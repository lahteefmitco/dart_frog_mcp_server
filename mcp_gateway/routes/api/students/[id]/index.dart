import 'package:dart_frog/dart_frog.dart';
import 'package:student_mcp_gateway/backend_client.dart';
import 'package:student_mcp_gateway/http_convert.dart';
import 'package:student_mcp_gateway/request_id_tag.dart';

Future<Response> onRequest(RequestContext context) async {
  final rid = context.read<RequestIdTag>().value;
  final id = context.request.params['id'];
  if (id == null || id.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'message': 'Missing id',
        'details': null,
      },
    );
  }

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

  final path = '/students/$id';
  final m = context.request.method;

  if (m == HttpMethod.get) {
    final resp = await client.forward(
      requestId: rid,
      method: 'GET',
      path: path,
      query: context.request.uri.queryParameters,
    );
    return dartFrogFromHttp(resp);
  }

  if (m == HttpMethod.put || m == HttpMethod.patch) {
    final body = await context.request.body();
    final resp = await client.forward(
      requestId: rid,
      method: m == HttpMethod.put ? 'PUT' : 'PATCH',
      path: path,
      body: body,
    );
    return dartFrogFromHttp(resp);
  }

  if (m == HttpMethod.delete) {
    final resp = await client.forward(
      requestId: rid,
      method: 'DELETE',
      path: path,
    );
    return dartFrogFromHttp(resp);
  }

  return Response(statusCode: 405);
}
