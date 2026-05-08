import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../../constants/app_colors.dart';
import '../../../data/services/app_settings_service.dart';
import '../../../data/services/engine_client_service.dart';

class TopBarController extends GetxController with WindowListener {
  final AppSettingsService settingsService = Get.find<AppSettingsService>();
  final EngineClientService engineClientService =
      Get.find<EngineClientService>();

  final isMaximized = false.obs;
  bool _isClosing = false;

  RxBool get isLocalModelEnabled => settingsService.localModelEnabled;

  String get engineStatusLabel {
    final status = engineClientService.engineStatus.value;
    if (engineClientService.isStartingEngine.value) return 'تشغيل المحرك';
    if (engineClientService.isStoppingEngine.value) return 'إيقاف المحرك';
    if (status.isChecking) return 'فحص المحرك';
    return status.isOnline ? 'المحرك متصل' : 'المحرك غير متصل';
  }

  Color get engineStatusColor {
    final status = engineClientService.engineStatus.value;
    if (engineClientService.isStartingEngine.value ||
        engineClientService.isStoppingEngine.value ||
        status.isChecking) {
      return AppColors.runtimeBusy;
    }
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

  @override
  void onWindowClose() {
    _closeApp();
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
    await settingsService.setLocalModelEnabled(
      !settingsService.localModelEnabled.value,
    );
  }

  Future<void> refreshEngineStatus() async {
    await engineClientService.refreshEngineStatus();
  }

  Future<void> toggleRustEngine() async {
    final status = engineClientService.engineStatus.value;
    final busy =
        engineClientService.isStartingEngine.value ||
        engineClientService.isStoppingEngine.value ||
        status.isChecking;

    if (busy) return;

    final result = status.isOnline
        ? await engineClientService.stopLocalEngine()
        : await engineClientService.startLocalEngine();

    if (!result.ok) {
      Get.snackbar(
        'Rust Engine',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorSoft,
        colorText: AppColors.textPrimary,
      );
    }
  }

  void minimizeWindow() {
    windowManager.minimize();
  }

  Future<void> closeWindow() async {
    await _closeApp();
  }

  Future<void> _closeApp() async {
    if (_isClosing) return;
    _isClosing = true;

    await engineClientService.stopLocalEngine();
    await windowManager.destroy();
  }
}
