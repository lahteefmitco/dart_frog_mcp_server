import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:student_mcp_gateway/backend_client.dart';
import 'package:student_mcp_gateway/env_config.dart';
import 'package:student_mcp_gateway/json_logger.dart';
import 'package:student_mcp_gateway/mistral_service.dart';
import 'package:student_mcp_gateway/request_id_tag.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final rid = context.read<RequestIdTag>().value;

  late final BackendClient client;
  try {
    client = BackendClient();
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'message': 'Configuration error',
        'details': e.toString(),
      },
    );
  }

  if (mistralApiKey() == null) {
    return Response.json(
      statusCode: 503,
      body: {
        'message': 'Mistral is not configured',
        'details': 'Set MISTRAL_API_KEY in .env or environment',
      },
    );
  }

  final raw = await context.request.body();
  Map<String, dynamic>? map;
  try {
    final d = jsonDecode(raw);
    map = d is Map<String, dynamic> ? d : null;
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {
        'message': 'Invalid JSON',
        'details': e.toString(),
      },
    );
  }

  final q = map?['query'] as String? ?? '';
  if (q.trim().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'message': 'Missing query',
        'details': 'Provide { "query": "your question" }',
      },
    );
  }

  try {
    final studentsJson = await client.getStudentsJson(requestId: rid);
    final answer = await runMistralStudentQuery(
      requestId: rid,
      userQuery: q.trim(),
      studentsContextJson: studentsJson,
    );
    return Response.json(
      body: {
        'answer': answer,
        'requestId': rid,
      },
    );
  } catch (e, st) {
    JsonLogger.logError(requestId: rid, error: e, stackTrace: st);
    return Response.json(
      statusCode: 502,
      body: {
        'message': 'Assistant request failed',
        'details': e.toString(),
        'requestId': rid,
      },
    );
  }
}
