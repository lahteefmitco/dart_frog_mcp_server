import 'package:mcp_server/mcp_server.dart';
import 'package:student_mcp_gateway/backend_client.dart';
import 'package:student_mcp_gateway/env_config.dart';

/// MCP server over stdio: tools forward to the same REST backend as the gateway.
///
/// Run from `mcp_gateway/`: `dart run bin/mcp_stdio.dart`
void main() {
  loadEnvOnce();

  final server = McpServer.createServer(
    McpServer.simpleConfig(
      name: 'student_mcp_gateway',
      version: '1.0.0',
    ),
  );

  server.addTool(
    name: 'list_students',
    description: 'Fetch all students from the student backend API',
    inputSchema: const {
      'type': 'object',
      'properties': <String, dynamic>{},
    },
    handler: (args) async {
      const rid = 'mcp-stdio';
      final text = await fetchStudentsPlain(rid);
      return CallToolResult(
        content: [TextContent(text: text)],
      );
    },
  );

  server.addTool(
    name: 'create_student',
    description: 'Create a student with name, age, and class',
    inputSchema: const {
      'type': 'object',
      'properties': {
        'name': {
          'type': 'string',
          'description': 'Student full name',
        },
        'age': {
          'type': 'integer',
          'description': 'Age in years',
        },
        'class': {
          'type': 'string',
          'description': 'Class label (e.g. 5A)',
        },
      },
      'required': ['name', 'age', 'class'],
    },
    handler: (args) async {
      final text = await createStudentMcp('mcp-stdio', args);
      return CallToolResult(
        content: [TextContent(text: text)],
      );
    },
  );

  final transport = McpServer.createStdioTransport().get();
  server.connect(transport);
}
