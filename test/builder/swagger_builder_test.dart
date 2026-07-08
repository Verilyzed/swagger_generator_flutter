import 'dart:convert';

import 'package:build/build.dart';
import 'package:swagger_generator_flutter/src/builder/builder_config.dart';
import 'package:swagger_generator_flutter/src/builder/swagger_builder.dart';
import 'package:test/test.dart';

void main() {
  test('default config writes outputs co-located with the spec', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(
      config.outputPathFor('lib/resource_scheduler.json', '.enums.dart'),
      'lib/resource_scheduler.enums.dart',
    );
  });

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
    expect(sources['.client.dart'], contains('JsonSerializableConverter'));
    expect(sources['.client.dart'], contains('Task: Task.fromJson,'));
    expect(sources['.api.dart'], contains("export 'demo.enums.dart';"));

    final pathNamed = generateSources(
      content,
      path: 'lib/api/demo.openapi.json',
      baseName: 'demo',
      nameFromPath: true,
    );
    expect(pathNamed['.service.dart'], contains('getTasks('));
  });

  test('generateSources applies multipart_file_type to file parts', () {
    final content = jsonEncode({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/upload': {
          'post': {
            'operationId': 'upload',
            'requestBody': {
              'content': {
                'multipart/form-data': {
                  'schema': {
                    'type': 'object',
                    'required': ['file'],
                    'properties': {
                      'file': {'type': 'string', 'format': 'binary'},
                    },
                  },
                },
              },
            },
            'responses': <String, dynamic>{},
          },
        },
      },
    });

    final sources = generateSources(
      content,
      path: 'lib/api/demo.openapi.json',
      baseName: 'demo',
      multipartFileType: MultipartFileType.listInt,
    );

    final service = sources['.service.dart']!;
    expect(service, contains("@PartFile('file') required List<int> file,"));
    expect(service, isNot(contains('package:http')));
  });
}
