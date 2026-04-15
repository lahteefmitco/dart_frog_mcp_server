import 'package:dart_frog/dart_frog.dart';
import 'package:student_mcp_gateway/backend_client.dart';
import 'package:student_mcp_gateway/http_convert.dart';
import 'package:student_mcp_gateway/request_id_tag.dart';

Future<Response> onRequest(RequestContext context) async {
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

  final m = context.request.method;
  if (m == HttpMethod.get) {
    final resp = await client.forward(
      requestId: rid,
      method: 'GET',
      path: '/students',
      query: context.request.uri.queryParameters,
    );
    return dartFrogFromHttp(resp);
  }
  if (m == HttpMethod.post) {
    final body = await context.request.body();
    final resp = await client.forward(
      requestId: rid,
      method: 'POST',
      path: '/students',
      body: body,
    );
    return dartFrogFromHttp(resp);
  }
  return Response(statusCode: 405);
}
