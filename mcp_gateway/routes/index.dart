import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  return Response.json(
    body: {
      'service': 'student_mcp_gateway',
      'health': 'ok',
      'api': {
        'students': '/api/students',
        'query': '/api/query',
      },
    },
  );
}
