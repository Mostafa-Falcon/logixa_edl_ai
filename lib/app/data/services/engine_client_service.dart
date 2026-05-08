import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/engine_status_model.dart';

class EngineClientService extends GetxService {
  static const String defaultBaseUrl = 'http://127.0.0.1:8787';
  static const Duration _refreshInterval = Duration(seconds: 10);

  late final Dio _dio;
  Timer? _statusTimer;

  final engineStatus = EngineStatusModel.initial().obs;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: defaultBaseUrl,
        connectTimeout: const Duration(milliseconds: 900),
        receiveTimeout: const Duration(milliseconds: 1200),
        sendTimeout: const Duration(milliseconds: 1200),
        responseType: ResponseType.json,
      ),
    );

    refreshEngineStatus(silent: true);
    _statusTimer = Timer.periodic(_refreshInterval, (_) {
      refreshEngineStatus(silent: true);
    });
  }

  @override
  void onClose() {
    _statusTimer?.cancel();
    super.onClose();
  }

  Future<void> refreshEngineStatus({bool silent = false}) async {
    if (!silent) {
      engineStatus.value = engineStatus.value.copyWith(isChecking: true);
    }

    try {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>('/health'),
        _dio.get<Map<String, dynamic>>('/status'),
        _dio.get<Map<String, dynamic>>('/settings'),
        _dio.get<Map<String, dynamic>>('/runtime/status'),
      ]);

      final health = _asMap(responses[0].data);
      final status = _asMap(responses[1].data);
      final settings = _asMap(responses[2].data);
      final runtime = _asMap(responses[3].data);

      engineStatus.value = EngineStatusModel(
        isOnline: _asBool(health['ok'], fallback: true),
        isChecking: false,
        service: _asString(health['service'], fallback: 'logixa_engine'),
        version: _asString(health['version'], fallback: '-'),
        statusMessage: 'Rust Engine متصل',
        errorMessage: null,
        configPath: _asNullableString(
          status['config_path'] ?? health['config_path'],
        ),
        memoryDbPath: _asNullableString(status['memory_db_path']),
        uptimeSeconds: _asNullableInt(status['uptime_seconds']),
        engineRunning: _asBool(status['engine_running'], fallback: true),
        localModelEnabled: _asBool(
          status['local_model_enabled'] ?? settings['local_model_enabled'],
          fallback: false,
        ),
        modelLoaded: _asBool(
          runtime['model_loaded'] ?? status['model_loaded'],
          fallback: false,
        ),
        runtimeStage: _asString(runtime['stage'], fallback: 'unknown'),
        activeModelProfileId: _asNullableString(
          runtime['active_model_profile_id'] ??
              status['active_model_profile_id'] ??
              settings['active_model_profile_id'],
        ),
      );
    } catch (error) {
      engineStatus.value = EngineStatusModel.initial().copyWith(
        isChecking: false,
        statusMessage: 'Rust Engine غير متصل',
        errorMessage: _friendlyError(error),
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _asString(dynamic value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  String? _asNullableString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  int? _asNullableInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'انتهت مهلة الاتصال بـ Rust Engine.';
        case DioExceptionType.connectionError:
          return 'تعذر الاتصال بـ Rust Engine على $defaultBaseUrl.';
        default:
          return 'فشل فحص Rust Engine: ${error.message ?? error.type.name}';
      }
    }

    return 'فشل فحص Rust Engine.';
  }
}
