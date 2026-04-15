import 'package:flutter_test/flutter_test.dart';
import 'package:student_app/features/students/data/student.dart';

void main() {
  test('Student.fromJson maps API class field', () {
    final s = Student.fromJson({
      'id': 1,
      'name': 'Ada',
      'age': 12,
      'class': '7B',
    });
    expect(s.id, 1);
    expect(s.name, 'Ada');
    expect(s.age, 12);
    expect(s.studentClass, '7B');
  });
}
