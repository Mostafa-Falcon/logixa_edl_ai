import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../constants/app_strings.dart';
import '../../../data/models/model_profile_model.dart';
import '../../../data/services/app_settings_service.dart';

class SettingsController extends GetxController {
  final AppSettingsService settingsService = Get.find<AppSettingsService>();

  final selectedSectionIndex = 2.obs;
  final isPickingModel = false.obs;
  final isSaving = false.obs;

  final TextEditingController modelNameController = TextEditingController();
  final TextEditingController modelPathController = TextEditingController();
  final TextEditingController contextSizeController = TextEditingController();
  final TextEditingController threadsController = TextEditingController();
  final TextEditingController batchSizeController = TextEditingController();
  final TextEditingController maxTokensController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController topPController = TextEditingController();
  final TextEditingController topKController = TextEditingController();
  final TextEditingController systemPromptController = TextEditingController();

  final Uuid _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    _syncControllersFromProfile(settingsService.activeModelProfile.value);
    systemPromptController.text = settingsService.systemPrompt.value;
  }

  @override
  void onClose() {
    modelNameController.dispose();
    modelPathController.dispose();
    contextSizeController.dispose();
    threadsController.dispose();
    batchSizeController.dispose();
    maxTokensController.dispose();
    temperatureController.dispose();
    topPController.dispose();
    topKController.dispose();
    systemPromptController.dispose();
    super.onClose();
  }

  Future<void> createModelProfile() async {
    final profileNumber = settingsService.modelProfiles.length + 1;
    final newProfile = ModelProfileModel.defaultLocal().copyWith(
      id: _uuid.v4(),
      name: '${AppStrings.newModelProfileName} $profileNumber',
      isActive: true,
    );

    await settingsService.addModelProfile(newProfile);
    _syncControllersFromProfile(newProfile);
    _showSuccess(AppStrings.modelProfileCreated);
  }

  Future<void> selectModelProfile(String profileId) async {
    await settingsService.setActiveModelProfile(profileId);
    _syncControllersFromProfile(settingsService.activeModelProfile.value);
    systemPromptController.text = settingsService.systemPrompt.value;
    _showSuccess(AppStrings.modelProfileSelected);
  }

  Future<void> deleteModelProfile(String profileId) async {
    final deleted = await settingsService.deleteModelProfile(profileId);

    if (!deleted) {
      _showError(AppStrings.cannotDeleteLastModelProfile);
      return;
    }

    _syncControllersFromProfile(settingsService.activeModelProfile.value);
    systemPromptController.text = settingsService.systemPrompt.value;
    _showSuccess(AppStrings.modelProfileDeleted);
  }

  Future<void> pickLocalModelFile() async {
    if (isPickingModel.value) return;

    isPickingModel.value = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: AppStrings.chooseLocalModelFile,
        type: FileType.custom,
        allowedExtensions: const ['gguf'],
        allowMultiple: false,
      );

      final selectedPath = result?.files.single.path;
      if (selectedPath == null || selectedPath.trim().isEmpty) return;

      final normalizedPath = _normalizePath(selectedPath);
      modelPathController.text = normalizedPath;

      if (modelNameController.text.trim().isEmpty ||
          modelNameController.text.trim() ==
              ModelProfileModel.defaultLocal().name ||
          modelNameController.text.trim().startsWith(
            AppStrings.newModelProfileName,
          )) {
        modelNameController.text = path.basenameWithoutExtension(
          normalizedPath,
        );
      }

      await saveLocalModelSettings(showSuccessMessage: false);
    } finally {
      isPickingModel.value = false;
    }
  }

  Future<void> setLocalModelEnabled(bool value) async {
    await settingsService.setLocalModelEnabled(value);
  }

  Future<void> setAutoStartOnMessage(bool value) async {
    await settingsService.setAutoStartOnMessage(value);
  }

  Future<void> setAllowBackgroundModel(bool value) async {
    await settingsService.setAllowBackgroundModel(value);
  }

  Future<void> setKeepModelLoaded(bool value) async {
    final current = settingsService.activeModelProfile.value;
    await settingsService.saveActiveModelProfile(
      current.copyWith(keepModelLoaded: value, unloadAfterResponse: !value),
    );
  }

  Future<void> setUnloadAfterResponse(bool value) async {
    final current = settingsService.activeModelProfile.value;
    await settingsService.saveActiveModelProfile(
      current.copyWith(unloadAfterResponse: value, keepModelLoaded: !value),
    );
  }


  Future<void> saveSystemPrompt({bool showSuccessMessage = true}) async {
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      await settingsService.setSystemPrompt(systemPromptController.text);
      systemPromptController.text = settingsService.systemPrompt.value;

      if (showSuccessMessage) {
        _showSuccess(AppStrings.systemPromptSaved);
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> resetSystemPrompt() async {
    await settingsService.resetSystemPrompt();
    systemPromptController.text = settingsService.systemPrompt.value;
    _showSuccess(AppStrings.systemPromptReset);
  }

  Future<void> saveLocalModelSettings({bool showSuccessMessage = true}) async {
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      final current = settingsService.activeModelProfile.value;
      final profile = current.copyWith(
        name: _safeText(
          modelNameController.text,
          ModelProfileModel.defaultLocal().name,
        ),
        modelPath: modelPathController.text.trim(),
        contextSize: _safeInt(
          contextSizeController.text,
          current.contextSize,
          min: 256,
        ),
        threads: _safeInt(threadsController.text, current.threads, min: 1),
        batchSize: _safeInt(
          batchSizeController.text,
          current.batchSize,
          min: 1,
        ),
        maxTokens: _safeInt(
          maxTokensController.text,
          current.maxTokens,
          min: 1,
        ),
        temperature: _safeDouble(
          temperatureController.text,
          current.temperature,
          min: 0,
          max: 2,
        ),
        topP: _safeDouble(topPController.text, current.topP, min: 0.01, max: 1),
        topK: _safeInt(topKController.text, current.topK, min: 1),
        isActive: true,
      );

      await settingsService.saveActiveModelProfile(profile);

      if (showSuccessMessage) {
        _showSuccess(AppStrings.localModelSettingsSaved);
      }
    } finally {
      isSaving.value = false;
    }
  }

  void _syncControllersFromProfile(ModelProfileModel profile) {
    modelNameController.text = profile.name;
    modelPathController.text = profile.modelPath;
    contextSizeController.text = profile.contextSize.toString();
    threadsController.text = profile.threads.toString();
    batchSizeController.text = profile.batchSize.toString();
    maxTokensController.text = profile.maxTokens.toString();
    temperatureController.text = profile.temperature.toString();
    topPController.text = profile.topP.toString();
    topKController.text = profile.topK.toString();
  }

  void _showSuccess(String message) {
    Get.snackbar(
      AppStrings.doneTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      AppStrings.errorTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
    );
  }

  String _safeText(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  int _safeInt(String value, int fallback, {required int min}) {
    final parsed = int.tryParse(value.trim()) ?? fallback;
    if (parsed < min) return min;
    return parsed;
  }

  double _safeDouble(
    String value,
    double fallback, {
    required double min,
    required double max,
  }) {
    final parsed = double.tryParse(value.trim()) ?? fallback;
    if (parsed < min) return min;
    if (parsed > max) return max;
    return parsed;
  }

  String _normalizePath(String value) {
    final expanded = value.trim().replaceFirst(
      RegExp(r'^~(?=/|\\)'),
      Platform.environment['HOME'] ?? '~',
    );
    return path.normalize(path.absolute(expanded));
  }
}
