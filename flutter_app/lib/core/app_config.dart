/// MCP gateway base URL (Dart Frog). Override at build time:
/// `flutter run --dart-define=GATEWAY_BASE_URL=http://10.0.2.2:8081`
class AppConfig {
  AppConfig._();

  static const String gatewayBaseUrl = String.fromEnvironment(
    'GATEWAY_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );
}
