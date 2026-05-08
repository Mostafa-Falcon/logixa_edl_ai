import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/memory_dashboard_model.dart';
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
  final conversations = <MemoryConversationSummary>[].obs;
  final selectedConversationId = ''.obs;
  final isSending = false.obs;
  final isStreaming = false.obs;
  final isLoadingConversations = false.obs;
  final isDeletingConversation = false.obs;
  final conversationErrorMessage = RxnString();

  String? _conversationId;
  bool _memoryWarningShown = false;

  @override
  void onInit() {
    super.onInit();
    _resetCurrentConversationMessages();
    refreshConversationSessions(silent: true);
  }

  @override
  void onClose() {
    inputController.dispose();
    messagesScrollController.dispose();
    super.onClose();
  }

  ModelProfileModel get activeProfile =>
      settingsService.activeModelProfile.value;

  Future<void> refreshConversationSessions({bool silent = false}) async {
    if (isLoadingConversations.value) return;

    isLoadingConversations.value = true;
    if (!silent) conversationErrorMessage.value = null;

    try {
      final result = await engineClientService.fetchMemoryDashboard(
        preferredConversationId: _conversationId,
      );

      if (!result.ok) {
        if (!silent) conversationErrorMessage.value = result.message;
        return;
      }

      conversations.assignAll(result.snapshot.conversations);
      _syncSelectedConversationMarker();
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> openConversation(String conversationId) async {
    final cleanConversationId = conversationId.trim();
    if (cleanConversationId.isEmpty || isLoadingConversations.value) return;

    isLoadingConversations.value = true;
    conversationErrorMessage.value = null;

    try {
      final result = await engineClientService.fetchMemoryDashboard(
        preferredConversationId: cleanConversationId,
      );

      if (!result.ok) {
        _showSnackBar(
          AppStrings.chatSessionOpenFailed,
          result.message,
        );
        return;
      }

      conversations.assignAll(result.snapshot.conversations);
      _conversationId = cleanConversationId;
      selectedConversationId.value = cleanConversationId;
      _memoryWarningShown = false;
      _loadMemoryMessages(result.snapshot.messages);
    } finally {
      isLoadingConversations.value = false;
    }
  }

  void startNewConversation() {
    _conversationId = null;
    selectedConversationId.value = '';
    _memoryWarningShown = false;
    _resetCurrentConversationMessages();
  }

  Future<void> confirmDeleteConversation(
    MemoryConversationSummary conversation,
  ) async {
    final conversationId = conversation.id.trim();
    if (conversationId.isEmpty || isDeletingConversation.value) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          AppStrings.chatSessionDeleteTitle,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          AppStrings.chatSessionDeleteMessage,
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.chatSessionDeleteCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text(AppStrings.chatSessionDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await deleteConversation(conversationId);
  }

  Future<void> deleteConversation(String conversationId) async {
    final cleanConversationId = conversationId.trim();
    if (cleanConversationId.isEmpty || isDeletingConversation.value) return;

    isDeletingConversation.value = true;
    try {
      final result = await engineClientService.deleteMemoryConversation(
        cleanConversationId,
      );

      if (!result.ok) {
        _showSnackBar(
          AppStrings.chatSessionDeleteFailedTitle,
          result.message,
        );
        return;
      }

      conversations.removeWhere(
        (conversation) => conversation.id == cleanConversationId,
      );

      if (_conversationId == cleanConversationId) {
        startNewConversation();
      } else {
        _syncSelectedConversationMarker();
      }

      await refreshConversationSessions(silent: true);

      _showSnackBar(
        AppStrings.chatSessionDeletedTitle,
        AppStrings.chatSessionDeletedMessage,
      );
    } finally {
      isDeletingConversation.value = false;
    }
  }

  bool isConversationSelected(String conversationId) {
    return selectedConversationId.value == conversationId;
  }

  String conversationTimeLabel(MemoryConversationSummary conversation) {
    return _formatEpoch(conversation.updatedAt);
  }

  String conversationSubtitle(MemoryConversationSummary conversation) {
    final workspacePath = conversation.workspacePath?.trim();
    if (workspacePath != null && workspacePath.isNotEmpty) {
      return _compactText(workspacePath, maxChars: 42);
    }

    final profileId = conversation.modelProfileId?.trim();
    if (profileId != null && profileId.isNotEmpty) {
      return profileId;
    }

    return 'بدون Workspace';
  }

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
      final streamedReasoningText = StringBuffer();
      final result = await engineClientService.sendRuntimeChatStream(
        prompt: prompt,
        systemPrompt: settingsService.systemPrompt.value,
        onChunk: (chunk) {
          var shouldRefreshBubble = false;
          var nextStage = 'streaming';

          if (chunk.isReasoningToken && chunk.reasoningDelta != null) {
            streamedReasoningText.write(chunk.reasoningDelta);
            shouldRefreshBubble = true;
            nextStage = 'thinking';
          }

          if (chunk.isToken && chunk.delta != null) {
            streamedText.write(chunk.delta);
            shouldRefreshBubble = true;
            nextStage = 'streaming';
          }

          if (shouldRefreshBubble) {
            _replaceChatMessage(
              id: assistantMessageId,
              role: ChatMessageRole.assistant,
              content: _visibleAssistantContent(
                streamedText.toString(),
                hasReasoning: streamedReasoningText.toString().trim().isNotEmpty,
              ),
              createdAt: assistantCreatedAt,
              modelProfileId: chunk.activeModelProfileId ?? profile.id,
              runtimeStage: nextStage,
              reasoningContent: _cleanOptionalText(
                streamedReasoningText.toString(),
              ),
            );
            _scrollToBottom();
          }

          if (chunk.isError) {
            _replaceChatMessage(
              id: assistantMessageId,
              role: ChatMessageRole.assistant,
              content: chunk
                  .toResult(
                    streamedText: streamedText.toString(),
                    streamedReasoningText: streamedReasoningText.toString(),
                  )
                  .displayText,
              createdAt: assistantCreatedAt,
              modelProfileId: chunk.activeModelProfileId ?? profile.id,
              runtimeStage: chunk.stage,
              reasoningContent: _cleanOptionalText(
                streamedReasoningText.toString(),
              ),
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
      final assistantReasoning = _cleanOptionalText(
        result.reasoningText ?? streamedReasoningText.toString(),
      );

      _replaceChatMessage(
        id: assistantMessageId,
        role: ChatMessageRole.assistant,
        content: assistantContent,
        createdAt: assistantCreatedAt,
        modelProfileId: result.activeModelProfileId ?? profile.id,
        runtimeStage: result.stage,
        reasoningContent: assistantReasoning,
      );

      if (conversationId != null && result.ok) {
        await _saveMessageToMemory(
          conversationId: conversationId,
          role: 'assistant',
          content: assistantContent,
          profile: profile,
          runtimeStage: result.stage,
          clientMessageId: assistantMessageId,
          reasoningContent: assistantReasoning,
        );
        await refreshConversationSessions(silent: true);
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
        ..writeln(message.content.trim());

      final reasoningContent = _cleanOptionalText(message.reasoningContent);
      if (reasoningContent != null) {
        buffer
          ..writeln('reasoning_content:')
          ..writeln(reasoningContent);
      }

      buffer.writeln('---');
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
    String? reasoningContent,
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
      reasoningContent: reasoningContent,
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
    selectedConversationId.value = result.conversationId ?? '';
    await refreshConversationSessions(silent: true);
    return result.conversationId;
  }

  Future<void> _saveMessageToMemory({
    required String conversationId,
    required String role,
    required String content,
    required ModelProfileModel profile,
    required String runtimeStage,
    required String clientMessageId,
    String? reasoningContent,
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
        reasoningContent: reasoningContent,
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
    String? reasoningContent,
  }) {
    final metadata = <String, dynamic>{
      'workspace_path': _activeWorkspacePath(),
      'active_model_profile_id': profile.id,
      'system_prompt_preview': _previewText(settingsService.systemPrompt.value),
      'runtime_stage': runtimeStage,
      'runtime_source': 'rust_llama_server_adapter',
      'client_message_id': clientMessageId,
      'source': 'flutter_chat_page',
      'step': 'step_26_chat_sessions_sidebar',
      'local_model_enabled': settingsService.localModelEnabled.value,
      'auto_start_on_message': settingsService.autoStartOnMessage.value,
      'allow_background_model': settingsService.allowBackgroundModel.value,
    };

    final cleanReasoning = _cleanOptionalText(reasoningContent);
    if (cleanReasoning != null) {
      metadata['reasoning_content'] = cleanReasoning;
    }

    return metadata;
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

  void _loadMemoryMessages(List<MemoryMessageSummary> memoryMessages) {
    if (memoryMessages.isEmpty) {
      _resetCurrentConversationMessages();
      return;
    }

    final sortedMessages = [...memoryMessages]
      ..sort((first, second) => first.createdAt.compareTo(second.createdAt));

    messages.assignAll(
      sortedMessages.map(_chatMessageFromMemory).toList(growable: false),
    );

    _scrollToBottom();
  }

  ChatMessageModel _chatMessageFromMemory(MemoryMessageSummary message) {
    return ChatMessageModel(
      id: message.id.isEmpty ? _nextMessageId() : message.id,
      role: _roleFromMemory(message.role),
      content: message.content,
      createdAt: _dateTimeFromEpoch(message.createdAt),
      modelProfileId: message.modelProfileId,
      runtimeStage: _runtimeStageFromMetadata(message.metadata),
      reasoningContent: _reasoningFromMetadata(message.metadata),
    );
  }

  ChatMessageRole _roleFromMemory(String role) {
    switch (role.trim().toLowerCase()) {
      case 'user':
        return ChatMessageRole.user;
      case 'assistant':
      case 'model':
        return ChatMessageRole.assistant;
      case 'system':
      default:
        return ChatMessageRole.system;
    }
  }

  String? _runtimeStageFromMetadata(Map<String, dynamic>? metadata) {
    final value = metadata?['runtime_stage'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  String? _reasoningFromMetadata(Map<String, dynamic>? metadata) {
    final value = metadata?['reasoning_content'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  String _visibleAssistantContent(String visibleText, {required bool hasReasoning}) {
    final cleanVisibleText = visibleText.trim();
    if (cleanVisibleText.isNotEmpty) return cleanVisibleText;
    if (hasReasoning) return AppStrings.chatThinkingStreamingPlaceholder;
    return AppStrings.chatStreamingPlaceholder;
  }

  String? _cleanOptionalText(String? value) {
    final clean = value?.trim();
    if (clean == null || clean.isEmpty) return null;
    return clean;
  }

  void _resetCurrentConversationMessages() {
    messages.clear();
  }

  void _syncSelectedConversationMarker() {
    final currentConversationId = _conversationId?.trim();
    if (currentConversationId == null || currentConversationId.isEmpty) {
      selectedConversationId.value = '';
      return;
    }

    final stillExists = conversations.any(
      (conversation) => conversation.id == currentConversationId,
    );

    selectedConversationId.value = stillExists ? currentConversationId : '';
  }

  DateTime _dateTimeFromEpoch(int epochSeconds) {
    if (epochSeconds <= 0) return DateTime.now();
    return DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
  }

  String _formatEpoch(int epochSeconds) {
    if (epochSeconds <= 0) return '--';

    final date = _dateTimeFromEpoch(epochSeconds);
    return '${_two(date.hour)}:${_two(date.minute)}  ${_two(date.day)}/${_two(date.month)}';
  }

  String _compactText(String value, {required int maxChars}) {
    final normalized = value.split(RegExp(r'\s+')).join(' ').trim();
    if (normalized.length <= maxChars) return normalized;
    return '...${normalized.substring(normalized.length - maxChars)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void _showSnackBar(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
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
