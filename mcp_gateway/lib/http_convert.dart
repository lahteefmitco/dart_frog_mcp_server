import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

/// Maps a package:http response to a Dart Frog [Response].
Response dartFrogFromHttp(http.Response r) {
  final headers = <String, Object>{};
  r.headers.forEach((k, v) {
    headers[k] = v;
  });
  return Response(
    statusCode: r.statusCode,
    body: r.body.isEmpty ? null : r.body,
    headers: headers,
  );
}
