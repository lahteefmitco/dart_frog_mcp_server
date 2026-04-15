import 'package:dotenv/dotenv.dart';

final DotEnv _env = DotEnv(includePlatformEnvironment: true, quiet: true);

bool _loaded = false;

void loadEnvOnce() {
  if (_loaded) return;
  _loaded = true;
  try {
    _env.load(const ['.env']);
  } catch (_) {}
}

String requireBackendBaseUrl() {
  loadEnvOnce();
  final v = _env['BACKEND_BASE_URL']?.trim();
  if (v == null || v.isEmpty) {
    throw StateError('BACKEND_BASE_URL is not set');
  }
  return v.endsWith('/') ? v.substring(0, v.length - 1) : v;
}

String? mistralApiKey() {
  loadEnvOnce();
  final k = _env['MISTRAL_API_KEY']?.trim();
  return k == null || k.isEmpty ? null : k;
}

String mistralModel() {
  loadEnvOnce();
  return _env['MISTRAL_MODEL']?.trim().isNotEmpty == true
      ? _env['MISTRAL_MODEL']!.trim()
      : 'mistral-small-latest';
}
