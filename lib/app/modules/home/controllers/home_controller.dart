import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../data/models/new_workspace_request.dart';
import '../../../data/models/quick_action_model.dart';
import '../../../data/models/sidebar_item_model.dart';
import '../../../data/models/workspace_model.dart';
import '../../../routes/app_pages.dart';
import '../views/dialogs/new_workspace_dialog.dart';
import '../../../widgets/reusable_widgets/reusable_alert_dialog.dart';

class HomeController extends GetxController {
  static const String _recentWorkspacesStorageKey = 'recent_workspaces';
  static const String _activeWorkspaceStorageKey = 'active_workspace';
  static const int _maxRecentWorkspaces = 10;

  final GetStorage _storage = GetStorage();

  final selectedSidebarIndex = 0.obs;
  final isCreatingWorkspace = false.obs;

  late final List<SidebarItemModel> sidebarItems;
  late final List<QuickActionModel> quickActions;
  final recentWorkspaces = <WorkspaceModel>[].obs;

  final showAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    sidebarItems = _buildSidebarItems();
    quickActions = _buildQuickActions();
    recentWorkspaces.assignAll(_loadRecentWorkspaces());
  }

  Future<void> selectSidebarItem(int index) async {
    selectedSidebarIndex.value = index;

    final selectedItem = sidebarItems[index];
    if (selectedItem.label == AppStrings.navWorkspace) {
      final activeWorkspace = _loadActiveWorkspace();
      if (activeWorkspace == null) {
        await openExistingWorkspaceFlow();
        return;
      }
      _openWorkspace(activeWorkspace, showMessage: false);
      return;
    }

    if (selectedItem.label == AppStrings.navChat) {
      Get.toNamed(Routes.chatPage);
      return;
    }

    if (selectedItem.label == AppStrings.navSettings) {
      Get.toNamed(Routes.settings);
    }
  }

  Future<void> handleQuickAction(QuickActionType type) async {
    switch (type) {
      case QuickActionType.newWorkspace:
        await startNewWorkspaceFlow();
        break;
      case QuickActionType.openFolder:
        await openExistingWorkspaceFlow();
        break;
      case QuickActionType.localModel:
        Get.toNamed(Routes.settings);
        break;
      case QuickActionType.dataCenter:
        _showComingSoon(AppStrings.dataCenter, AppStrings.dataCenterComingSoon);
        break;
    }
  }

  Future<void> startNewWorkspaceFlow() async {
    if (isCreatingWorkspace.value) return;

    final defaultParentPath = await _resolveDefaultWorkspaceRoot();
    final request = await Get.dialog<NewWorkspaceRequest>(
      NewWorkspaceDialog(defaultParentPath: defaultParentPath),
      barrierDismissible: false,
    );

    if (request == null) return;
    await createWorkspace(request);
  }

  Future<void> createWorkspace(NewWorkspaceRequest request) async {
    final workspaceName = _sanitizeWorkspaceName(request.name);
    if (workspaceName.isEmpty) {
      _showError(AppStrings.workspaceInvalidNameMessage);
      return;
    }

    isCreatingWorkspace.value = true;

    try {
      final workspaceDirectory = Directory(
        path.join(request.parentPath, workspaceName),
      );
      await workspaceDirectory.create(recursive: true);
      await _createWorkspaceStructure(workspaceDirectory, workspaceName);

      final workspace = WorkspaceModel(
        name: workspaceName,
        path: workspaceDirectory.path,
      );

      _openWorkspace(
        workspace,
        successMessage: AppStrings.workspaceCreatedMessage,
      );
    } catch (error) {
      _showError('${AppStrings.workspaceCreateFailedMessage}\n$error');
    } finally {
      isCreatingWorkspace.value = false;
    }
  }

  Future<void> openExistingWorkspaceFlow() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: AppStrings.chooseWorkspaceFolderDialogTitle,
    );

    if (selectedPath == null || selectedPath.trim().isEmpty) return;

    final workspace = WorkspaceModel(
      name: path.basename(selectedPath),
      path: selectedPath,
    );

    _openWorkspace(
      workspace,
      successMessage: AppStrings.workspaceOpenedMessage,
    );
  }

  void openRecentWorkspace(WorkspaceModel workspace) {
    _openWorkspace(
      workspace,
      successMessage: AppStrings.workspaceSelectedMessage,
    );
  }

  Future<void> confirmDeleteWorkspace(WorkspaceModel workspace) async {
    final confirmed = await Get.dialog<bool>(
      ReusableAlertDialog(
        title: AppStrings.deleteWorkspace,
        content:
            '${AppStrings.deleteWorkspaceConfirmation} (${workspace.name})',
        confirmLabel: AppStrings.deleteWorkspace,
        isDestructive: true,
        onConfirm: () => Get.back(result: true),
      ),
    );

    if (confirmed == true) {
      final normalizedName = workspace.name.trim().toLowerCase();
      final normalizedPath = _normalizePath(workspace.path);
      recentWorkspaces.removeWhere((item) {
        return item.name.trim().toLowerCase() == normalizedName ||
            _normalizePath(item.path) == normalizedPath;
      });
      _saveRecentWorkspaces();
      _showSuccess(AppStrings.workspaceRemovedMessage);
    }
  }

  List<SidebarItemModel> _buildSidebarItems() {
    return const [
      SidebarItemModel(
        label: AppStrings.navHome,
        icon: Icons.dashboard_rounded,
      ),
      SidebarItemModel(
        label: AppStrings.navWorkspace,
        icon: Icons.code_rounded,
      ),
      SidebarItemModel(
        label: AppStrings.navChat,
        icon: Icons.chat_bubble_rounded,
      ),
      SidebarItemModel(
        label: AppStrings.navTerminal,
        icon: Icons.terminal_rounded,
      ),
      SidebarItemModel(label: AppStrings.navData, icon: Icons.storage_rounded),
      SidebarItemModel(
        label: AppStrings.navSettings,
        icon: Icons.settings_rounded,
      ),
    ];
  }

  List<QuickActionModel> _buildQuickActions() {
    return const [
      QuickActionModel(
        type: QuickActionType.newWorkspace,
        title: AppStrings.newWorkspace,
        subtitle: AppStrings.newWorkspaceSubtitle,
        icon: Icons.add_box_rounded,
        gradient: AppColors.primaryGradient,
      ),
      QuickActionModel(
        type: QuickActionType.openFolder,
        title: AppStrings.openFolder,
        subtitle: AppStrings.openFolderSubtitle,
        icon: Icons.folder_open_rounded,
        gradient: AppColors.cyanVioletGradient,
      ),
      QuickActionModel(
        type: QuickActionType.localModel,
        title: AppStrings.localModel,
        subtitle: AppStrings.runtimePolicy,
        icon: Icons.memory_rounded,
        gradient: AppColors.panelGradient,
      ),
      QuickActionModel(
        type: QuickActionType.dataCenter,
        title: AppStrings.dataCenter,
        subtitle: AppStrings.dataCenterSubtitle,
        icon: Icons.hub_rounded,
        gradient: AppColors.softDarkGradient,
      ),
    ];
  }

  Future<String> _resolveDefaultWorkspaceRoot() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final workspaceRoot = Directory(
      path.join(documentsDirectory.path, 'Logixa EDL Workspaces'),
    );
    await workspaceRoot.create(recursive: true);
    return workspaceRoot.path;
  }

  Future<void> _createWorkspaceStructure(
    Directory workspaceDirectory,
    String workspaceName,
  ) async {
    final folders = [
      '.logixa',
      'workspace',
      'data',
      'data/raw',
      'data/processed',
      'memory',
      'experts',
      'runtime',
      'logs',
    ];

    for (final folder in folders) {
      await Directory(
        path.join(workspaceDirectory.path, folder),
      ).create(recursive: true);
    }

    await _writeFileIfMissing(
      path.join(workspaceDirectory.path, 'README.md'),
      '# $workspaceName\n\nمساحة عمل Logixa EDL AI.\n',
    );

    final workspaceConfig = {
      'name': workspaceName,
      'path': workspaceDirectory.path,
      'created_at': DateTime.now().toIso8601String(),
      'version': 1,
      'engine': 'local_rust_engine',
      'model_lifecycle': {
        'local_model_enabled': true,
        'auto_start_on_message': true,
        'keep_model_loaded': false,
        'unload_after_response': true,
      },
    };

    await _writeFileIfMissing(
      path.join(workspaceDirectory.path, '.logixa', 'workspace.json'),
      const JsonEncoder.withIndent('  ').convert(workspaceConfig),
    );
  }

  Future<void> _writeFileIfMissing(String filePath, String content) async {
    final file = File(filePath);
    if (await file.exists()) return;
    await file.writeAsString(content);
  }

  List<WorkspaceModel> _loadRecentWorkspaces() {
    final stored = _storage.read<List<dynamic>>(_recentWorkspacesStorageKey);
    if (stored == null || stored.isEmpty) return const [];

    final uniqueWorkspaces = <WorkspaceModel>[];
    final seenNames = <String>{};
    final seenPaths = <String>{};

    final storedWorkspaces = stored
        .whereType<Map>()
        .map((item) => WorkspaceModel.fromJson(Map<String, dynamic>.from(item)))
        .where(
          (workspace) => workspace.name.isNotEmpty && workspace.path.isNotEmpty,
        )
        .map(_normalizeWorkspace);

    for (final workspace in storedWorkspaces) {
      final normalizedName = workspace.name.trim().toLowerCase();
      final normalizedPath = _normalizePath(workspace.path);

      if (seenNames.contains(normalizedName) ||
          seenPaths.contains(normalizedPath)) {
        continue;
      }

      seenNames.add(normalizedName);
      seenPaths.add(normalizedPath);
      uniqueWorkspaces.add(workspace);
    }

    return uniqueWorkspaces;
  }

  void _addRecentWorkspace(WorkspaceModel workspace) {
    final normalizedWorkspace = _normalizeWorkspace(workspace);
    final normalizedName = normalizedWorkspace.name.toLowerCase();
    final normalizedPath = _normalizePath(normalizedWorkspace.path);

    recentWorkspaces.removeWhere((item) {
      final itemName = item.name.trim().toLowerCase();
      final itemPath = _normalizePath(item.path);
      return itemName == normalizedName || itemPath == normalizedPath;
    });

    recentWorkspaces.insert(0, normalizedWorkspace);

    if (recentWorkspaces.length > _maxRecentWorkspaces) {
      recentWorkspaces.removeRange(
        _maxRecentWorkspaces,
        recentWorkspaces.length,
      );
    }

    _saveRecentWorkspaces();
  }

  void _openWorkspace(
    WorkspaceModel workspace, {
    String? successMessage,
    bool showMessage = true,
  }) {
    final normalizedWorkspace = _normalizeWorkspace(workspace);

    _addRecentWorkspace(normalizedWorkspace);
    _saveActiveWorkspace(normalizedWorkspace);

    if (showMessage && successMessage != null) {
      _showSuccess(successMessage);
    }

    Get.toNamed(Routes.workSpace, arguments: normalizedWorkspace.toJson());
  }

  WorkspaceModel? _loadActiveWorkspace() {
    final stored = _storage.read(_activeWorkspaceStorageKey);
    if (stored is! Map) return null;

    final workspace = WorkspaceModel.fromJson(
      Map<String, dynamic>.from(stored),
    );
    if (workspace.name.trim().isEmpty || workspace.path.trim().isEmpty) {
      return null;
    }

    return _normalizeWorkspace(workspace);
  }

  void _saveActiveWorkspace(WorkspaceModel workspace) {
    _storage.write(
      _activeWorkspaceStorageKey,
      _normalizeWorkspace(workspace).toJson(),
    );
  }

  WorkspaceModel _normalizeWorkspace(WorkspaceModel workspace) {
    final normalizedPath = _normalizePath(workspace.path);
    final safeName = workspace.name.trim().isNotEmpty
        ? workspace.name.trim()
        : path.basename(normalizedPath);

    return WorkspaceModel(name: safeName, path: normalizedPath);
  }

  String _normalizePath(String value) {
    final expanded = value.trim().replaceFirst(
      RegExp(r'^~(?=/|\\)'),
      Platform.environment['HOME'] ?? '~',
    );
    return path.normalize(path.absolute(expanded));
  }

  void _saveRecentWorkspaces() {
    _storage.write(
      _recentWorkspacesStorageKey,
      recentWorkspaces.map((workspace) => workspace.toJson()).toList(),
    );
  }

  String _sanitizeWorkspaceName(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\u0600-\u06FF ]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  void _showSuccess(String message) {
    Get.snackbar(
      AppStrings.doneTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successSoft,
      colorText: AppColors.textPrimary,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      AppStrings.errorTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorSoft,
      colorText: AppColors.textPrimary,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showComingSoon(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.infoSoft,
      colorText: AppColors.textPrimary,
      margin: const EdgeInsets.all(16),
    );
  }
}
