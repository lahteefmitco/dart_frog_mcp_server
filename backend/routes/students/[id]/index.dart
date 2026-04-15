import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:student_backend/student_models.dart';
import 'package:student_backend/student_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final idStr = context.request.params['id'];
  final id = int.tryParse(idStr ?? '');
  if (id == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'message': 'Invalid id',
        'details': 'id must be an integer',
      },
    );
  }

  final repo = StudentRepository();

  final m = context.request.method;
  if (m == HttpMethod.get) {
      final s = await repo.getById(id);
      if (s == null) {
        return Response.json(
          statusCode: 404,
          body: {
            'message': 'Student not found',
            'details': id,
          },
        );
      }
      return Response.json(body: s.toJson());
  }
  if (m == HttpMethod.put || m == HttpMethod.patch) {
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
      try {
        Student? updated;
        if (m == HttpMethod.put) {
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
          updated = await repo.update(id, input);
        } else {
          updated = await repo.patch(id, map);
        }
        if (updated == null) {
          return Response.json(
            statusCode: 404,
            body: {
              'message': 'Student not found',
              'details': id,
            },
          );
        }
        return Response.json(body: updated.toJson());
      } on FormatException catch (e) {
        return Response.json(
          statusCode: 400,
          body: {
            'message': 'Validation failed',
            'details': e.message,
          },
        );
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
  if (m == HttpMethod.delete) {
      final ok = await repo.delete(id);
      if (!ok) {
        return Response.json(
          statusCode: 404,
          body: {
            'message': 'Student not found',
            'details': id,
          },
        );
      }
      return Response(statusCode: 204);
  }
  return Response(statusCode: 405);
}
