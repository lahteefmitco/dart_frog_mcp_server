import 'package:postgres/postgres.dart';
import 'package:student_backend/env_config.dart';

/// Shared PostgreSQL connection (lazy singleton for dev / small deployments).
class Database {
  Database._();

  static Connection? _connection;
  static Future<Connection>? _opening;

  static Future<Connection> get connection async {
    if (_connection != null) return _connection!;
    _opening ??= _open();
    _connection = await _opening;
    return _connection!;
  }

  static Future<Connection> _open() async {
    final c = readEndpointConfig();
    return Connection.open(
      Endpoint(
        host: c.host,
        port: c.port,
        database: c.database,
        username: c.username,
        password: c.password,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }
}
