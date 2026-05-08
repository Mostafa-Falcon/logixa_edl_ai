import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as path;
import 'package:xterm/xterm.dart';

import '../../../constants/app_strings.dart';
import '../../../data/models/opened_file_model.dart';
import '../../../data/models/workspace_file_item_model.dart';
import '../../../data/models/workspace_model.dart';
import '../../../data/services/engine_client_service.dart';

enum WorkSpaceSidePanel { explorer, extensions }

enum WorkSpaceBottomPanel { terminal, logs, problems, output }

class WorkSpaceController extends GetxController {
  static const String _activeWorkspaceStorageKey = 'active_workspace';
  static const int _maxEditableBytes = 512 * 1024;
  static const int _terminalRows = 24;
  static const int _terminalColumns = 100;

  static const String _eventWorkspaceRefreshed = 'workspace_refreshed';
  static const String _eventWorkspaceLoaded = 'workspace_loaded';
  static const String _eventFileOpened = 'file_opened';
  static const String _eventActiveFileChanged = 'active_file_changed';
  static const String _eventActiveFileCleared = 'active_file_cleared';
  static const String _eventActiveFileChangedAfterClose =
      'active_file_changed_after_close';

  static const String _metadataEventKey = 'event';
  static const String _metadataSourceKey = 'source';
  static const String _metadataSourceFlutterWorkspace = 'flutter_workspace';
  static const String _metadataOpenedFileCountKey = 'opened_file_count';
  static const String _metadataOpenedFilesKey = 'opened_files';
  static const String _metadataWorkspaceFileCountKey = 'workspace_file_count';
  static const String _metadataSidePanelKey = 'side_panel';
  static const String _metadataBottomPanelKey = 'bottom_panel';
  static const String _metadataBottomPanelVisibleKey = 'bottom_panel_visible';

  final GetStorage _storage = GetStorage();

  late final Terminal terminal = Terminal(
    maxLines: 2000,
    onOutput: _handleTerminalInput,
    onResize: _handleTerminalResize,
  );

  Pty? _terminalPty;
  StreamSubscription<Uint8List>? _terminalOutputSubscription;

  final activeWorkspace = Rxn<WorkspaceModel>();
  final workspaceFiles = <WorkspaceFileItemModel>[].obs;
  final expandedDirectoryPaths = <String>{}.obs;
  final activeSidePanel = WorkSpaceSidePanel.explorer.obs;
  final activeBottomPanel = WorkSpaceBottomPanel.terminal.obs;
  final openedFiles = <OpenedFileModel>[].obs;
  final workspaceLogs = <String>[].obs;
  final isBottomPanelVisible = true.obs;
  final isSyncingWorkspaceSession = false.obs;
  final lastWorkspaceSessionId = ''.obs;
  final isTerminalRunning = false.obs;
  final isTerminalStarting = false.obs;
  final terminalStatusMessage = AppStrings.workspaceTerminalStopped.obs;
  final terminalWorkingDirectory = ''.obs;
  final dirtyFilePaths = <String>{}.obs;
  final protectedFilePaths = <String>{}.obs;
  final isSavingOpenedFile = false.obs;

  final Map<String, String> _savedFileContentByPath = {};

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

  bool get isActiveFileDirty {
    dirtyFilePaths.length;
    final activePath = openedFilePath.value;
    if (activePath.isEmpty) return false;
    return dirtyFilePaths.contains(activePath);
  }

  bool get isActiveFileEditable {
    protectedFilePaths.length;
    final activePath = openedFilePath.value;
    if (activePath.isEmpty) return false;
    return !protectedFilePaths.contains(activePath);
  }

  bool get canSaveActiveFile =>
      hasOpenedFile &&
      isActiveFileEditable &&
      isActiveFileDirty &&
      !isSavingOpenedFile.value;

  String get activeEditorStatusLabel {
    if (!hasOpenedFile) return '';
    if (isSavingOpenedFile.value) return AppStrings.workspaceEditorSaving;
    if (!isActiveFileEditable) return AppStrings.workspaceEditorReadOnly;
    if (isActiveFileDirty) return AppStrings.workspaceEditorUnsaved;
    return AppStrings.workspaceEditorSaved;
  }

  bool isFileDirty(String filePath) {
    dirtyFilePaths.length;
    return dirtyFilePaths.contains(filePath);
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

  @override
  void onClose() {
    _disposeTerminalProcess();
    super.onClose();
  }

  Future<void> refreshWorkspace() async {
    final workspace = activeWorkspace.value;
    if (workspace == null) return;
    await _syncWorkspaceSessionToMemory(event: _eventWorkspaceRefreshed);
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
    _pushWorkspaceLog(AppStrings.workspaceLogsCleared);
  }

  Future<void> startTerminal() async {
    if (isTerminalRunning.value || isTerminalStarting.value) return;

    final workspace = activeWorkspace.value;
    if (workspace == null) {
      terminalStatusMessage.value = AppStrings.workspaceTerminalNoWorkspace;
      _pushWorkspaceLog(AppStrings.workspaceTerminalNoWorkspace);
      return;
    }

    isTerminalStarting.value = true;
    terminalWorkingDirectory.value = workspace.path;
    terminalStatusMessage.value = AppStrings.workspaceTerminalStarting;
    terminal.write(
      '\r\n${AppStrings.workspaceTerminalStartingBanner} ${workspace.path}\r\n',
    );

    try {
      final shell = _resolveTerminalShell();
      final pty = Pty.start(
        shell.executable,
        arguments: shell.arguments,
        workingDirectory: workspace.path,
        environment: _terminalEnvironment(),
        rows: _terminalRows,
        columns: _terminalColumns,
      );

      _terminalPty = pty;
      _terminalOutputSubscription = pty.output.listen(
        _handleTerminalOutput,
        onError: (Object error) {
          terminal.write(
            '\r\n${AppStrings.workspaceTerminalOutputErrorPrefix} $error\r\n',
          );
          _pushWorkspaceLog(
            '${AppStrings.workspaceTerminalOutputErrorPrefix} $error',
          );
        },
      );

      unawaited(
        pty.exitCode.then((code) {
          if (_terminalPty != pty) return;
          _markTerminalStopped(code);
        }),
      );

      isTerminalRunning.value = true;
      terminalStatusMessage.value = AppStrings.workspaceTerminalRunning;
      _pushWorkspaceLog(
        '${AppStrings.workspaceTerminalStartedLogPrefix} ${workspace.path}',
      );
    } catch (error) {
      terminalStatusMessage.value = AppStrings.workspaceTerminalFailed;
      terminal.write(
        '\r\n${AppStrings.workspaceTerminalStartFailedPrefix} $error\r\n',
      );
      _pushWorkspaceLog(
        '${AppStrings.workspaceTerminalStartFailedPrefix} $error',
      );
      _terminalPty = null;
      await _terminalOutputSubscription?.cancel();
      _terminalOutputSubscription = null;
    } finally {
      isTerminalStarting.value = false;
    }
  }

  Future<void> stopTerminal() async {
    final pty = _terminalPty;
    if (pty == null) {
      isTerminalRunning.value = false;
      terminalStatusMessage.value = AppStrings.workspaceTerminalStopped;
      return;
    }

    terminalStatusMessage.value = AppStrings.workspaceTerminalStopping;
    pty.kill();
    await _terminalOutputSubscription?.cancel();
    _terminalOutputSubscription = null;
    _terminalPty = null;
    isTerminalRunning.value = false;
    terminalStatusMessage.value = AppStrings.workspaceTerminalStopped;
    terminal.write('\r\n${AppStrings.workspaceTerminalStoppedBanner}\r\n');
    _pushWorkspaceLog(AppStrings.workspaceTerminalStoppedLog);
  }

  Future<void> restartTerminal() async {
    await stopTerminal();
    await startTerminal();
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

  Future<void> openWorkspaceItemFromContextMenu(
    WorkspaceFileItemModel item,
  ) async {
    if (item.isDirectory) {
      toggleDirectory(item);
      return;
    }

    await openFile(item);
  }

  Future<void> copyWorkspaceItemPath(WorkspaceFileItemModel item) async {
    await Clipboard.setData(ClipboardData(text: item.path));
    _pushWorkspaceLog(
      '${AppStrings.workspacePathCopiedLogPrefix} ${item.path}',
    );
  }

  Future<void> revealWorkspaceItemPath(WorkspaceFileItemModel item) async {
    try {
      final revealTargetPath = item.isDirectory
          ? item.path
          : File(item.path).parent.path;

      if (Platform.isLinux) {
        await Process.start('xdg-open', [revealTargetPath]);
      } else if (Platform.isMacOS) {
        await Process.start(
          'open',
          item.isDirectory ? [item.path] : ['-R', item.path],
        );
      } else if (Platform.isWindows) {
        await Process.start(
          'explorer',
          item.isDirectory ? [revealTargetPath] : ['/select,', item.path],
        );
      } else {
        _pushWorkspaceLog(AppStrings.workspacePathRevealUnsupported);
        return;
      }

      _pushWorkspaceLog(
        '${AppStrings.workspacePathRevealStartedPrefix} ${item.path}',
      );
    } catch (error) {
      _pushWorkspaceLog('${AppStrings.workspacePathRevealFailedPrefix} $error');
    }
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
      var isEditable = true;
      late final String content;

      if (bytes.length > _maxEditableBytes) {
        content = AppStrings.workspaceLargeFilePreviewBlocked;
        isEditable = false;
      } else if (_looksBinary(bytes)) {
        content = AppStrings.workspaceBinaryPreviewBlocked;
        isEditable = false;
      } else {
        content = utf8.decode(bytes, allowMalformed: true);
      }

      if (isEditable) {
        protectedFilePaths.remove(item.path);
      } else {
        protectedFilePaths.add(item.path);
      }
      dirtyFilePaths.remove(item.path);
      _savedFileContentByPath[item.path] = content;

      final openedFile = OpenedFileModel(
        name: item.name,
        path: item.path,
        relativePath: relativePath,
        content: content,
        sizeLabel: sizeLabel,
      );

      openedFiles.add(openedFile);
      _applyActiveFile(openedFile);
      _pushWorkspaceLog(
        '${AppStrings.workspaceFileOpenedLogPrefix} $relativePath',
      );
      await _syncWorkspaceSessionToMemory(
        event: _eventFileOpened,
        activeFile: relativePath,
      );
    } catch (error) {
      openedFileContent.value = '';
      errorMessage.value = '${AppStrings.workspaceFileOpenFailedPrefix} $error';
      _pushWorkspaceLog('${AppStrings.workspaceFileOpenFailedPrefix} $error');
    }
  }

  void setActiveOpenedFile(String filePath) {
    final file = openedFiles.firstWhereOrNull((item) => item.path == filePath);
    if (file == null) return;
    _applyActiveFile(file);
    unawaited(
      _syncWorkspaceSessionToMemory(
        event: _eventActiveFileChanged,
        activeFile: file.relativePath,
      ),
    );
  }

  void updateActiveOpenedFileContent(String content) {
    final filePath = openedFilePath.value;
    if (filePath.isEmpty || !isActiveFileEditable) return;

    if (openedFileContent.value != content) {
      openedFileContent.value = content;
    }

    final index = openedFiles.indexWhere((file) => file.path == filePath);
    if (index != -1 && openedFiles[index].content != content) {
      openedFiles[index] = openedFiles[index].copyWith(content: content);
    }

    final savedContent = _savedFileContentByPath[filePath] ?? '';
    if (content == savedContent) {
      dirtyFilePaths.remove(filePath);
    } else {
      dirtyFilePaths.add(filePath);
    }
  }

  Future<void> saveActiveFile() async {
    final filePath = openedFilePath.value;
    if (filePath.isEmpty || isSavingOpenedFile.value) return;

    final activeFile = activeOpenedFile;
    if (activeFile == null) return;

    if (!isActiveFileEditable) {
      _pushWorkspaceLog(AppStrings.workspaceFileSaveBlocked);
      return;
    }

    if (!isActiveFileDirty) return;

    isSavingOpenedFile.value = true;
    try {
      final content = openedFileContent.value;
      final file = File(filePath);
      await file.writeAsString(content, flush: true);
      final sizeLabel = _formatBytes(await file.length());
      final index = openedFiles.indexWhere((item) => item.path == filePath);

      _savedFileContentByPath[filePath] = content;
      dirtyFilePaths.remove(filePath);
      openedFileSizeLabel.value = sizeLabel;

      if (index != -1) {
        openedFiles[index] = openedFiles[index].copyWith(
          content: content,
          sizeLabel: sizeLabel,
        );
      }

      _pushWorkspaceLog(
        '${AppStrings.workspaceFileSavedLogPrefix} ${activeFile.relativePath}',
      );
    } catch (error) {
      _pushWorkspaceLog('${AppStrings.workspaceFileSaveFailedPrefix} $error');
    } finally {
      isSavingOpenedFile.value = false;
    }
  }

  void closeOpenedFile(String filePath) {
    final closingIndex = openedFiles.indexWhere(
      (file) => file.path == filePath,
    );
    if (closingIndex == -1) return;

    final wasActive = openedFilePath.value == filePath;
    final closedFile = openedFiles[closingIndex];
    final hadUnsavedChanges = dirtyFilePaths.contains(filePath);

    openedFiles.removeAt(closingIndex);
    dirtyFilePaths.remove(filePath);
    protectedFilePaths.remove(filePath);
    _savedFileContentByPath.remove(filePath);

    if (hadUnsavedChanges) {
      _pushWorkspaceLog(
        '${AppStrings.workspaceFileUnsavedDiscardedLogPrefix} '
        '${closedFile.relativePath}',
      );
    }

    _pushWorkspaceLog(
      '${AppStrings.workspaceTabClosedLogPrefix} ${closedFile.relativePath}',
    );

    if (!wasActive) return;

    if (openedFiles.isEmpty) {
      _clearActiveFile();
      unawaited(_syncWorkspaceSessionToMemory(event: _eventActiveFileCleared));
      return;
    }

    final nextIndex = closingIndex >= openedFiles.length
        ? openedFiles.length - 1
        : closingIndex;
    final nextFile = openedFiles[nextIndex];
    _applyActiveFile(nextFile);
    unawaited(
      _syncWorkspaceSessionToMemory(
        event: _eventActiveFileChangedAfterClose,
        activeFile: nextFile.relativePath,
      ),
    );
  }

  void _handleTerminalInput(String data) {
    final pty = _terminalPty;
    if (pty == null || !isTerminalRunning.value) return;
    pty.write(const Utf8Encoder().convert(data));
  }

  void _handleTerminalOutput(Uint8List data) {
    final text = const Utf8Decoder(allowMalformed: true).convert(data);
    terminal.write(text);
  }

  void _handleTerminalResize(
    int width,
    int height,
    int pixelWidth,
    int pixelHeight,
  ) {
    final pty = _terminalPty;
    if (pty == null || width <= 0 || height <= 0) return;
    pty.resize(height, width);
  }

  void _markTerminalStopped(int code) {
    _terminalPty = null;
    unawaited(_terminalOutputSubscription?.cancel());
    _terminalOutputSubscription = null;
    isTerminalRunning.value = false;
    terminalStatusMessage.value =
        '${AppStrings.workspaceTerminalExitedPrefix} $code';
    terminal.write('\r\n${AppStrings.workspaceTerminalExitedPrefix} $code\r\n');
    _pushWorkspaceLog('${AppStrings.workspaceTerminalExitedPrefix} $code');
  }

  void _disposeTerminalProcess() {
    _terminalPty?.kill();
    unawaited(_terminalOutputSubscription?.cancel());
    _terminalOutputSubscription = null;
    _terminalPty = null;
    isTerminalRunning.value = false;
  }

  _TerminalShell _resolveTerminalShell() {
    if (Platform.isWindows) {
      return const _TerminalShell(executable: 'cmd.exe');
    }

    if (Platform.isMacOS || Platform.isLinux) {
      final shell = Platform.environment['SHELL'];
      if (shell != null && shell.trim().isNotEmpty) {
        return _TerminalShell(executable: shell.trim());
      }
      return const _TerminalShell(executable: 'bash');
    }

    return const _TerminalShell(executable: 'sh');
  }

  Map<String, String> _terminalEnvironment() {
    return {
      ...Platform.environment,
      'TERM': 'xterm-256color',
      'COLORTERM': 'truecolor',
    };
  }

  Future<void> _syncWorkspaceSessionToMemory({
    required String event,
    String? activeFile,
  }) async {
    final workspace = activeWorkspace.value;
    if (workspace == null || isSyncingWorkspaceSession.value) return;

    final engineClient = Get.isRegistered<EngineClientService>()
        ? Get.find<EngineClientService>()
        : null;
    if (engineClient == null) {
      _pushWorkspaceLog(AppStrings.workspaceEngineClientNotReady);
      return;
    }

    final resolvedActiveFile = activeFile ?? activeOpenedFile?.relativePath;

    isSyncingWorkspaceSession.value = true;
    try {
      final result = await engineClient.createMemoryWorkspaceSession(
        workspacePath: workspace.path,
        workspaceName: workspace.name,
        activeFile: resolvedActiveFile,
        metadata: {
          _metadataEventKey: event,
          _metadataSourceKey: _metadataSourceFlutterWorkspace,
          _metadataOpenedFileCountKey: openedFiles.length,
          _metadataOpenedFilesKey: openedFiles
              .map((file) => file.relativePath)
              .take(20)
              .toList(growable: false),
          _metadataWorkspaceFileCountKey: workspaceFiles.length,
          _metadataSidePanelKey: activeSidePanel.value.name,
          _metadataBottomPanelKey: activeBottomPanel.value.name,
          _metadataBottomPanelVisibleKey: isBottomPanelVisible.value,
        },
      );

      if (!result.ok) {
        _pushWorkspaceLog(
          '${AppStrings.workspaceSessionSyncFailed} ${result.message}',
        );
        return;
      }

      lastWorkspaceSessionId.value = result.sessionId ?? '';
      _pushWorkspaceLog(AppStrings.workspaceSessionSyncedToMemory);
    } catch (error) {
      _pushWorkspaceLog('${AppStrings.workspaceSessionSyncFailed} $error');
    } finally {
      isSyncingWorkspaceSession.value = false;
    }
  }

  Future<void> _loadActiveWorkspace() async {
    final workspace = _workspaceFromArguments() ?? _workspaceFromStorage();

    if (workspace == null) {
      errorMessage.value = AppStrings.workspaceNoActiveWorkspaceOpenFromHome;
      return;
    }

    activeWorkspace.value = workspace;
    _storage.write(_activeWorkspaceStorageKey, workspace.toJson());
    _pushWorkspaceLog(
      '${AppStrings.workspaceLoadedLogPrefix} ${workspace.name}',
    );
    await _syncWorkspaceSessionToMemory(event: _eventWorkspaceLoaded);
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
          errorMessage.value = AppStrings.workspacePathMissing;
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
      _pushWorkspaceLog(
        '${AppStrings.workspaceProjectFilesReadPrefix} '
        '${items.length} '
        '${AppStrings.workspaceProjectFilesReadSuffix}',
      );
      await _openDefaultFileIfAvailable();
    } catch (error) {
      if (currentScan == _scanVersion) {
        errorMessage.value =
            '${AppStrings.workspaceProjectFilesReadFailedPrefix} $error';
        _pushWorkspaceLog(
          '${AppStrings.workspaceProjectFilesReadFailedPrefix} $error',
        );
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

    final readme =
        rootReadme ??
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
    dirtyFilePaths.clear();
    protectedFilePaths.clear();
    _savedFileContentByPath.clear();
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

class _TerminalShell {
  final String executable;
  final List<String> arguments = const [];

  const _TerminalShell({required this.executable});
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
