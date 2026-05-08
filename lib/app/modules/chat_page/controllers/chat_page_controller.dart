import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_strings.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/models/model_profile_model.dart';
import '../../../data/services/app_settings_service.dart';
import '../../../data/services/engine_client_service.dart';

class ChatPageController extends GetxController {
  final AppSettingsService settingsService = Get.find<AppSettingsService>();
  final EngineClientService engineClientService =
      Get.find<EngineClientService>();

  final TextEditingController inputController = TextEditingController();
  final ScrollController messagesScrollController = ScrollController();

  final messages = <ChatMessageModel>[].obs;
  final isSending = false.obs;

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
    messages.add(
      ChatMessageModel(
        id: _nextMessageId(),
        role: ChatMessageRole.user,
        content: prompt,
        createdAt: DateTime.now(),
        modelProfileId: profile.id,
      ),
    );
    _scrollToBottom();

    isSending.value = true;
    try {
      await _syncActiveProfile(profile);

      final result = await engineClientService.sendRuntimeChat(
        prompt: prompt,
        systemPrompt: settingsService.systemPrompt.value,
      );

      messages.add(
        ChatMessageModel(
          id: _nextMessageId(),
          role: ChatMessageRole.assistant,
          content: result.displayText,
          createdAt: DateTime.now(),
          modelProfileId: result.activeModelProfileId ?? profile.id,
          runtimeStage: result.stage,
        ),
      );
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
