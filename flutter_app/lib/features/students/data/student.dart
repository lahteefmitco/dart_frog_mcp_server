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

  /// JSON key is [class].
  final String studentClass;

  factory Student.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is int
        ? idRaw
        : idRaw is num
            ? idRaw.toInt()
            : int.parse('$idRaw');
    final ageRaw = json['age'];
    final age = ageRaw is int
        ? ageRaw
        : ageRaw is num
            ? ageRaw.toInt()
            : int.parse('$ageRaw');
    final cls = json['class'] as String? ?? json['student_class'] as String?;
    return Student(
      id: id,
      name: json['name'] as String? ?? '',
      age: age,
      studentClass: cls ?? '',
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'class': studentClass,
      };
}
