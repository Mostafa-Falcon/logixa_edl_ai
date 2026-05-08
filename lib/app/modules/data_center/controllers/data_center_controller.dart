import 'package:get/get.dart';

import '../../../data/models/memory_dashboard_model.dart';
import '../../../data/services/engine_client_service.dart';

class DataCenterController extends GetxController {
  final EngineClientService engineClientService =
      Get.find<EngineClientService>();

  final snapshot = MemoryDashboardSnapshot.empty().obs;
  final selectedConversationId = ''.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    refreshMemoryDashboard();
  }

  Future<void> refreshMemoryDashboard() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await engineClientService.fetchMemoryDashboard(
        preferredConversationId: selectedConversationId.value,
      );

      if (!result.ok) {
        snapshot.value = MemoryDashboardSnapshot.empty();
        selectedConversationId.value = '';
        errorMessage.value = result.message;
        return;
      }

      final nextSnapshot = result.snapshot;
      snapshot.value = nextSnapshot;
      selectedConversationId.value = _resolveSelectedConversationId(
        nextSnapshot,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectConversation(String conversationId) async {
    if (conversationId.trim().isEmpty) return;
    selectedConversationId.value = conversationId;
    await refreshMemoryDashboard();
  }

  MemoryConversationSummary? get selectedConversation {
    final selectedId = selectedConversationId.value;
    if (selectedId.isEmpty) return null;

    for (final conversation in snapshot.value.conversations) {
      if (conversation.id == selectedId) return conversation;
    }

    return null;
  }

  bool isConversationSelected(String conversationId) {
    return selectedConversationId.value == conversationId;
  }

  String compactPath(String? path) {
    if (path == null || path.trim().isEmpty) return '--';
    final cleanPath = path.trim();
    if (cleanPath.length <= 42) return cleanPath;
    return '...${cleanPath.substring(cleanPath.length - 39)}';
  }

  String compactText(String value, {int maxChars = 120}) {
    final normalized = value.split(RegExp(r'\s+')).join(' ').trim();
    if (normalized.length <= maxChars) return normalized;
    return '${normalized.substring(0, maxChars)}...';
  }

  String formatEpoch(int? epochSeconds) {
    if (epochSeconds == null || epochSeconds <= 0) return '--';

    final date = DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: false,
    );

    return '${_two(date.hour)}:${_two(date.minute)}  ${_two(date.day)}/${_two(date.month)}/${date.year}';
  }

  String _resolveSelectedConversationId(MemoryDashboardSnapshot nextSnapshot) {
    final conversations = nextSnapshot.conversations;
    if (conversations.isEmpty) return '';

    final current = selectedConversationId.value;
    if (current.isNotEmpty) {
      for (final conversation in conversations) {
        if (conversation.id == current) return current;
      }
    }

    return conversations.first.id;
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
