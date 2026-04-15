import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs requests, responses, and errors to the debug console.
class AppDioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buf = StringBuffer()
      ..writeln('[DIO][REQ] ${options.method} ${options.uri}')
      ..writeln('[DIO][REQ] headers: ${_redact(options.headers)}');
    if (options.data != null) {
      buf.writeln('[DIO][REQ] data: ${options.data}');
    }
    _log(buf.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _log(
      '[DIO][RES] ${response.statusCode} ${response.requestOptions.uri} '
      'len=${response.data is String ? (response.data as String).length : "?"}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '[DIO][ERR] ${err.requestOptions.uri} ${err.message}',
      name: 'Dio',
      error: err,
      stackTrace: err.stackTrace,
    );
    if (kDebugMode) {
      debugPrint('[DIO][ERR] type: ${err.type}');
      debugPrint('[DIO][ERR] response: ${err.response?.data}');
    }
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> h) {
    final m = Map<String, dynamic>.from(h);
    for (final k in m.keys.toList()) {
      if (k.toLowerCase().contains('auth')) {
        m[k] = '***';
      }
    }
    return m;
  }

  void _log(String message) {
    developer.log(message, name: 'Dio');
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
