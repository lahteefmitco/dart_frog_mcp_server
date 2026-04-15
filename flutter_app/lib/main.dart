import 'package:flutter/material.dart';
import 'package:student_app/features/students/presentation/student_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const StudentListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
