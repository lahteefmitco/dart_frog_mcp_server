import 'package:dio/dio.dart';
import 'package:student_app/features/students/data/student.dart';

/// Talks to the MCP gateway (`/api/...`), not the raw backend.
class StudentRemoteDatasource {
  StudentRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Student>> listStudents() async {
    final response = await _dio.get<Object?>('api/students');
    final data = response.data;
    if (data == null) return [];
    if (data is! List<dynamic>) {
      throw StateError('Expected JSON array from api/students');
    }
    return data
        .map((e) => Student.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Student> getStudent(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('api/students/$id');
    final data = response.data;
    if (data == null) {
      throw StateError('Empty response');
    }
    return Student.fromJson(data);
  }

  Future<Student> createStudent({
    required String name,
    required int age,
    required String studentClass,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/students',
      data: {
        'name': name,
        'age': age,
        'class': studentClass,
      },
    );
    final data = response.data;
    if (data == null) throw StateError('Empty response');
    return Student.fromJson(data);
  }

  Future<Student> updateStudent(
    int id, {
    required String name,
    required int age,
    required String studentClass,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      'api/students/$id',
      data: {
        'name': name,
        'age': age,
        'class': studentClass,
      },
    );
    final data = response.data;
    if (data == null) throw StateError('Empty response');
    return Student.fromJson(data);
  }

  Future<void> deleteStudent(int id) async {
    await _dio.delete<void>('api/students/$id');
  }

  /// Natural-language query via Mistral (gateway `/api/query`).
  Future<String> askAssistant(String query) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/query',
      data: {'query': query},
    );
    final data = response.data;
    if (data == null) return '';
    return data['answer'] as String? ?? '';
  }
}
