import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../../data/services/app_settings_service.dart';

class TopBarController extends GetxController with WindowListener {
  final AppSettingsService settingsService = Get.find<AppSettingsService>();

  final isMaximized = false.obs;

  RxBool get isLocalModelEnabled => settingsService.localModelEnabled;

  @override
  void onInit() {
    super.onInit();
    windowManager.addListener(this);
    _loadWindowState();
  }

  @override
  void onClose() {
    windowManager.removeListener(this);
    super.onClose();
  }

  Future<void> _loadWindowState() async {
    isMaximized.value = await windowManager.isMaximized();
  }

  @override
  void onWindowMaximize() {
    isMaximized.value = true;
  }

  @override
  void onWindowUnmaximize() {
    isMaximized.value = false;
  }

  Future<void> toggleMaximize() async {
    final currentlyMaximized = await windowManager.isMaximized();
    if (currentlyMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
    isMaximized.value = await windowManager.isMaximized();
  }

  Future<void> toggleLocalModelMode() async {
    await settingsService.setLocalModelEnabled(!settingsService.localModelEnabled.value);
  }

  void minimizeWindow() {
    windowManager.minimize();
  }

  void closeWindow() {
    windowManager.close();
  }
}
