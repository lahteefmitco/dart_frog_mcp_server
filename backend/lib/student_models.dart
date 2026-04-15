import 'dart:convert';

/// JSON uses key [class] (quoted in JSON); Dart field is [studentClass].
class Student {
  const Student({
    required this.id,
    required this.name,
    required this.age,
    required this.studentClass,
  });

  final int id;
  final String name;
  final int age;
  final String studentClass;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'class': studentClass,
      };

  static Student fromRow(Map<String, dynamic> map) {
    final idVal = map['id'];
    final id = idVal is int
        ? idVal
        : idVal is BigInt
            ? idVal.toInt()
            : (idVal as num).toInt();
    return Student(
      id: id,
      name: map['name'] as String,
      age: (map['age'] as num).toInt(),
      studentClass: map['student_class'] as String,
    );
  }
}

class StudentInput {
  const StudentInput({
    required this.name,
    required this.age,
    required this.studentClass,
  });

  final String name;
  final int age;
  final String studentClass;

  static StudentInput fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim() ?? '';
    final ageVal = json['age'];
    final age = ageVal is int
        ? ageVal
        : ageVal is num
            ? ageVal.toInt()
            : int.tryParse('$ageVal') ?? -1;
    final cls = json['class'] as String? ?? json['student_class'] as String?;
    return StudentInput(
      name: name,
      age: age,
      studentClass: (cls ?? '').trim(),
    );
  }
}

String validationMessage(StudentInput input) {
  if (input.name.isEmpty) return 'name is required';
  if (input.age <= 0 || input.age >= 150) return 'age must be between 1 and 149';
  if (input.studentClass.isEmpty) return 'class is required';
  return '';
}

Map<String, dynamic>? decodeBodyMap(String body) {
  try {
    final v = jsonDecode(body);
    if (v is Map<String, dynamic>) return v;
    return null;
  } catch (_) {
    return null;
  }
}
