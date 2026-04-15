import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:student_app/core/dio_client.dart';
import 'package:student_app/features/students/data/student.dart';
import 'package:student_app/features/students/data/student_remote_datasource.dart';
import 'package:student_app/features/students/presentation/query_screen.dart';
import 'package:student_app/features/students/presentation/student_edit_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late final StudentRemoteDatasource _ds;
  late Future<List<Student>> _future;

  @override
  void initState() {
    super.initState();
    _ds = StudentRemoteDatasource(createDio());
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _ds.listStudents();
    });
  }

  Future<void> _delete(Student s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete student'),
        content: Text('Remove ${s.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _ds.deleteStudent(s.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student deleted')),
      );
      _reload();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_dioMessage(e))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return '${data['message']}';
    }
    return e.message ?? '$e';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Ask assistant',
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => QueryScreen(datasource: _ds),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final f = _ds.listStudents();
          setState(() => _future = f);
          await f;
        },
        child: FutureBuilder<List<Student>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
              );
            }
            final list = snapshot.data ?? [];
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No students yet. Tap + to add one.'),
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final s = list[i];
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text('Age ${s.age} · Class ${s.studentClass}'),
                  onTap: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => StudentEditScreen(
                          datasource: _ds,
                          existing: s,
                        ),
                      ),
                    );
                    _reload();
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(s),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => StudentEditScreen(datasource: _ds),
            ),
          );
          _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
