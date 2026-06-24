import 'dart:io';

import 'package:swagger_generator_flutter/src/builder/swagger_builder.dart';
import 'package:test/test.dart';

void main() {
  test('generates all files from the bundled spec without throwing', () {
    final file = File('example/lib/specs/resource_scheduler.json');
    final content = file.readAsStringSync();

    final sources = generateSources(
      content,
      path: file.path,
      baseName: 'resource_scheduler',
    );

    expect(sources['.enums.dart'], contains('enum AggregationEnum {'));
    expect(sources['.models.dart'], contains('class Task {'));
    expect(
      sources['.service.dart'],
      contains('class ResourceSchedulerService extends ChopperService {'),
    );
    expect(sources['.api.dart'], contains("export 'resource_scheduler.enums.dart';"));

    for (final source in sources.values) {
      expect(source, startsWith('// GENERATED CODE'));
    }
  });

  test('keeps a date field with an example as a String', () {
    const spec = '''
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "components": {
    "schemas": {
      "Event": {
        "type": "object",
        "properties": {
          "occurredAt": {"type": "string", "format": "date", "example": "2025-04-20"},
          "createdAt": {"type": "string", "format": "date"}
        }
      }
    }
  },
  "paths": {}
}
''';

    final sources = generateSources(spec, path: 'ev.json', baseName: 'ev');
    final models = sources['.models.dart'];

    expect(models, contains('final String? occurredAt;'));
    expect(models, contains('final DateTime? createdAt;'));
  });

  test('creates a named enum for an inline enum parameter', () {
    const spec = '''
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "paths": {
    "/curve": {
      "get": {
        "operationId": "getCurve",
        "parameters": [
          {
            "name": "interpolationsAufloesung",
            "in": "query",
            "schema": {"type": "string", "enum": ["LINEAR", "CUBIC"]}
          }
        ],
        "responses": {"200": {"description": "ok"}}
      }
    }
  }
}
''';

    final sources = generateSources(spec, path: 'curve.json', baseName: 'curve');

    expect(
      sources['.enums.dart'],
      contains('enum GetCurveInterpolationsAufloesung {'),
    );
    expect(
      sources['.service.dart'],
      contains(
        'GetCurveInterpolationsAufloesung? interpolationsAufloesung',
      ),
    );
  });
}
