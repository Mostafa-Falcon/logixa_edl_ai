import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../constants/app_strings.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/model_profile_model.dart';
import '../../../data/models/workspace_model.dart';
import '../../../data/services/app_settings_service.dart';
import '../../../data/services/engine_client_service.dart';

class ChatPageController extends GetxController {
  static const String _activeWorkspaceStorageKey = 'active_workspace';

  final AppSettingsService settingsService = Get.find<AppSettingsService>();
  final EngineClientService engineClientService =
      Get.find<EngineClientService>();
  final GetStorage _storage = GetStorage();

  final TextEditingController inputController = TextEditingController();
  final ScrollController messagesScrollController = ScrollController();

  final messages = <ChatMessageModel>[].obs;
  final isSending = false.obs;
  final isStreaming = false.obs;

  String? _conversationId;
  bool _memoryWarningShown = false;

  @override
  void onInit() {
    super.onInit();
    messages.add(
      ChatMessageModel(
        id: _nextMessageId(),
        role: ChatMessageRole.system,
        content: AppStrings.chatWelcomeMessage,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  void onClose() {
    inputController.dispose();
    messagesScrollController.dispose();
    super.onClose();
  }

  ModelProfileModel get activeProfile =>
      settingsService.activeModelProfile.value;

  Future<void> sendMessage() async {
    if (isSending.value) return;

    final prompt = inputController.text.trim();
    if (prompt.isEmpty) return;

    inputController.clear();

    final profile = activeProfile;
    final userMessage = ChatMessageModel(
      id: _nextMessageId(),
      role: ChatMessageRole.user,
      content: prompt,
      createdAt: DateTime.now(),
      modelProfileId: profile.id,
      runtimeStage: 'before_runtime_chat',
    );

    messages.add(userMessage);
    _scrollToBottom();

    isSending.value = true;
    isStreaming.value = true;
    try {
      await _syncActiveProfile(profile);

      final conversationId = await _ensureMemoryConversation(
        profile: profile,
        firstPrompt: prompt,
      );

      if (conversationId != null) {
        await _saveMessageToMemory(
          conversationId: conversationId,
          role: 'user',
          content: prompt,
          profile: profile,
          runtimeStage: 'before_runtime_chat',
          clientMessageId: userMessage.id,
        );
      }

      final assistantMessageId = _nextMessageId();
      final assistantCreatedAt = DateTime.now();
      messages.add(
        ChatMessageModel(
          id: assistantMessageId,
          role: ChatMessageRole.assistant,
          content: AppStrings.chatStreamingPlaceholder,
          createdAt: assistantCreatedAt,
          modelProfileId: profile.id,
          runtimeStage: 'streaming',
        ),
      );
      _scrollToBottom();

      final streamedText = StringBuffer();
      final result = await engineClientService.sendRuntimeChatStream(
        prompt: prompt,
        systemPrompt: settingsService.systemPrompt.value,
        onChunk: (chunk) {
          if (chunk.isToken && chunk.delta != null) {
            streamedText.write(chunk.delta);
            _replaceChatMessage(
              id: assistantMessageId,
              role: ChatMessageRole.assistant,
              content: streamedText.toString(),
              createdAt: assistantCreatedAt,
              modelProfileId: chunk.activeModelProfileId ?? profile.id,
              runtimeStage: 'streaming',
            );
            _scrollToBottom();
          }

          if (chunk.isError) {
            _replaceChatMessage(
              id: assistantMessageId,
              role: ChatMessageRole.assistant,
              content: chunk
                  .toResult(streamedText: streamedText.toString())
                  .displayText,
              createdAt: assistantCreatedAt,
              modelProfileId: chunk.activeModelProfileId ?? profile.id,
              runtimeStage: chunk.stage,
            );
          }
        },
      );

      final assistantContent =
          result.ok &&
              result.generatedText != null &&
              result.generatedText!.trim().isNotEmpty
          ? result.generatedText!.trim()
          : result.displayText;

      _replaceChatMessage(
        id: assistantMessageId,
        role: ChatMessageRole.assistant,
        content: assistantContent,
        createdAt: assistantCreatedAt,
        modelProfileId: result.activeModelProfileId ?? profile.id,
        runtimeStage: result.stage,
      );

      if (conversationId != null && result.ok) {
        await _saveMessageToMemory(
          conversationId: conversationId,
          role: 'assistant',
          content: assistantContent,
          profile: profile,
          runtimeStage: result.stage,
          clientMessageId: assistantMessageId,
        );
      }
    } finally {
      isSending.value = false;
      isStreaming.value = false;
      _scrollToBottom();
    }
  }

  bool get hasCopyableConversation {
    return messages.any((message) {
      final isWelcome =
          message.role == ChatMessageRole.system &&
          message.content == AppStrings.chatWelcomeMessage;
      return !isWelcome && message.content.trim().isNotEmpty;
    });
  }

  Future<void> copyConversationToClipboard() async {
    final transcript = _conversationExportText();

    if (transcript.trim().isEmpty) {
      Get.snackbar(
        AppStrings.chatCopyConversationEmptyTitle,
        AppStrings.chatCopyConversationEmptyMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: transcript));

    Get.snackbar(
      AppStrings.chatCopyConversationCopiedTitle,
      AppStrings.chatCopyConversationCopiedMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _conversationExportText() {
    final exportMessages = messages
        .where((message) {
          final isWelcome =
              message.role == ChatMessageRole.system &&
              message.content == AppStrings.chatWelcomeMessage;
          return !isWelcome && message.content.trim().isNotEmpty;
        })
        .toList(growable: false);

    if (exportMessages.isEmpty) return '';

    final systemPrompt = settingsService.systemPrompt.value.trim();
    final buffer = StringBuffer()
      ..writeln(AppStrings.chatConversationExportTitle)
      ..writeln('exported_at: ${DateTime.now().toIso8601String()}')
      ..writeln('active_model_profile_id: ${activeProfile.id}')
      ..writeln('active_model_profile_name: ${activeProfile.name}')
      ..writeln('runtime_source: rust_llama_server_adapter')
      ..writeln(
        'local_model_enabled: ${settingsService.localModelEnabled.value}',
      )
      ..writeln(
        'auto_start_on_message: ${settingsService.autoStartOnMessage.value}',
      )
      ..writeln(
        'allow_background_model: ${settingsService.allowBackgroundModel.value}',
      )
      ..writeln('system_prompt_saved: ${systemPrompt.isNotEmpty}')
      ..writeln('system_prompt_chars: ${systemPrompt.runes.length}')
      ..writeln('---');

    for (final message in exportMessages) {
      buffer
        ..writeln(
          '[${message.createdAt.toIso8601String()}] ${_exportRoleLabel(message.role)}',
        )
        ..writeln('message_id: ${message.id}');

      final runtimeStage = message.runtimeStage;
      if (runtimeStage != null && runtimeStage.trim().isNotEmpty) {
        buffer.writeln('runtime_stage: $runtimeStage');
      }

      final modelProfileId = message.modelProfileId;
      if (modelProfileId != null && modelProfileId.trim().isNotEmpty) {
        buffer.writeln('model_profile_id: $modelProfileId');
      }

      buffer
        ..writeln('content:')
        ..writeln(message.content.trim())
        ..writeln('---');
    }

    return buffer.toString().trimRight();
  }

  String _exportRoleLabel(ChatMessageRole role) {
    switch (role) {
      case ChatMessageRole.user:
        return 'user';
      case ChatMessageRole.assistant:
        return 'assistant';
      case ChatMessageRole.system:
        return 'system';
    }
  }

  Future<void> stopGeneration() async {
    if (!isStreaming.value) return;
    await engineClientService.stopRuntimeGeneration();
    isSending.value = false;
    isStreaming.value = false;
  }

  void _replaceChatMessage({
    required String id,
    required ChatMessageRole role,
    required String content,
    required DateTime createdAt,
    String? modelProfileId,
    String? runtimeStage,
  }) {
    final index = messages.indexWhere((message) => message.id == id);
    if (index < 0) return;

    messages[index] = ChatMessageModel(
      id: id,
      role: role,
      content: content,
      createdAt: createdAt,
      modelProfileId: modelProfileId,
      runtimeStage: runtimeStage,
    );
  }

  Future<void> _syncActiveProfile(ModelProfileModel profile) async {
    await engineClientService.syncRuntimeProfile(
      profile: profile,
      localModelEnabled: settingsService.localModelEnabled.value,
      autoStartOnMessage: settingsService.autoStartOnMessage.value,
      allowBackgroundModel: settingsService.allowBackgroundModel.value,
    );
  }

  Future<String?> _ensureMemoryConversation({
    required ModelProfileModel profile,
    required String firstPrompt,
  }) async {
    final currentConversationId = _conversationId;
    if (currentConversationId != null) return currentConversationId;

    final result = await engineClientService.createMemoryConversation(
      title: _conversationTitle(firstPrompt),
      workspacePath: _activeWorkspacePath(),
      modelProfileId: profile.id,
      systemPrompt: settingsService.systemPrompt.value,
    );

    if (!result.ok || result.conversationId == null) {
      _showMemoryWarning(result.message);
      return null;
    }

    _conversationId = result.conversationId;
    return result.conversationId;
  }

  Future<void> _saveMessageToMemory({
    required String conversationId,
    required String role,
    required String content,
    required ModelProfileModel profile,
    required String runtimeStage,
    required String clientMessageId,
  }) async {
    final result = await engineClientService.createMemoryMessage(
      conversationId: conversationId,
      role: role,
      content: content,
      modelProfileId: profile.id,
      metadata: _messageMetadata(
        profile: profile,
        runtimeStage: runtimeStage,
        clientMessageId: clientMessageId,
      ),
    );

    if (!result.ok) {
      _showMemoryWarning(result.message);
    }
  }

  Map<String, dynamic> _messageMetadata({
    required ModelProfileModel profile,
    required String runtimeStage,
    required String clientMessageId,
  }) {
    return {
      'workspace_path': _activeWorkspacePath(),
      'active_model_profile_id': profile.id,
      'system_prompt_preview': _previewText(settingsService.systemPrompt.value),
      'runtime_stage': runtimeStage,
      'runtime_source': 'rust_llama_server_adapter',
      'client_message_id': clientMessageId,
      'source': 'flutter_chat_page',
      'step': 'step_24_runtime_chat_response_ux',
      'local_model_enabled': settingsService.localModelEnabled.value,
      'auto_start_on_message': settingsService.autoStartOnMessage.value,
      'allow_background_model': settingsService.allowBackgroundModel.value,
    };
  }

  String? _activeWorkspacePath() {
    final stored = _storage.read(_activeWorkspaceStorageKey);
    if (stored is! Map) return null;

    final workspace = WorkspaceModel.fromJson(
      Map<String, dynamic>.from(stored),
    );
    final workspacePath = workspace.path.trim();
    if (workspacePath.isEmpty) return null;
    return workspacePath;
  }

  String _conversationTitle(String prompt) {
    final normalized = prompt.split(RegExp(r'\s+')).join(' ').trim();
    if (normalized.isEmpty) return 'محادثة جديدة';

    final chars = _takeRunes(normalized, 64);
    if (normalized.runes.length <= 64) return chars;
    return '$chars...';
  }

  String _previewText(String value) {
    final normalized = value.split(RegExp(r'\s+')).join(' ').trim();
    if (normalized.isEmpty) return '';

    final chars = _takeRunes(normalized, 160);
    if (normalized.runes.length <= 160) return chars;
    return '$chars...';
  }

  String _takeRunes(String value, int maxRunes) {
    final buffer = StringBuffer();
    var count = 0;

    for (final rune in value.runes) {
      if (count >= maxRunes) break;
      buffer.writeCharCode(rune);
      count++;
    }

    return buffer.toString();
  }

  void _showMemoryWarning(String message) {
    if (_memoryWarningShown) return;
    _memoryWarningShown = true;

    messages.add(
      ChatMessageModel(
        id: _nextMessageId(),
        role: ChatMessageRole.system,
        content: '${AppStrings.chatMemorySaveWarning}\n$message',
        createdAt: DateTime.now(),
      ),
    );
  }

  void _scrollToBottom() {
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!messagesScrollController.hasClients) return;
      messagesScrollController.animateTo(
        messagesScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _nextMessageId() => DateTime.now().microsecondsSinceEpoch.toString();
}
