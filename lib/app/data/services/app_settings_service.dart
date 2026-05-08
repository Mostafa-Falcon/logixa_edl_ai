import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/model_profile_model.dart';

class AppSettingsService extends GetxService {
  static const String defaultSystemPrompt = '';

  static const String _localModelEnabledKey = 'local_model_enabled';
  static const String _activeModelProfileKey = 'active_model_profile';
  static const String _modelProfilesKey = 'model_profiles';
  static const String _activeModelProfileIdKey = 'active_model_profile_id';
  static const String _autoStartOnMessageKey = 'auto_start_on_message';
  static const String _allowBackgroundModelKey = 'allow_background_model';
  static const String _systemPromptKey = 'active_system_prompt';

  final GetStorage _storage = GetStorage();

  final localModelEnabled = true.obs;
  final autoStartOnMessage = true.obs;
  final allowBackgroundModel = false.obs;
  final systemPrompt = ''.obs;
  final activeModelProfile = ModelProfileModel.defaultLocal().obs;
  final modelProfiles = <ModelProfileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    localModelEnabled.value = _storage.read(_localModelEnabledKey) ?? true;
    autoStartOnMessage.value = _storage.read(_autoStartOnMessageKey) ?? true;
    allowBackgroundModel.value =
        _storage.read(_allowBackgroundModelKey) ?? false;
    systemPrompt.value = _readSystemPrompt(_storage.read(_systemPromptKey));

    final profiles = _readStoredProfiles();
    final activeId = _storage.read(_activeModelProfileIdKey);
    _setProfilesState(
      profiles: profiles,
      activeId: activeId is String ? activeId : null,
      shouldPersist: false,
    );
  }

  List<ModelProfileModel> _readStoredProfiles() {
    final storedProfiles = _storage.read(_modelProfilesKey);

    if (storedProfiles is List) {
      final profiles = storedProfiles
          .whereType<Map>()
          .map(
            (item) => _sanitizeLegacyModelPath(
              ModelProfileModel.fromJson(Map<String, dynamic>.from(item)),
            ),
          )
          .toList();

      if (profiles.isNotEmpty) return profiles;
    }

    final legacyProfile = _storage.read(_activeModelProfileKey);
    if (legacyProfile is Map) {
      return [
        _sanitizeLegacyModelPath(
          ModelProfileModel.fromJson(
            Map<String, dynamic>.from(legacyProfile),
          ).copyWith(isActive: true),
        ),
      ];
    }

    return [ModelProfileModel.defaultLocal()];
  }

  Future<void> setLocalModelEnabled(bool value) async {
    localModelEnabled.value = value;
    await _storage.write(_localModelEnabledKey, value);
  }

  Future<void> setAutoStartOnMessage(bool value) async {
    autoStartOnMessage.value = value;
    await _storage.write(_autoStartOnMessageKey, value);
  }

  Future<void> setAllowBackgroundModel(bool value) async {
    allowBackgroundModel.value = value;
    await _storage.write(_allowBackgroundModelKey, value);
  }

  Future<void> setSystemPrompt(String value) async {
    final normalized = _readSystemPrompt(value);
    systemPrompt.value = normalized;
    await _storage.write(_systemPromptKey, normalized);
  }

  Future<void> resetSystemPrompt() async {
    systemPrompt.value = '';
    await _storage.write(_systemPromptKey, '');
  }

  String _readSystemPrompt(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return '';
  }

  Future<void> addModelProfile(ModelProfileModel profile) async {
    final nextProfiles = [
      ...modelProfiles.map((item) => item.copyWith(isActive: false)),
      profile.copyWith(isActive: true),
    ];

    await _setProfilesState(
      profiles: nextProfiles,
      activeId: profile.id,
      shouldPersist: true,
    );
  }

  Future<void> setActiveModelProfile(String profileId) async {
    await _setProfilesState(
      profiles: modelProfiles.toList(),
      activeId: profileId,
      shouldPersist: true,
    );
  }

  Future<void> saveActiveModelProfile(ModelProfileModel profile) async {
    final activeProfile = profile.copyWith(isActive: true);
    final existingIndex = modelProfiles.indexWhere(
      (item) => item.id == activeProfile.id,
    );

    final nextProfiles = modelProfiles
        .map((item) => item.copyWith(isActive: false))
        .toList();

    if (existingIndex == -1) {
      nextProfiles.add(activeProfile);
    } else {
      nextProfiles[existingIndex] = activeProfile;
    }

    await _setProfilesState(
      profiles: nextProfiles,
      activeId: activeProfile.id,
      shouldPersist: true,
    );
  }

  Future<bool> deleteModelProfile(String profileId) async {
    if (modelProfiles.length <= 1) return false;

    final nextProfiles = modelProfiles
        .where((item) => item.id != profileId)
        .toList();
    final activeId = activeModelProfile.value.id == profileId
        ? nextProfiles.first.id
        : activeModelProfile.value.id;

    await _setProfilesState(
      profiles: nextProfiles,
      activeId: activeId,
      shouldPersist: true,
    );

    return true;
  }

  Future<void> _setProfilesState({
    required List<ModelProfileModel> profiles,
    required String? activeId,
    required bool shouldPersist,
  }) async {
    final sanitizedProfiles = _sanitizeProfiles(profiles);
    final resolvedActiveId = _resolveActiveId(sanitizedProfiles, activeId);

    final nextProfiles = sanitizedProfiles
        .map(
          (profile) =>
              profile.copyWith(isActive: profile.id == resolvedActiveId),
        )
        .toList(growable: false);

    modelProfiles.assignAll(nextProfiles);
    activeModelProfile.value = nextProfiles.firstWhere(
      (profile) => profile.id == resolvedActiveId,
      orElse: () => nextProfiles.first,
    );

    if (!shouldPersist) return;

    await _persistProfiles();
  }

  List<ModelProfileModel> _sanitizeProfiles(List<ModelProfileModel> profiles) {
    final uniqueProfiles = <String, ModelProfileModel>{};

    for (final profile in profiles) {
      final safeProfile = _sanitizeLegacyModelPath(profile);
      uniqueProfiles[safeProfile.id] = safeProfile;
    }

    if (uniqueProfiles.isEmpty) {
      uniqueProfiles[ModelProfileModel.defaultLocal().id] =
          ModelProfileModel.defaultLocal();
    }

    return uniqueProfiles.values.toList(growable: false);
  }

  String _resolveActiveId(
    List<ModelProfileModel> profiles,
    String? preferredId,
  ) {
    if (preferredId != null &&
        profiles.any((profile) => profile.id == preferredId)) {
      return preferredId;
    }

    final markedActive = profiles.where((profile) => profile.isActive).toList();
    if (markedActive.isNotEmpty) return markedActive.first.id;

    return profiles.first.id;
  }

  ModelProfileModel _sanitizeLegacyModelPath(ModelProfileModel profile) {
    final trimmedPath = profile.modelPath.trim();
    if (trimmedPath.isEmpty) return profile.copyWith(modelPath: '');

    final normalizedPath = trimmedPath.replaceAll('\\', '/');
    final isOldBundledPresetPath =
        normalizedPath ==
            'models/gemma3_abliterated_v2/gemma-3-4b-it-abliterated-v2.q4_k_m.gguf' ||
        normalizedPath ==
            'models/gemma3_abliterated_v2/gemma-3-12b-it-abliterated-v2.q4_k_m.gguf';

    if (isOldBundledPresetPath) {
      return profile.copyWith(modelPath: '');
    }

    return profile.copyWith(modelPath: trimmedPath);
  }

  Future<void> _persistProfiles() async {
    final profilesJson = modelProfiles
        .map((profile) => profile.toJson())
        .toList(growable: false);

    await _storage.write(_modelProfilesKey, profilesJson);
    await _storage.write(_activeModelProfileIdKey, activeModelProfile.value.id);
    await _storage.write(
      _activeModelProfileKey,
      activeModelProfile.value.toJson(),
    );
  }
}
