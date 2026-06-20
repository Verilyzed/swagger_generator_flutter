import 'dart:convert';

import 'package:swagger_generator_flutter/src/builder/swagger_builder.dart';
import 'package:test/test.dart';

void main() {
  test('generateSources produces the five output files', () {
    final content = jsonEncode({
      'components': {
        'schemas': {
          'AggregationEnum': {
            'type': 'string',
            'enum': ['month', 'year'],
          },
          'Task': {
            'type': 'object',
            'required': ['id'],
            'properties': {
              'id': {'type': 'string'},
            },
          },
        },
      },
      'paths': {
        '/tasks': {
          'get': {
            'operationId': 'list_tasks',
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'schema': {r'$ref': '#/components/schemas/Task'},
                  },
                },
              },
            },
          },
        },
      },
    });

    final sources = generateSources(
      content,
      path: 'lib/api/demo.openapi.json',
      baseName: 'demo',
    );

    expect(sources.keys, containsAll(<String>[
      '.enums.dart',
      '.models.dart',
      '.service.dart',
      '.client.dart',
      '.api.dart',
    ]));
    expect(sources['.enums.dart'], contains('enum AggregationEnum {'));
    expect(sources['.models.dart'], contains('class Task {'));
    expect(sources['.service.dart'], contains('class DemoService extends ChopperService {'));
    expect(sources['.service.dart'], contains('listTasks('));
    expect(sources['.client.dart'], contains('ChopperClient createClient('));
    expect(sources['.api.dart'], contains("export 'demo.enums.dart';"));
  });
}
