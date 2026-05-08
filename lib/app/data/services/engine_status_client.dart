import 'package:dio/dio.dart';

import '../models/engine_status_model.dart';

/// Reads Rust Engine health/status snapshots.
///
/// Step 25.3 keeps [EngineClientService] as the public facade and moves only
/// status polling/parsing into this focused client. Runtime, memory, settings
/// sync, and process management stay in EngineClientService for later steps.
class EngineStatusClient {
  final Dio dio;
  final String defaultBaseUrl;

  const EngineStatusClient({required this.dio, required this.defaultBaseUrl});

  Future<EngineStatusModel> fetchStatus() async {
    try {
      final responses = await Future.wait([
        dio.get<Map<String, dynamic>>('/health'),
        dio.get<Map<String, dynamic>>('/status'),
        dio.get<Map<String, dynamic>>('/settings'),
        dio.get<Map<String, dynamic>>('/runtime/status'),
      ]);

      final health = _asMap(responses[0].data);
      final status = _asMap(responses[1].data);
      final settings = _asMap(responses[2].data);
      final runtime = _asMap(responses[3].data);

      return EngineStatusModel(
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
      return EngineStatusModel.initial().copyWith(
        isChecking: false,
        statusMessage: 'Rust Engine غير متصل',
        errorMessage: _friendlyError(error),
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
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
