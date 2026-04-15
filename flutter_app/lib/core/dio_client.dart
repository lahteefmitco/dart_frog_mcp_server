import 'package:dio/dio.dart';
import 'package:student_app/core/app_config.dart';
import 'package:student_app/core/logging/app_dio_interceptor.dart';

Dio createDio() {
  final base = AppConfig.gatewayBaseUrl.endsWith('/')
      ? AppConfig.gatewayBaseUrl
      : '${AppConfig.gatewayBaseUrl}/';
  final dio = Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AppDioInterceptor());
  return dio;
}
