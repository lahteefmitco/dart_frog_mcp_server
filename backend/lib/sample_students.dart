import 'package:student_backend/student_models.dart';

/// Builds [count] deterministic sample rows for dev seeding.
List<StudentInput> generateSampleStudents({int count = 100}) {
  return List.generate(count, (i) {
    final n = i + 1;
    final age = (i % 12) + 7; // 7–18
    final grade = (i % 6) + 1;
    final section = String.fromCharCode(65 + (i % 3)); // A, B, C
    return StudentInput(
      name: 'Sample Student ${n.toString().padLeft(3, '0')}',
      age: age,
      studentClass: 'Grade $grade$section',
    );
  });
}
