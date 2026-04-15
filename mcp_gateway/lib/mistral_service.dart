import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:student_mcp_gateway/env_config.dart';
import 'package:student_mcp_gateway/json_logger.dart';

/// Calls Mistral chat completions to answer questions about students.
Future<String> runMistralStudentQuery({
  required String requestId,
  required String userQuery,
  required String studentsContextJson,
}) async {
  final key = mistralApiKey();
  if (key == null) {
    throw StateError('MISTRAL_API_KEY is not set');
  }
  final model = mistralModel();
  final system =
      'You are a helpful assistant for a student management system. '
      'Answer using the JSON student list provided. If data is missing, say so. '
      'Be concise.\n\nStudent data (JSON):\n$studentsContextJson';

  final bodyMap = {
    'model': model,
    'messages': [
      {'role': 'system', 'content': system},
      {'role': 'user', 'content': userQuery},
    ],
    'temperature': 0.3,
  };
  final bodyStr = jsonEncode(bodyMap);
  final promptChars = system.length + userQuery.length;

  final sw = Stopwatch()..start();
  final resp = await http.post(
    Uri.parse('https://api.mistral.ai/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
    },
    body: bodyStr,
  );
  sw.stop();

  final decoded = jsonDecode(resp.body);
  String text;
  if (decoded is Map<String, dynamic> &&
      decoded['choices'] is List &&
      (decoded['choices'] as List).isNotEmpty) {
    final choice = (decoded['choices'] as List).first as Map<String, dynamic>;
    final msg = choice['message'] as Map<String, dynamic>?;
    text = msg?['content'] as String? ?? resp.body;
  } else {
    text = 'Mistral error (${resp.statusCode}): ${resp.body}';
  }

  JsonLogger.logLlm(
    requestId: requestId,
    model: model,
    promptChars: promptChars,
    responseChars: text.length,
    latencyMs: sw.elapsedMilliseconds,
  );

  if (resp.statusCode >= 400) {
    throw StateError(text);
  }

  return text;
}
