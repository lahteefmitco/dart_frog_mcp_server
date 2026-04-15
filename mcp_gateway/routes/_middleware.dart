import 'package:dart_frog/dart_frog.dart';
import 'package:student_mcp_gateway/env_config.dart';
import 'package:student_mcp_gateway/json_logger.dart';
import 'package:student_mcp_gateway/request_id_tag.dart';
import 'package:uuid/uuid.dart';

const _requestIdHeader = 'x-request-id';
final _uuid = const Uuid();

Handler middleware(Handler handler) {
  return (context) async {
    loadEnvOnce();

    final incoming = context.request.headers[_requestIdHeader];
    final requestId =
        incoming != null && incoming.isNotEmpty ? incoming : _uuid.v4();

    final ctx = context.provide(() => RequestIdTag(requestId));

    final method = ctx.request.method.value;
    final path = ctx.request.uri.path;
    final query = ctx.request.uri.queryParameters;

    String? payload;
    if (method != 'GET' && method != 'HEAD' && method != 'DELETE') {
      try {
        payload = await ctx.request.body();
      } catch (_) {
        payload = null;
      }
    }

    JsonLogger.logRequest(
      requestId: requestId,
      method: method,
      path: path,
      query: query.isEmpty ? null : Map<String, String>.from(query),
      payload: payload,
    );

    final sw = Stopwatch()..start();
    try {
      final response = await handler(ctx);
      sw.stop();
      JsonLogger.logResponse(
        requestId: requestId,
        statusCode: response.statusCode,
        durationMs: sw.elapsedMilliseconds,
      );
      return response.copyWith(
        headers: {
          ...response.headers,
          _requestIdHeader: requestId,
        },
      );
    } catch (e, st) {
      sw.stop();
      JsonLogger.logError(requestId: requestId, error: e, stackTrace: st);
      JsonLogger.logResponse(
        requestId: requestId,
        statusCode: 500,
        durationMs: sw.elapsedMilliseconds,
      );
      return Response.json(
        statusCode: 500,
        headers: {_requestIdHeader: requestId},
        body: {
          'message': 'Internal server error',
          'details': e.toString(),
        },
      );
    }
  };
}
