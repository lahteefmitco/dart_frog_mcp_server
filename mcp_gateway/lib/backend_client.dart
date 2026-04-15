import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:student_mcp_gateway/env_config.dart';
import 'package:student_mcp_gateway/json_logger.dart';

/// HTTP client for the student REST backend (no direct DB access).
class BackendClient {
  BackendClient({String? baseUrl}) : _base = baseUrl ?? requireBackendBaseUrl();

  final String _base;

  Uri _uri(String path, [Map<String, String>? query]) {
    final p = path.startsWith('/') ? path : '/$path';
    var u = Uri.parse('$_base$p');
    if (query != null && query.isNotEmpty) {
      u = u.replace(queryParameters: query);
    }
    return u;
  }

  Future<String> getStudentsJson({required String requestId}) async {
    final uri = _uri('/students');
    final sw = Stopwatch()..start();
    final resp = await http.get(uri, headers: {'x-request-id': requestId});
    sw.stop();
    JsonLogger.logBackendCall(
      requestId: requestId,
      method: 'GET',
      url: uri.toString(),
      statusCode: resp.statusCode,
      durationMs: sw.elapsedMilliseconds,
    );
    return resp.body;
  }

  Future<http.Response> forward({
    required String requestId,
    required String method,
    required String path,
    Map<String, String>? query,
    String? body,
  }) async {
    final uri = _uri(path, query);
    final req = http.Request(method, uri);
    req.headers['x-request-id'] = requestId;
    if (body != null && body.isNotEmpty) {
      req.body = body;
      req.headers['Content-Type'] = 'application/json';
    }
    final sw = Stopwatch()..start();
    final streamed = await http.Client().send(req);
    final resp = await http.Response.fromStream(streamed);
    sw.stop();
    JsonLogger.logBackendCall(
      requestId: requestId,
      method: method,
      url: uri.toString(),
      statusCode: resp.statusCode,
      durationMs: sw.elapsedMilliseconds,
    );
    return resp;
  }
}

/// Used from [bin/mcp_stdio.dart] (stdio MCP tools).
Future<String> fetchStudentsPlain(String requestId) async {
  final c = BackendClient();
  final body = await c.getStudentsJson(requestId: requestId);
  try {
    final decoded = jsonDecode(body);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return body;
  }
}

Future<String> createStudentMcp(
  String requestId,
  Map<String, dynamic> args,
) async {
  final c = BackendClient();
  final payload = jsonEncode({
    'name': args['name'],
    'age': args['age'],
    'class': args['class'],
  });
  final resp = await c.forward(
    requestId: requestId,
    method: 'POST',
    path: '/students',
    body: payload,
  );
  return '${resp.statusCode}\n${resp.body}';
}
