import 'package:flutter/material.dart';
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

      final result = await engineClientService.sendRuntimeChat(
        prompt: prompt,
        systemPrompt: settingsService.systemPrompt.value,
      );

      final assistantMessage = ChatMessageModel(
        id: _nextMessageId(),
        role: ChatMessageRole.assistant,
        content: result.displayText,
        createdAt: DateTime.now(),
        modelProfileId: result.activeModelProfileId ?? profile.id,
        runtimeStage: result.stage,
      );

      messages.add(assistantMessage);

      if (conversationId != null) {
        await _saveMessageToMemory(
          conversationId: conversationId,
          role: 'assistant',
          content: result.displayText,
          profile: profile,
          runtimeStage: result.stage,
          clientMessageId: assistantMessage.id,
        );
      }
    } finally {
      isSending.value = false;
      _scrollToBottom();
    }
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
      'client_message_id': clientMessageId,
      'source': 'flutter_chat_page',
      'step': 'step_15_auto_save_chat_to_rust_memory',
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
