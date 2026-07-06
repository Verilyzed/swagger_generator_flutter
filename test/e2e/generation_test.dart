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

    expect(sources['.client.dart'], contains('class ResourceSchedulerApi {'));
    expect(
      sources['.service.dart'],
      isNot(contains('class ResourceSchedulerApi')),
    );
  });

  test('maps a date field to String', () {
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
    expect(models, contains('final String? createdAt;'));
  });

  test('maps a date parameter to String', () {
    const spec = '''
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "paths": {
    "/x": {
      "get": {
        "operationId": "getX",
        "parameters": [
          {
            "in": "query",
            "name": "startDatum",
            "schema": {"type": "string", "format": "date"},
            "example": "2026-06-24",
            "required": true
          },
          {
            "in": "query",
            "name": "endDatum",
            "schema": {"type": "string", "format": "date"},
            "required": true
          }
        ],
        "responses": {"200": {"description": "ok"}}
      }
    }
  }
}
''';

    final service = generateSources(spec, path: 'x.json', baseName: 'x')[
        '.service.dart'];

    expect(
      service,
      contains("@Query('startDatum') required String startDatum,"),
    );
    expect(
      service,
      contains("@Query('endDatum') required String endDatum,"),
    );
  });

  test('uses an override type for an overridden schema', () {
    const spec = '''
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "components": {
    "schemas": {
      "OneOfThing": {
        "oneOf": [
          {"type": "string"},
          {"type": "integer"}
        ]
      },
      "Holder": {
        "type": "object",
        "properties": {
          "thing": {"\$ref": "#/components/schemas/OneOfThing"}
        }
      }
    }
  },
  "paths": {}
}
''';

    final sources = generateSources(
      spec,
      path: 'h.json',
      baseName: 'h',
      overridesImport: 'package:example/overrides.dart',
      overrideSchemas: const {'OneOfThing'},
    );

    expect(sources['.enums.dart'], isNot(contains('OneOfThing')));
    expect(sources['.models.dart'], isNot(contains('class OneOfThing')));
    expect(sources['.models.dart'], contains('final OneOfThing? thing;'));
    expect(
      sources['.models.dart'],
      contains("import 'package:example/overrides.dart';"),
    );
    expect(
      sources['.client.dart'],
      contains('OneOfThing: OneOfThing.fromJson,'),
    );
    expect(
      sources['.client.dart'],
      contains("import 'package:example/overrides.dart';"),
    );
  });

  test('emits a typedef for a top-level array schema', () {
    const spec = '''
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "components": {"schemas": {
    "Tags": {"type": "array", "items": {"type": "string"}},
    "Post": {"type": "object", "properties": {
      "tags": {"\$ref": "#/components/schemas/Tags"}
    }}
  }},
  "paths": {}
}
''';

    final models = generateSources(spec, path: 'p.json', baseName: 'p')[
        '.models.dart'];

    expect(models, contains('typedef Tags = List<String>;'));
    expect(models, contains('final Tags? tags;'));
  });

  test('generates a copyWith on a model class', () {
    const spec = '''
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "components": {"schemas": {
    "Customer": {
      "type": "object",
      "required": ["id"],
      "properties": {
        "id": {"type": "string"},
        "nickname": {"type": "string", "nullable": true}
      }
    }
  }},
  "paths": {}
}
''';

    final models = generateSources(spec, path: 'c.json', baseName: 'c')[
        '.models.dart'];

    expect(models, contains('Customer copyWith({'));
    expect(models, contains('String? id,'));
    expect(models, contains('String? nickname,'));
    expect(models, contains('id: id ?? this.id,'));
    expect(models, contains('nickname: nickname ?? this.nickname,'));
  });

  test('uses the single member of an allOf property', () {
    const spec = '''
{
  "openapi": "3.0.1",
  "info": {"title": "t", "version": "1"},
  "components": {"schemas": {
    "Bar": {"type": "object", "properties": {"x": {"type": "string"}}},
    "Foo": {"type": "object", "properties": {
      "child": {"allOf": [{"\$ref": "#/components/schemas/Bar"}]}
    }}
  }},
  "paths": {}
}
''';

    final models = generateSources(spec, path: 'f.json', baseName: 'f')[
        '.models.dart'];

    expect(models, contains('final Bar? child;'));
    expect(models, isNot(contains('dynamic child')));
  });

  test('handles a 3.0 anyOf ref-or-null property', () {
    const spec = '''
{
  "openapi": "3.0.1",
  "info": {"title": "t", "version": "1"},
  "components": {"schemas": {
    "Bar": {"type": "object", "properties": {"x": {"type": "string"}}},
    "Foo": {"type": "object", "properties": {
      "bar": {"anyOf": [{"\$ref": "#/components/schemas/Bar"}, {"type": "null"}]}
    }}
  }},
  "paths": {}
}
''';

    final models = generateSources(spec, path: 'f.json', baseName: 'f')[
        '.models.dart'];

    expect(models, contains('final Bar? bar;'));
    expect(models, isNot(contains('dynamic bar')));
  });

  test('a required ref to a nullable enum becomes an optional nullable field',
      () {
    const spec = '''
{
  "openapi": "3.0.0",
  "info": {"title": "t", "version": "1"},
  "components": {"schemas": {
    "Salutation": {"type": "string", "enum": ["Mr", "Mrs"], "nullable": true},
    "Customer": {"type": "object", "required": ["salutation"], "properties": {
      "salutation": {"\$ref": "#/components/schemas/Salutation"}
    }}
  }},
  "paths": {}
}
''';

    final models = generateSources(spec, path: 'c.json', baseName: 'c')[
        '.models.dart'];

    expect(models, contains('final Salutation? salutation;'));
    expect(models, contains('this.salutation,'));
    expect(models, isNot(contains('required this.salutation')));
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
