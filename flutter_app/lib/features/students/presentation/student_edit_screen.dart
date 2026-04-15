import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:student_app/features/students/data/student.dart';
import 'package:student_app/features/students/data/student_remote_datasource.dart';

class StudentEditScreen extends StatefulWidget {
  const StudentEditScreen({
    required this.datasource,
    super.key,
    this.existing,
  });

  final StudentRemoteDatasource datasource;
  final Student? existing;

  @override
  State<StudentEditScreen> createState() => _StudentEditScreenState();
}

class _StudentEditScreenState extends State<StudentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _class;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _age = TextEditingController(text: e != null ? '${e.age}' : '');
    _class = TextEditingController(text: e?.studentClass ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _class.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _name.text.trim();
    final age = int.tryParse(_age.text.trim());
    final cls = _class.text.trim();
    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid age')),
      );
      return;
    }
    try {
      if (widget.existing == null) {
        await widget.datasource.createStudent(
          name: name,
          age: age,
          studentClass: cls,
        );
      } else {
        await widget.datasource.updateStudent(
          widget.existing!.id,
          name: name,
          age: age,
          studentClass: cls,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null
          ? '${data['message']}'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg ?? 'Request failed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New student' : 'Edit student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _age,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _class,
                decoration: const InputDecoration(labelText: 'Class'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
