import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/engine_status_model.dart';
import '../models/memory_dashboard_model.dart';
import '../models/model_profile_model.dart';

class EngineSyncResult {
  final bool engineOnline;
  final bool saved;
  final String message;

  const EngineSyncResult({
    required this.engineOnline,
    required this.saved,
    required this.message,
  });

  bool get fullySynced => engineOnline && saved;

  factory EngineSyncResult.offline(String message) {
    return EngineSyncResult(
      engineOnline: false,
      saved: false,
      message: message,
    );
  }

  factory EngineSyncResult.fromResponse(Map<String, dynamic> data) {
    return EngineSyncResult(
      engineOnline: true,
      saved: _asBool(data['saved'], fallback: true),
      message: _asString(data['message'], fallback: 'تمت مزامنة Rust Engine.'),
    );
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  static String _asString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }
}

class EngineRuntimeChatResult {
  final bool ok;
  final String message;
  final String stage;
  final String? activeModelProfileId;
  final bool systemPromptApplied;
  final int? systemPromptChars;
  final String? systemPromptPreview;

  const EngineRuntimeChatResult({
    required this.ok,
    required this.message,
    required this.stage,
    this.activeModelProfileId,
    required this.systemPromptApplied,
    this.systemPromptChars,
    this.systemPromptPreview,
  });

  String get displayText {
    if (!ok) return message;

    final lines = <String>[
      message,
      '',
      'runtime lifecycle is ready; actual GGUF execution adapter is not connected',
      'runtime_stage: $stage',
    ];

    if (activeModelProfileId != null) {
      lines.add('active_model_profile_id: $activeModelProfileId');
    }

    lines.add('system_prompt_applied: $systemPromptApplied');

    if (systemPromptChars != null) {
      lines.add('system_prompt_chars: $systemPromptChars');
    }

    if (systemPromptPreview != null && systemPromptPreview!.isNotEmpty) {
      lines.add('system_prompt_preview: $systemPromptPreview');
    }

    return lines.join('\n');
  }

  factory EngineRuntimeChatResult.offline(String message) {
    return EngineRuntimeChatResult(
      ok: false,
      message: message,
      stage: 'offline',
      systemPromptApplied: false,
    );
  }

  factory EngineRuntimeChatResult.fromResponse(Map<String, dynamic> data) {
    final runtime = _asMap(data['runtime']);
    final stage = _asString(
      data['stage'] ?? data['runtime_stage'] ?? runtime['stage'],
      fallback: 'completed',
    );
    final message = _asString(
      data['message'] ?? data['response'] ?? data['assistant_message'],
      fallback: 'Runtime lifecycle completed successfully.',
    );

    return EngineRuntimeChatResult(
      ok: _asBool(data['ok'] ?? data['success'], fallback: true),
      message: message,
      stage: stage,
      activeModelProfileId: _asNullableString(
        data['active_model_profile_id'] ?? runtime['active_model_profile_id'],
      ),
      systemPromptApplied: _asBool(
        data['system_prompt_applied'] ?? runtime['system_prompt_applied'],
        fallback: false,
      ),
      systemPromptChars: _asNullableInt(
        data['system_prompt_chars'] ?? runtime['system_prompt_chars'],
      ),
      systemPromptPreview: _asNullableString(
        data['system_prompt_preview'] ?? runtime['system_prompt_preview'],
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String _asString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static String? _asNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static int? _asNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }
}

class EngineProcessResult {
  final bool ok;
  final String message;

  const EngineProcessResult({required this.ok, required this.message});

  factory EngineProcessResult.ok(String message) {
    return EngineProcessResult(ok: true, message: message);
  }

  factory EngineProcessResult.failed(String message) {
    return EngineProcessResult(ok: false, message: message);
  }
}

class EngineMemoryConversationResult {
  final bool ok;
  final String message;
  final String? conversationId;

  const EngineMemoryConversationResult({
    required this.ok,
    required this.message,
    this.conversationId,
  });

  factory EngineMemoryConversationResult.failed(String message) {
    return EngineMemoryConversationResult(ok: false, message: message);
  }

  factory EngineMemoryConversationResult.fromResponse(
    Map<String, dynamic> data,
  ) {
    final ok = _asBool(data['ok'], fallback: true);
    if (!ok) {
      return EngineMemoryConversationResult.failed(
        _asString(data['error'], fallback: 'فشل إنشاء محادثة في Rust Memory.'),
      );
    }

    final payload = _asMap(data['data']);
    final id = _asNullableString(payload['id']);
    return EngineMemoryConversationResult(
      ok: id != null,
      conversationId: id,
      message: id == null
          ? 'Rust Memory لم يرجع conversation id.'
          : 'تم إنشاء محادثة في Rust Memory.',
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _asString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static String? _asNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }
}

class EngineMemoryMessageResult {
  final bool ok;
  final String message;
  final String? messageId;

  const EngineMemoryMessageResult({
    required this.ok,
    required this.message,
    this.messageId,
  });

  factory EngineMemoryMessageResult.failed(String message) {
    return EngineMemoryMessageResult(ok: false, message: message);
  }

  factory EngineMemoryMessageResult.fromResponse(Map<String, dynamic> data) {
    final ok = _asBool(data['ok'], fallback: true);
    if (!ok) {
      return EngineMemoryMessageResult.failed(
        _asString(data['error'], fallback: 'فشل حفظ رسالة في Rust Memory.'),
      );
    }

    final payload = _asMap(data['data']);
    final id = _asNullableString(payload['id']);
    return EngineMemoryMessageResult(
      ok: id != null,
      messageId: id,
      message: id == null
          ? 'Rust Memory لم يرجع message id.'
          : 'تم حفظ الرسالة في Rust Memory.',
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _asString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static String? _asNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }
}

class EngineWorkspaceSessionResult {
  final bool ok;
  final String message;
  final String? sessionId;

  const EngineWorkspaceSessionResult({
    required this.ok,
    required this.message,
    this.sessionId,
  });

  factory EngineWorkspaceSessionResult.failed(String message) {
    return EngineWorkspaceSessionResult(ok: false, message: message);
  }

  factory EngineWorkspaceSessionResult.fromResponse(Map<String, dynamic> data) {
    final ok = _asBool(data['ok'], fallback: true);
    if (!ok) {
      return EngineWorkspaceSessionResult.failed(
        _asString(
          data['error'],
          fallback: 'فشل حفظ جلسة مساحة العمل في Rust Memory.',
        ),
      );
    }

    final payload = _asMap(data['data']);
    final id = _asNullableString(payload['id']);
    return EngineWorkspaceSessionResult(
      ok: id != null,
      sessionId: id,
      message: id == null
          ? 'Rust Memory لم يرجع workspace session id.'
          : 'تم حفظ جلسة مساحة العمل في Rust Memory.',
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _asString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  static String? _asNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }
}

class EngineClientService extends GetxService {
  static const String defaultBaseUrl = 'http://127.0.0.1:8787';
  static const Duration _refreshInterval = Duration(seconds: 10);

  late final Dio _dio;
  Timer? _statusTimer;
  Process? _managedEngineProcess;

  final engineStatus = EngineStatusModel.initial().obs;
  final isStartingEngine = false.obs;
  final isStoppingEngine = false.obs;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: defaultBaseUrl,
        connectTimeout: const Duration(milliseconds: 900),
        receiveTimeout: const Duration(milliseconds: 1200),
        sendTimeout: const Duration(milliseconds: 1200),
        responseType: ResponseType.json,
      ),
    );

    refreshEngineStatus(silent: true);
    _statusTimer = Timer.periodic(_refreshInterval, (_) {
      refreshEngineStatus(silent: true);
    });
  }

  @override
  void onClose() {
    _statusTimer?.cancel();
    _managedEngineProcess?.kill(ProcessSignal.sigterm);
    _managedEngineProcess = null;
    super.onClose();
  }

  Future<EngineProcessResult> startLocalEngine() async {
    if (isStartingEngine.value) {
      return EngineProcessResult.ok('Rust Engine قيد التشغيل بالفعل.');
    }

    await refreshEngineStatus(silent: true);
    if (engineStatus.value.isOnline) {
      return EngineProcessResult.ok('Rust Engine متصل بالفعل.');
    }

    isStartingEngine.value = true;
    engineStatus.value = engineStatus.value.copyWith(
      isChecking: true,
      statusMessage: 'جاري تشغيل Rust Engine...',
      errorMessage: null,
    );

    try {
      final engineDir = Directory('${Directory.current.path}/logixa_engine');
      if (!engineDir.existsSync()) {
        return EngineProcessResult.failed(
          'لم أجد مجلد logixa_engine من مسار تشغيل التطبيق الحالي.',
        );
      }

      final buildResult = await Process.run(
        'cargo',
        ['build'],
        workingDirectory: engineDir.path,
        runInShell: false,
      );

      if (buildResult.exitCode != 0) {
        final stderrText = buildResult.stderr.toString().trim();
        final message = stderrText.isEmpty
            ? 'فشل بناء Rust Engine قبل التشغيل.'
            : stderrText;
        return EngineProcessResult.failed(message);
      }

      final binaryName = Platform.isWindows
          ? 'logixa_engine.exe'
          : 'logixa_engine';
      final binaryFile = File('${engineDir.path}/target/debug/$binaryName');
      if (!binaryFile.existsSync()) {
        return EngineProcessResult.failed(
          'لم أجد ملف تشغيل Rust Engine بعد cargo build.',
        );
      }

      final process = await Process.start(
        binaryFile.path,
        const [],
        workingDirectory: engineDir.path,
        runInShell: false,
      );

      _managedEngineProcess = process;
      process.stdout.listen((_) {});
      process.stderr.listen((_) {});
      process.exitCode.then((_) {
        if (_managedEngineProcess?.pid == process.pid) {
          _managedEngineProcess = null;
          refreshEngineStatus(silent: true);
        }
      });

      for (var attempt = 0; attempt < 30; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await refreshEngineStatus(silent: true);
        if (engineStatus.value.isOnline) {
          return EngineProcessResult.ok('Rust Engine اشتغل من الشريط العلوي.');
        }
      }

      return EngineProcessResult.failed(
        'Rust Engine لم يرد على /health بعد محاولة التشغيل.',
      );
    } catch (error) {
      return EngineProcessResult.failed('فشل تشغيل Rust Engine: $error');
    } finally {
      isStartingEngine.value = false;
      await refreshEngineStatus(silent: true);
    }
  }

  Future<EngineProcessResult> stopLocalEngine() async {
    if (isStoppingEngine.value) {
      return EngineProcessResult.ok('Rust Engine قيد الإيقاف بالفعل.');
    }

    isStoppingEngine.value = true;
    engineStatus.value = engineStatus.value.copyWith(
      isChecking: true,
      statusMessage: 'جاري إيقاف Rust Engine...',
      errorMessage: null,
    );

    try {
      await _terminateManagedProcess();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await refreshEngineStatus(silent: true);

      if (engineStatus.value.isOnline) {
        await _terminateEngineByPortFallback();
      }

      for (var attempt = 0; attempt < 12; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await refreshEngineStatus(silent: true);
        if (!engineStatus.value.isOnline) {
          return EngineProcessResult.ok('Rust Engine اتوقف من الشريط العلوي.');
        }
      }

      return EngineProcessResult.failed(
        'Rust Engine ما زال متصلًا. اقفل العملية يدويًا من النظام لو كانت بدأت خارج التطبيق.',
      );
    } catch (error) {
      return EngineProcessResult.failed('فشل إيقاف Rust Engine: $error');
    } finally {
      isStoppingEngine.value = false;
      await refreshEngineStatus(silent: true);
    }
  }

  Future<void> stopManagedEngine() async {
    await stopLocalEngine();
  }

  Future<void> _terminateManagedProcess() async {
    final process = _managedEngineProcess;
    _managedEngineProcess = null;
    if (process == null) return;

    process.kill(ProcessSignal.sigterm);
    try {
      await process.exitCode.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
    }
  }

  Future<void> _terminateEngineByPortFallback() async {
    if (!Platform.isLinux && !Platform.isMacOS) return;

    const script = r'''
PIDS="$(lsof -ti tcp:8787 2>/dev/null || true)"
if [ -n "$PIDS" ]; then
  kill -TERM $PIDS 2>/dev/null || true
  sleep 0.4
fi

if command -v fuser >/dev/null 2>&1; then
  fuser -k 8787/tcp >/dev/null 2>&1 || true
fi

pkill -TERM -f 'target/debug/logixa_engine' >/dev/null 2>&1 || true
''';

    await Process.run('bash', ['-lc', script], runInShell: false);
  }

  Future<void> refreshEngineStatus({bool silent = false}) async {
    if (!silent) {
      engineStatus.value = engineStatus.value.copyWith(isChecking: true);
    }

    try {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>('/health'),
        _dio.get<Map<String, dynamic>>('/status'),
        _dio.get<Map<String, dynamic>>('/settings'),
        _dio.get<Map<String, dynamic>>('/runtime/status'),
      ]);

      final health = _asMap(responses[0].data);
      final status = _asMap(responses[1].data);
      final settings = _asMap(responses[2].data);
      final runtime = _asMap(responses[3].data);

      engineStatus.value = EngineStatusModel(
        isOnline: _asBool(health['ok'], fallback: true),
        isChecking: false,
        service: _asString(health['service'], fallback: 'logixa_engine'),
        version: _asString(health['version'], fallback: '-'),
        statusMessage: 'Rust Engine متصل',
        errorMessage: null,
        configPath: _asNullableString(
          status['config_path'] ?? health['config_path'],
        ),
        memoryDbPath: _asNullableString(status['memory_db_path']),
        uptimeSeconds: _asNullableInt(status['uptime_seconds']),
        engineRunning: _asBool(status['engine_running'], fallback: true),
        localModelEnabled: _asBool(
          status['local_model_enabled'] ?? settings['local_model_enabled'],
          fallback: false,
        ),
        modelLoaded: _asBool(
          runtime['model_loaded'] ?? status['model_loaded'],
          fallback: false,
        ),
        runtimeStage: _asString(runtime['stage'], fallback: 'unknown'),
        activeModelProfileId: _asNullableString(
          runtime['active_model_profile_id'] ??
              status['active_model_profile_id'] ??
              settings['active_model_profile_id'],
        ),
      );
    } catch (error) {
      engineStatus.value = EngineStatusModel.initial().copyWith(
        isChecking: false,
        statusMessage: 'Rust Engine غير متصل',
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<EngineSyncResult> syncRuntimeProfile({
    required ModelProfileModel profile,
    required bool localModelEnabled,
    required bool autoStartOnMessage,
    required bool allowBackgroundModel,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/runtime/profile',
        data: {
          'local_model_enabled': localModelEnabled,
          'auto_start_on_message': autoStartOnMessage,
          'keep_model_loaded': profile.keepModelLoaded,
          'unload_after_response': profile.unloadAfterResponse,
          'allow_background_model': allowBackgroundModel,
          'model_profile': profile.toJson(),
        },
      );

      await refreshEngineStatus(silent: true);
      return EngineSyncResult.fromResponse(_asMap(response.data));
    } catch (error) {
      await refreshEngineStatus(silent: true);
      return EngineSyncResult.offline(_friendlyError(error));
    }
  }

  Future<EngineSyncResult> syncSystemPrompt(String systemPrompt) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/runtime/system-prompt',
        data: {'system_prompt': systemPrompt},
      );

      await refreshEngineStatus(silent: true);
      return EngineSyncResult.fromResponse(_asMap(response.data));
    } catch (error) {
      await refreshEngineStatus(silent: true);
      return EngineSyncResult.offline(_friendlyError(error));
    }
  }

  Future<EngineRuntimeChatResult> sendRuntimeChat({
    required String prompt,
    required String systemPrompt,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/runtime/chat',
        data: {'prompt': prompt, 'system_prompt': systemPrompt},
      );
      await refreshEngineStatus(silent: true);
      return EngineRuntimeChatResult.fromResponse(_asMap(response.data));
    } catch (error) {
      await refreshEngineStatus(silent: true);
      return EngineRuntimeChatResult.offline(_friendlyError(error));
    }
  }

  Future<EngineMemoryConversationResult> createMemoryConversation({
    required String title,
    required String? workspacePath,
    required String? modelProfileId,
    required String systemPrompt,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/memory/conversations',
        data: {
          'title': title,
          'workspace_path': workspacePath,
          'model_profile_id': modelProfileId,
          'system_prompt': systemPrompt,
        },
      );

      await refreshEngineStatus(silent: true);
      return EngineMemoryConversationResult.fromResponse(_asMap(response.data));
    } catch (error) {
      await refreshEngineStatus(silent: true);
      return EngineMemoryConversationResult.failed(_friendlyError(error));
    }
  }

  Future<EngineMemoryMessageResult> createMemoryMessage({
    required String conversationId,
    required String role,
    required String content,
    required String? modelProfileId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/memory/messages',
        data: {
          'conversation_id': conversationId,
          'role': role,
          'content': content,
          'model_profile_id': modelProfileId,
          'metadata': metadata,
        },
      );

      await refreshEngineStatus(silent: true);
      return EngineMemoryMessageResult.fromResponse(_asMap(response.data));
    } catch (error) {
      await refreshEngineStatus(silent: true);
      return EngineMemoryMessageResult.failed(_friendlyError(error));
    }
  }

  Future<EngineWorkspaceSessionResult> createMemoryWorkspaceSession({
    required String workspacePath,
    required String? workspaceName,
    required String? activeFile,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/memory/workspace-sessions',
        data: {
          'workspace_path': workspacePath,
          'workspace_name': workspaceName,
          'active_file': activeFile,
          'metadata': metadata,
        },
      );

      await refreshEngineStatus(silent: true);
      return EngineWorkspaceSessionResult.fromResponse(_asMap(response.data));
    } catch (error) {
      await refreshEngineStatus(silent: true);
      return EngineWorkspaceSessionResult.failed(_friendlyError(error));
    }
  }

  Future<EngineMemoryDashboardResult> fetchMemoryDashboard({
    String? preferredConversationId,
  }) async {
    try {
      final statusResponse = await _dio.get<Map<String, dynamic>>(
        '/memory/status',
      );
      final conversationsResponse = await _dio.get<Map<String, dynamic>>(
        '/memory/conversations',
      );
      final itemsResponse = await _dio.get<Map<String, dynamic>>(
        '/memory/items',
      );
      final expertsResponse = await _dio.get<Map<String, dynamic>>(
        '/memory/experts',
      );
      final workspaceSessionsResponse = await _dio.get<Map<String, dynamic>>(
        '/memory/workspace-sessions',
      );
      final selectedProfileResponse = await _dio.get<Map<String, dynamic>>(
        '/memory/selected-model-profile',
      );

      final conversations = _extractDataList(
        conversationsResponse.data,
      ).map(MemoryConversationSummary.fromJson).toList(growable: false);

      final conversationId = _resolveConversationId(
        preferredConversationId,
        conversations,
      );
      final messages = conversationId == null
          ? <MemoryMessageSummary>[]
          : await _fetchConversationMessages(conversationId);

      final snapshot = MemoryDashboardSnapshot(
        status: MemoryStatusSummary.fromJson(
          _extractDataMap(statusResponse.data),
        ),
        conversations: conversations,
        messages: messages,
        memoryItems: _extractDataList(
          itemsResponse.data,
        ).map(MemoryItemSummary.fromJson).toList(growable: false),
        experts: _extractDataList(
          expertsResponse.data,
        ).map(MemoryExpertSummary.fromJson).toList(growable: false),
        workspaceSessions: _extractDataList(
          workspaceSessionsResponse.data,
        ).map(MemoryWorkspaceSessionSummary.fromJson).toList(growable: false),
        selectedModelProfile: SelectedModelProfileSnapshot.fromJson(
          _extractDataMap(selectedProfileResponse.data),
        ),
      );

      await refreshEngineStatus(silent: true);
      return EngineMemoryDashboardResult.success(snapshot);
    } catch (error) {
      await refreshEngineStatus(silent: true);
      return EngineMemoryDashboardResult.failed(_friendlyError(error));
    }
  }

  Future<List<MemoryMessageSummary>> _fetchConversationMessages(
    String conversationId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/memory/messages',
      queryParameters: {'conversation_id': conversationId},
    );

    return _extractDataList(
      response.data,
    ).map(MemoryMessageSummary.fromJson).toList(growable: false);
  }

  String? _resolveConversationId(
    String? preferredConversationId,
    List<MemoryConversationSummary> conversations,
  ) {
    if (conversations.isEmpty) return null;

    final preferred = preferredConversationId?.trim();
    if (preferred != null && preferred.isNotEmpty) {
      for (final conversation in conversations) {
        if (conversation.id == preferred) return preferred;
      }
    }

    return conversations.first.id;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _asString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String? _asNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  int? _asNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  Map<String, dynamic> _extractDataMap(dynamic value) {
    final root = _asMap(value);
    final data = root['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractDataList(dynamic value) {
    final root = _asMap(value);
    final data = root['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'انتهت مهلة الاتصال بـ Rust Engine.';
        case DioExceptionType.connectionError:
          return 'تعذر الاتصال بـ Rust Engine على $defaultBaseUrl.';
        default:
          return 'فشل فحص Rust Engine: ${error.message ?? error.type.name}';
      }
    }

    return 'فشل فحص Rust Engine.';
  }
}
