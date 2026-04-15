import 'dart:convert';
import 'dart:io';

class JsonLogger {
  const JsonLogger._();

  static const String component = 'student_mcp_gateway';

  static void _write(Map<String, Object?> fields) {
    stdout.writeln(jsonEncode({...fields, 'component': component}));
  }

  static void logRequest({
    required String requestId,
    required String method,
    required String path,
    Map<String, String>? query,
    String? payload,
  }) {
    _write({
      'level': 'info',
      'event': 'request_in',
      'requestId': requestId,
      'method': method,
      'path': path,
      if (query != null && query.isNotEmpty) 'query': query.toString(),
      if (payload != null) 'payload': payload,
    });
  }

  static void logResponse({
    required String requestId,
    required int statusCode,
    required int durationMs,
  }) {
    _write({
      'level': 'info',
      'event': 'response_out',
      'requestId': requestId,
      'statusCode': statusCode,
      'durationMs': durationMs,
    });
  }

  static void logBackendCall({
    required String requestId,
    required String method,
    required String url,
    required int statusCode,
    required int durationMs,
  }) {
    _write({
      'level': 'info',
      'event': 'backend_call',
      'requestId': requestId,
      'outMethod': method,
      'outUrl': url,
      'outStatus': statusCode,
      'outDurationMs': durationMs,
    });
  }

  static void logLlm({
    required String requestId,
    required String model,
    required int promptChars,
    required int responseChars,
    required int latencyMs,
  }) {
    _write({
      'level': 'info',
      'event': 'llm_call',
      'requestId': requestId,
      'model': model,
      'promptChars': promptChars,
      'responseChars': responseChars,
      'latencyMs': latencyMs,
    });
  }

  static void logError({
    required String requestId,
    required Object error,
    StackTrace? stackTrace,
  }) {
    _write({
      'level': 'error',
      'event': 'error',
      'requestId': requestId,
      'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    });
  }
}
