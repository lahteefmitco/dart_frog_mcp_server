import 'package:dotenv/dotenv.dart';

final DotEnv _env = DotEnv(includePlatformEnvironment: true, quiet: true);

bool _loaded = false;

void loadEnvOnce() {
  if (_loaded) return;
  _loaded = true;
  try {
    _env.load(const ['.env']);
  } catch (_) {
    // No .env file; [includePlatformEnvironment] still provides process env.
  }
}

EndpointConfig readEndpointConfig() {
  loadEnvOnce();
  final urlStr = _env['DATABASE_URL']?.trim();
  if (urlStr != null && urlStr.isNotEmpty) {
    final uri = Uri.parse(urlStr);
    final info = uri.userInfo;
    var user = 'postgres';
    var password = '';
    if (info.isNotEmpty) {
      final idx = info.indexOf(':');
      if (idx >= 0) {
        user = Uri.decodeComponent(info.substring(0, idx));
        password = Uri.decodeComponent(info.substring(idx + 1));
      } else {
        user = Uri.decodeComponent(info);
      }
    }
    final dbName =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'postgres';
    return EndpointConfig(
      host: uri.host.isEmpty ? 'localhost' : uri.host,
      port: uri.hasPort ? uri.port : 5432,
      database: dbName,
      username: user,
      password: password,
    );
  }

  return EndpointConfig(
    host: _env['DB_HOST'] ?? 'localhost',
    port: int.tryParse(_env['DB_PORT'] ?? '') ?? 5432,
    database: _env['DB_NAME'] ?? 'students',
    username: _env['DB_USER'] ?? 'postgres',
    password: _env['DB_PASSWORD'] ?? 'postgres',
  );
}

class EndpointConfig {
  const EndpointConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
  });

  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
}
