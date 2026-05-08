import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as path;

import '../../../data/models/opened_file_model.dart';
import '../../../data/models/workspace_file_item_model.dart';
import '../../../data/models/workspace_model.dart';

enum WorkSpaceSidePanel { explorer, extensions }

enum WorkSpaceBottomPanel { terminal, logs, problems, output }

class WorkSpaceController extends GetxController {
  static const String _activeWorkspaceStorageKey = 'active_workspace';
  static const int _maxPreviewBytes = 512 * 1024;

  final GetStorage _storage = GetStorage();

  final activeWorkspace = Rxn<WorkspaceModel>();
  final workspaceFiles = <WorkspaceFileItemModel>[].obs;
  final expandedDirectoryPaths = <String>{}.obs;
  final activeSidePanel = WorkSpaceSidePanel.explorer.obs;
  final activeBottomPanel = WorkSpaceBottomPanel.terminal.obs;
  final openedFiles = <OpenedFileModel>[].obs;
  final workspaceLogs = <String>[].obs;
  final isBottomPanelVisible = true.obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final openedFileName = ''.obs;
  final openedFilePath = ''.obs;
  final openedFileContent = ''.obs;
  final openedFileSizeLabel = ''.obs;

  int _scanVersion = 0;

  bool get hasWorkspace => activeWorkspace.value != null;
  bool get hasOpenedFile => openedFilePath.value.isNotEmpty;
  bool get hasOpenedTabs => openedFiles.isNotEmpty;
  bool get isTreePossiblyLimited =>
      workspaceFiles.length >= _workspaceMaxVisibleItems;

  OpenedFileModel? get activeOpenedFile {
    final activePath = openedFilePath.value;
    if (activePath.isEmpty) return null;
    return openedFiles.firstWhereOrNull((file) => file.path == activePath);
  }

  String get openedFileSubtitle {
    final activeFile = activeOpenedFile;
    if (activeFile != null) {
      if (activeFile.sizeLabel.isEmpty) return activeFile.relativePath;
      return '${activeFile.relativePath} • ${activeFile.sizeLabel}';
    }

    final workspace = activeWorkspace.value;
    final filePath = openedFilePath.value;
    if (workspace == null || filePath.isEmpty) return '';

    final relative = path.relative(filePath, from: workspace.path);
    final size = openedFileSizeLabel.value;
    if (size.isEmpty) return relative;
    return '$relative • $size';
  }

  List<WorkspaceFileItemModel> get visibleWorkspaceFiles {
    // Read length explicitly so Obx tracks folder expand/collapse changes.
    expandedDirectoryPaths.length;

    return workspaceFiles.where(_isItemVisibleInTree).toList(growable: false);
  }

  bool get isExplorerPanelActive =>
      activeSidePanel.value == WorkSpaceSidePanel.explorer;

  bool get isExtensionsPanelActive =>
      activeSidePanel.value == WorkSpaceSidePanel.extensions;

  bool get isTerminalPanelActive =>
      activeBottomPanel.value == WorkSpaceBottomPanel.terminal;

  bool get isLogsPanelActive =>
      activeBottomPanel.value == WorkSpaceBottomPanel.logs;

  bool get isProblemsPanelActive =>
      activeBottomPanel.value == WorkSpaceBottomPanel.problems;

  bool get isOutputPanelActive =>
      activeBottomPanel.value == WorkSpaceBottomPanel.output;

  @override
  void onInit() {
    super.onInit();
    _loadActiveWorkspace();
  }

  Future<void> refreshWorkspace() async {
    final workspace = activeWorkspace.value;
    if (workspace == null) return;
    await _loadWorkspaceTree(workspace);
  }

  void selectSidePanel(WorkSpaceSidePanel panel) {
    activeSidePanel.value = panel;
  }

  void selectBottomPanel(WorkSpaceBottomPanel panel) {
    activeBottomPanel.value = panel;
    isBottomPanelVisible.value = true;
  }

  void toggleBottomPanelVisibility() {
    isBottomPanelVisible.value = !isBottomPanelVisible.value;
  }

  void clearWorkspaceLogs() {
    workspaceLogs.clear();
    _pushWorkspaceLog('تم مسح لوجات مساحة العمل.');
  }

  void toggleDirectory(WorkspaceFileItemModel item) {
    if (!item.isDirectory) return;

    if (expandedDirectoryPaths.contains(item.relativePath)) {
      expandedDirectoryPaths.remove(item.relativePath);
    } else {
      expandedDirectoryPaths.add(item.relativePath);
    }
  }

  void expandAllDirectories() {
    final directories = workspaceFiles
        .where((item) => item.isDirectory)
        .map((item) => item.relativePath)
        .toSet();
    expandedDirectoryPaths.assignAll(directories);
  }

  void collapseAllDirectories() {
    expandedDirectoryPaths.clear();
  }

  bool isDirectoryExpanded(WorkspaceFileItemModel item) {
    if (!item.isDirectory) return false;
    return expandedDirectoryPaths.contains(item.relativePath);
  }

  bool isFileOpened(WorkspaceFileItemModel item) {
    return !item.isDirectory && openedFilePath.value == item.path;
  }

  bool isFileInTabs(String filePath) {
    return openedFiles.any((file) => file.path == filePath);
  }

  Future<void> openFile(WorkspaceFileItemModel item) async {
    if (item.isDirectory) return;

    final alreadyOpened = openedFiles.firstWhereOrNull(
      (file) => file.path == item.path,
    );

    if (alreadyOpened != null) {
      setActiveOpenedFile(alreadyOpened.path);
      return;
    }

    errorMessage.value = '';

    try {
      final file = File(item.path);
      final bytes = await file.readAsBytes();
      final relativePath = _relativePathFor(item.path);
      final sizeLabel = _formatBytes(item.sizeBytes);
      late final String content;

      if (bytes.length > _maxPreviewBytes) {
        content = 'الملف كبير للمعاينة السريعة. افتحه لاحقًا في محرر كامل.';
      } else if (_looksBinary(bytes)) {
        content = 'الملف يبدو Binary أو غير نصي، لذلك المعاينة النصية متوقفة.';
      } else {
        content = utf8.decode(bytes, allowMalformed: true);
      }

      final openedFile = OpenedFileModel(
        name: item.name,
        path: item.path,
        relativePath: relativePath,
        content: content,
        sizeLabel: sizeLabel,
      );

      openedFiles.add(openedFile);
      _applyActiveFile(openedFile);
      _pushWorkspaceLog('تم فتح الملف: $relativePath');
    } catch (error) {
      openedFileContent.value = '';
      errorMessage.value = 'تعذر فتح الملف: $error';
      _pushWorkspaceLog('تعذر فتح الملف: $error');
    }
  }

  void setActiveOpenedFile(String filePath) {
    final file = openedFiles.firstWhereOrNull((item) => item.path == filePath);
    if (file == null) return;
    _applyActiveFile(file);
  }

  void closeOpenedFile(String filePath) {
    final closingIndex = openedFiles.indexWhere((file) => file.path == filePath);
    if (closingIndex == -1) return;

    final wasActive = openedFilePath.value == filePath;
    final closedFile = openedFiles[closingIndex];
    openedFiles.removeAt(closingIndex);
    _pushWorkspaceLog('تم إغلاق تبويب: ${closedFile.relativePath}');

    if (!wasActive) return;

    if (openedFiles.isEmpty) {
      _clearActiveFile();
      return;
    }

    final nextIndex = closingIndex >= openedFiles.length
        ? openedFiles.length - 1
        : closingIndex;
    _applyActiveFile(openedFiles[nextIndex]);
  }

  Future<void> _loadActiveWorkspace() async {
    final workspace = _workspaceFromArguments() ?? _workspaceFromStorage();

    if (workspace == null) {
      errorMessage.value =
          'لا توجد مساحة عمل نشطة. افتح مشروع من الصفحة الرئيسية.';
      return;
    }

    activeWorkspace.value = workspace;
    _storage.write(_activeWorkspaceStorageKey, workspace.toJson());
    _pushWorkspaceLog('تم تحميل مساحة العمل: ${workspace.name}');
    await _loadWorkspaceTree(workspace);
  }

  WorkspaceModel? _workspaceFromArguments() {
    final args = Get.arguments;
    if (args is WorkspaceModel) return _normalizeWorkspace(args);
    if (args is Map<String, dynamic>) {
      return _normalizeWorkspace(WorkspaceModel.fromJson(args));
    }
    if (args is Map) {
      return _normalizeWorkspace(
        WorkspaceModel.fromJson(Map<String, dynamic>.from(args)),
      );
    }
    return null;
  }

  WorkspaceModel? _workspaceFromStorage() {
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

  Future<void> _loadWorkspaceTree(WorkspaceModel workspace) async {
    final currentScan = ++_scanVersion;

    isLoading.value = true;
    errorMessage.value = '';
    workspaceFiles.clear();
    _clearOpenedFileState();

    try {
      final rootDirectory = Directory(workspace.path);
      if (!await rootDirectory.exists()) {
        if (currentScan == _scanVersion) {
          errorMessage.value = 'مسار المشروع غير موجود على الجهاز.';
        }
        return;
      }

      // مهم: قراءة شجرة الملفات على Isolate منفصل عشان الواجهة ما تعملش Freeze
      // لو المشروع كبير أو فيه folders تقيلة زي build/node_modules/.dart_tool.
      final items = await Isolate.run(
        () => _scanWorkspaceDirectory(rootDirectory.path),
      );

      if (currentScan != _scanVersion) return;

      workspaceFiles.assignAll(items);
      _seedExpandedDirectories(items);
      _pushWorkspaceLog('تم قراءة ${items.length} عنصر من ملفات المشروع.');
      await _openDefaultFileIfAvailable();
    } catch (error) {
      if (currentScan == _scanVersion) {
        errorMessage.value = 'تعذر قراءة ملفات المشروع: $error';
        _pushWorkspaceLog('تعذر قراءة ملفات المشروع: $error');
      }
    } finally {
      if (currentScan == _scanVersion) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _openDefaultFileIfAvailable() async {
    if (hasOpenedFile || workspaceFiles.isEmpty) return;

    final rootReadme = workspaceFiles.firstWhereOrNull(
      (item) =>
          !item.isDirectory &&
          item.name.toLowerCase() == 'readme.md' &&
          !item.relativePath.contains(path.separator),
    );

    final readme = rootReadme ??
        workspaceFiles.firstWhereOrNull(
          (item) => !item.isDirectory && item.name.toLowerCase() == 'readme.md',
        );

    final fallback =
        readme ?? workspaceFiles.firstWhereOrNull((item) => !item.isDirectory);
    if (fallback != null) await openFile(fallback);
  }

  void _applyActiveFile(OpenedFileModel file) {
    openedFileName.value = file.name;
    openedFilePath.value = file.path;
    openedFileContent.value = file.content;
    openedFileSizeLabel.value = file.sizeLabel;
  }

  void _clearActiveFile() {
    openedFileName.value = '';
    openedFilePath.value = '';
    openedFileContent.value = '';
    openedFileSizeLabel.value = '';
  }

  void _clearOpenedFileState() {
    openedFiles.clear();
    _clearActiveFile();
  }

  void _seedExpandedDirectories(List<WorkspaceFileItemModel> items) {
    expandedDirectoryPaths.clear();
  }

  bool _isItemVisibleInTree(WorkspaceFileItemModel item) {
    if (item.depth == 0) return true;

    final parts = path.split(item.relativePath);
    if (parts.length <= 1) return true;

    final ancestorParts = <String>[];
    for (var i = 0; i < parts.length - 1; i++) {
      ancestorParts.add(parts[i]);
      final ancestor = path.joinAll(ancestorParts);
      if (!expandedDirectoryPaths.contains(ancestor)) return false;
    }

    return true;
  }

  bool _looksBinary(List<int> bytes) {
    final sampleLength = bytes.length > 8000 ? 8000 : bytes.length;
    for (var i = 0; i < sampleLength; i++) {
      if (bytes[i] == 0) return true;
    }
    return false;
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

  String _relativePathFor(String filePath) {
    final workspace = activeWorkspace.value;
    if (workspace == null) return filePath;
    return path.relative(filePath, from: workspace.path);
  }

  void _pushWorkspaceLog(String message) {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    workspaceLogs.insert(0, '[$hour:$minute:$second] $message');

    if (workspaceLogs.length > 80) {
      workspaceLogs.removeRange(80, workspaceLogs.length);
    }
  }
}

const int _workspaceMaxTreeDepth = 5;
const int _workspaceMaxVisibleItems = 900;

const Set<String> _workspaceIgnoredNames = {
  '.git',
  '.dart_tool',
  '.idea',
  '.vscode',
  '.gradle',
  '.cache',
  '.next',
  '.nuxt',
  '.vercel',
  '.firebase',
  'build',
  'node_modules',
  'Pods',
  'target',
  'dist',
  'coverage',
  '.venv',
  'venv',
  '__pycache__',
  '.DS_Store',
  '.fvm',
  '.mypy_cache',
  '.pytest_cache',
  '.ruff_cache',
  '.history',
  '.terraform',
  '.tox',
  '.turbo',
  '.parcel-cache',
  'vendor',
};

Future<List<WorkspaceFileItemModel>> _scanWorkspaceDirectory(
  String rootPath,
) async {
  final rootDirectory = Directory(rootPath);
  final output = <WorkspaceFileItemModel>[];

  await _collectDirectoryItemsSafely(
    directory: rootDirectory,
    rootPath: rootDirectory.path,
    depth: 0,
    output: output,
  );

  return output;
}

Future<void> _collectDirectoryItemsSafely({
  required Directory directory,
  required String rootPath,
  required int depth,
  required List<WorkspaceFileItemModel> output,
}) async {
  if (depth > _workspaceMaxTreeDepth ||
      output.length >= _workspaceMaxVisibleItems) {
    return;
  }

  List<FileSystemEntity> children;
  try {
    children = await directory.list(followLinks: false).toList();
  } catch (_) {
    return;
  }

  children.sort(_sortEntitiesForExplorer);

  for (final entity in children) {
    if (output.length >= _workspaceMaxVisibleItems) return;

    final name = path.basename(entity.path);
    if (_shouldIgnoreEntity(name)) continue;

    final isDirectory = entity is Directory;
    FileStat? stat;

    try {
      stat = await entity.stat();
    } catch (_) {
      stat = null;
    }

    output.add(
      WorkspaceFileItemModel(
        name: name,
        path: path.normalize(entity.path),
        relativePath: path.relative(entity.path, from: rootPath),
        isDirectory: isDirectory,
        depth: depth,
        sizeBytes: isDirectory ? null : stat?.size,
        modifiedAt: stat?.modified,
      ),
    );

    if (isDirectory) {
      await _collectDirectoryItemsSafely(
        directory: entity,
        rootPath: rootPath,
        depth: depth + 1,
        output: output,
      );
    }
  }
}

bool _shouldIgnoreEntity(String name) {
  if (_workspaceIgnoredNames.contains(name)) return true;
  if (name.endsWith('.lock')) return true;
  if (name.endsWith('.tmp')) return true;
  return false;
}

String _formatBytes(int? value) {
  if (value == null) return '';
  if (value < 1024) return '$value B';

  final kb = value / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';

  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(mb >= 100 ? 0 : 1)} MB';

  final gb = mb / 1024;
  return '${gb.toStringAsFixed(gb >= 100 ? 0 : 1)} GB';
}

int _sortEntitiesForExplorer(FileSystemEntity a, FileSystemEntity b) {
  final aIsDirectory = a is Directory;
  final bIsDirectory = b is Directory;

  if (aIsDirectory && !bIsDirectory) return -1;
  if (!aIsDirectory && bIsDirectory) return 1;

  return path
      .basename(a.path)
      .toLowerCase()
      .compareTo(path.basename(b.path).toLowerCase());
}
