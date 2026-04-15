import 'package:postgres/postgres.dart';
import 'package:student_backend/database.dart';
import 'package:student_backend/student_models.dart';

class StudentRepository {
  Future<List<Student>> list() async {
    final conn = await Database.connection;
    final result = await conn.execute(
      Sql.named(
        'SELECT id, name, age, student_class FROM students ORDER BY id ASC',
      ),
    );
    return result.map((row) => Student.fromRow(row.toColumnMap())).toList();
  }

  Future<Student?> getById(int id) async {
    final conn = await Database.connection;
    final result = await conn.execute(
      Sql.named(
        'SELECT id, name, age, student_class FROM students WHERE id = @id',
      ),
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return Student.fromRow(result.first.toColumnMap());
  }

  Future<Student> create(StudentInput input) async {
    final conn = await Database.connection;
    final result = await conn.execute(
      Sql.named(
        '''
INSERT INTO students (name, age, student_class)
VALUES (@name, @age, @student_class)
RETURNING id, name, age, student_class
''',
      ),
      parameters: {
        'name': input.name,
        'age': input.age,
        'student_class': input.studentClass,
      },
    );
    return Student.fromRow(result.first.toColumnMap());
  }

  Future<Student?> update(int id, StudentInput input) async {
    final conn = await Database.connection;
    final result = await conn.execute(
      Sql.named(
        '''
UPDATE students
SET name = @name, age = @age, student_class = @student_class
WHERE id = @id
RETURNING id, name, age, student_class
''',
      ),
      parameters: {
        'id': id,
        'name': input.name,
        'age': input.age,
        'student_class': input.studentClass,
      },
    );
    if (result.isEmpty) return null;
    return Student.fromRow(result.first.toColumnMap());
  }

  Future<Student?> patch(int id, Map<String, dynamic> partial) async {
    final existing = await getById(id);
    if (existing == null) return null;

    var name = existing.name;
    var age = existing.age;
    var cls = existing.studentClass;

    if (partial.containsKey('name')) {
      name = (partial['name'] as String?)?.trim() ?? '';
    }
    if (partial.containsKey('age')) {
      final a = partial['age'];
      age = a is int
          ? a
          : a is num
              ? a.toInt()
              : int.tryParse('$a') ?? age;
    }
    if (partial.containsKey('class') || partial.containsKey('student_class')) {
      final raw = partial['class'] ?? partial['student_class'];
      cls = (raw as String?)?.trim() ?? cls;
    }

    final input = StudentInput(name: name, age: age, studentClass: cls);
    final err = validationMessage(input);
    if (err.isNotEmpty) {
      throw FormatException(err);
    }
    return update(id, input);
  }

  Future<bool> delete(int id) async {
    final conn = await Database.connection;
    final result = await conn.execute(
      Sql.named('DELETE FROM students WHERE id = @id RETURNING id'),
      parameters: {'id': id},
    );
    return result.isNotEmpty;
  }
}
