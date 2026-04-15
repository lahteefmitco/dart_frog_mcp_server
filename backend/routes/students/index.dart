import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:student_backend/student_models.dart';
import 'package:student_backend/student_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final repo = StudentRepository();
  final m = context.request.method;
  if (m == HttpMethod.get) {
      final list = await repo.list();
      return Response.json(
        body: list.map((e) => e.toJson()).toList(),
      );
  }
  if (m == HttpMethod.post) {
      final raw = await context.request.body();
      final map = decodeBodyMap(raw);
      if (map == null) {
        return Response.json(
          statusCode: 400,
          body: {
            'message': 'Invalid JSON body',
            'details': 'Expected a JSON object',
          },
        );
      }
      final input = StudentInput.fromJson(map);
      final err = validationMessage(input);
      if (err.isNotEmpty) {
        return Response.json(
          statusCode: 400,
          body: {
            'message': 'Validation failed',
            'details': err,
          },
        );
      }
      try {
        final created = await repo.create(input);
        return Response.json(statusCode: 201, body: created.toJson());
      } on PgException catch (e) {
        return Response.json(
          statusCode: 400,
          body: {
            'message': 'Database error',
            'details': e.message,
          },
        );
      }
  }
  return Response(statusCode: 405);
}
