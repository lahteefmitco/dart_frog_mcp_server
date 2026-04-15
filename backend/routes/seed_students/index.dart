import 'package:dart_frog/dart_frog.dart';
import 'package:student_backend/sample_students.dart';
import 'package:student_backend/student_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final repo = StudentRepository();
  final rows = generateSampleStudents();
  final inserted = await repo.insertMany(rows);

  return Response.json(
    body: {
      'message': 'Inserted $inserted sample students',
      'count': inserted,
    },
  );
}
