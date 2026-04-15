import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:student_app/features/students/data/student_remote_datasource.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({required this.datasource, super.key});

  final StudentRemoteDatasource datasource;

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final _controller = TextEditingController();
  String? _answer;
  bool _loading = false;

  Future<void> _send() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _answer = null;
    });
    try {
      final a = await widget.datasource.askAssistant(q);
      setState(() {
        _answer = a;
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _loading = false;
        _answer = e.response?.data?.toString() ?? e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _answer = '$e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Question about students',
                hintText: 'e.g. How many students are in class 5A?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _send,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send'),
            ),
            const SizedBox(height: 24),
            if (_answer != null)
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(_answer!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
