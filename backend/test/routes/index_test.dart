import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with 200 and JSON health payload', () async {
      final context = _MockRequestContext();
      when(() => context.request).thenReturn(
        Request.get(Uri.parse('http://localhost/')),
      );
      final response = route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      final body = await response.json();
      expect(body['service'], equals('student_backend'));
    });
  });
}
