import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../../constants/app_colors.dart';
import '../../../data/services/app_settings_service.dart';
import '../../../data/services/engine_client_service.dart';

class TopBarController extends GetxController with WindowListener {
  final AppSettingsService settingsService = Get.find<AppSettingsService>();
  final EngineClientService engineClientService = Get.find<EngineClientService>();

  final isMaximized = false.obs;

  RxBool get isLocalModelEnabled => settingsService.localModelEnabled;

  String get engineStatusLabel {
    final status = engineClientService.engineStatus.value;
    if (status.isChecking) return 'فحص المحرك';
    return status.isOnline ? 'Engine Online' : 'Engine Offline';
  }

  Color get engineStatusColor {
    final status = engineClientService.engineStatus.value;
    if (status.isChecking) return AppColors.runtimeBusy;
    return status.isOnline ? AppColors.runtimeRunning : AppColors.runtimeError;
  }

  String get runtimeStageLabel {
    final stage = engineClientService.engineStatus.value.runtimeStage;
    if (stage.trim().isEmpty || stage == 'unknown') return 'Runtime: --';
    return 'Runtime: $stage';
  }

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

  Future<void> refreshEngineStatus() async {
    await engineClientService.refreshEngineStatus();
  }

  void minimizeWindow() {
    windowManager.minimize();
  }

  void closeWindow() {
    windowManager.close();
  }
}
