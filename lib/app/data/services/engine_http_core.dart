import 'package:dio/dio.dart';

/// Shared HTTP/Dio configuration for the local Logixa Rust Engine.
///
/// Step 25.2 keeps [EngineClientService] as the public facade and extracts
/// only the low-level HTTP setup so future clients can reuse it without
/// changing current runtime behavior.
class EngineHttpCore {
  final String baseUrl;

  const EngineHttpCore({required this.baseUrl});

  Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 900),
        receiveTimeout: const Duration(milliseconds: 1200),
        sendTimeout: const Duration(milliseconds: 1200),
        responseType: ResponseType.json,
      ),
    );
  }
}
