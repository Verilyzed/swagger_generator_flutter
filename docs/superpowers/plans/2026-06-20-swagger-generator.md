# Swagger Generator Flutter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate Dart code (enums, json_serializable models, one Chopper service, a Chopper client) from an OpenAPI spec, driven by a build_runner Builder.

**Architecture:** Parse -> IR -> Emit. A `SpecParser` turns the raw spec map into a normalized `ApiSpec` IR. A shared `DartTypeResolver` maps schema nodes to Dart types and a shared `NameGiver` produces valid Dart identifiers. Small emitters turn the IR into Dart source strings. A `SwaggerBuilder` wires it into build_runner ahead of json_serializable and chopper_generator.

**Tech Stack:** Dart, `build`/`source_gen`, `yaml`, `json_serializable`/`json_annotation`, `chopper`/`chopper_generator`, `test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Match existing style; `dart format` and `dart analyze` must stay clean.
- analysis_options enforces: single quotes, trailing commas, `always_declare_return_types`, `prefer_final_locals`, `prefer_const_constructors`, `directives_ordering`. Write code that already satisfies these.
- TDD: no production code without a failing test first. Keep `dart test` green.
- Comments only to explain non-obvious *why*.
- Generated files begin with `// GENERATED CODE - DO NOT MODIFY BY HAND`.
- Dart SDK floor: `^3.8.0` (pure Dart package, no Flutter dependency in the generator).

---

### Task 1: Project setup (pure Dart package + dependencies)

Convert the stub Flutter package into a pure Dart code-generator package and pull in dependencies. The `example/` app is untouched.

**Files:**
- Modify: `pubspec.yaml`
- Delete: `lib/swagger_generator_flutter.dart` stub contents (replace with barrel)
- Create: `lib/swagger_generator_flutter.dart` (library barrel)
- Delete: `test/swagger_generator_flutter_test.dart` (Calculator test)
- Create: `test/setup_test.dart`

**Interfaces:**
- Produces: package compiles with `build`, `source_gen`, `yaml`, `json_annotation`, `chopper` as runtime deps and `json_serializable`, `chopper_generator`, `build_runner`, `test` as dev deps.

- [ ] **Step 1: Replace `pubspec.yaml`**

```yaml
name: swagger_generator_flutter
description: "Generate Dart code from OpenAPI (Swagger) specifications."
version: 0.0.1
homepage:

environment:
  sdk: ^3.8.0

dependencies:
  build: ^2.4.0
  source_gen: ^1.5.0
  yaml: ^3.1.2
  json_annotation: ^4.9.0
  chopper: ^8.0.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
  chopper_generator: ^8.0.0
  lints: ^4.0.0
  test: ^1.25.0
```

- [ ] **Step 2: Replace the library file `lib/swagger_generator_flutter.dart` with a barrel**

```dart
/// Generates Dart code from OpenAPI (Swagger) specifications.
library;

export 'src/builder/swagger_builder.dart';
```

(The export target is created in Task 12. Until then this file will not analyze; that is expected and resolved by Task 12. To keep early tasks green, temporarily make the body empty if needed.)

For Task 1, use this temporary body instead so analysis passes:

```dart
/// Generates Dart code from OpenAPI (Swagger) specifications.
library;
```

- [ ] **Step 3: Delete the old Calculator test and add a setup smoke test `test/setup_test.dart`**

```dart
import 'package:test/test.dart';

void main() {
  test('test harness runs', () {
    expect(1 + 1, 2);
  });
}
```

Delete `test/swagger_generator_flutter_test.dart`.

- [ ] **Step 4: Update `analysis_options.yaml` include line**

Change the first line from `include: package:flutter_lints/flutter.yaml` to:

```yaml
include: package:lints/recommended.yaml
```

Leave the rest of the file unchanged.

- [ ] **Step 5: Resolve dependencies and run the test**

Run: `dart pub get && dart test test/setup_test.dart`
Expected: PASS (1 test).

- [ ] **Step 6: Verify analyzer is clean**

Run: `dart analyze`
Expected: "No issues found!"

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml lib/ test/
git commit -m "Convert to pure Dart generator package with build deps"
```

---

### Task 2: Intermediate Representation (IR) data classes

Plain immutable data classes that every later stage consumes. No logic.

**Files:**
- Create: `lib/src/ir/dart_type.dart`
- Create: `lib/src/ir/api_spec.dart`
- Test: `test/ir/api_spec_test.dart`

**Interfaces:**
- Produces:
  - `DartType(String name, {bool isNullable})` with `String get display`.
  - `EnumValueDef({required String dartName, required String jsonValue})`
  - `EnumDef({required String name, required List<EnumValueDef> values})`
  - `FieldDef({required String dartName, required String jsonKey, required DartType type, required bool isRequired, String? defaultValue})`
  - `ModelDef({required String name, required List<FieldDef> fields})`
  - `ParamLocation { path, query, body }`
  - `ParamDef({required String dartName, required String wireName, required DartType type, required ParamLocation location})`
  - `OperationDef({required String methodName, required String httpMethod, required String path, required List<ParamDef> parameters, DartType? requestBodyType, required DartType responseType})`
  - `ServiceDef({required String name, required List<OperationDef> operations})`
  - `ApiSpec({required String name, required List<EnumDef> enums, required List<ModelDef> models, required ServiceDef service})`

- [ ] **Step 1: Write the failing test `test/ir/api_spec_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('DartType renders nullable display', () {
    expect(const DartType('Task').display, 'Task');
    expect(const DartType('Task', isNullable: true).display, 'Task?');
  });

  test('ApiSpec holds enums, models and a service', () {
    final spec = ApiSpec(
      name: 'demo',
      enums: const [
        EnumDef(
          name: 'AggregationEnum',
          values: [EnumValueDef(dartName: 'month', jsonValue: 'month')],
        ),
      ],
      models: const [
        ModelDef(
          name: 'Task',
          fields: [
            FieldDef(
              dartName: 'id',
              jsonKey: 'id',
              type: DartType('String'),
              isRequired: true,
            ),
          ],
        ),
      ],
      service: const ServiceDef(name: 'DemoService', operations: []),
    );

    expect(spec.enums.single.name, 'AggregationEnum');
    expect(spec.models.single.fields.single.dartName, 'id');
    expect(spec.service.name, 'DemoService');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/ir/api_spec_test.dart`
Expected: FAIL (uri does not exist / undefined classes).

- [ ] **Step 3: Create `lib/src/ir/dart_type.dart`**

```dart
/// A resolved Dart type with nullability.
class DartType {
  final String name;
  final bool isNullable;

  const DartType(this.name, {this.isNullable = false});

  String get display => isNullable ? '$name?' : name;
}
```

- [ ] **Step 4: Create `lib/src/ir/api_spec.dart`**

```dart
import 'dart_type.dart';

class EnumValueDef {
  final String dartName;
  final String jsonValue;

  const EnumValueDef({required this.dartName, required this.jsonValue});
}

class EnumDef {
  final String name;
  final List<EnumValueDef> values;

  const EnumDef({required this.name, required this.values});
}

class FieldDef {
  final String dartName;
  final String jsonKey;
  final DartType type;
  final bool isRequired;
  final String? defaultValue;

  const FieldDef({
    required this.dartName,
    required this.jsonKey,
    required this.type,
    required this.isRequired,
    this.defaultValue,
  });
}

class ModelDef {
  final String name;
  final List<FieldDef> fields;

  const ModelDef({required this.name, required this.fields});
}

enum ParamLocation { path, query, body }

class ParamDef {
  final String dartName;
  final String wireName;
  final DartType type;
  final ParamLocation location;

  const ParamDef({
    required this.dartName,
    required this.wireName,
    required this.type,
    required this.location,
  });
}

class OperationDef {
  final String methodName;
  final String httpMethod;
  final String path;
  final List<ParamDef> parameters;
  final DartType? requestBodyType;
  final DartType responseType;

  const OperationDef({
    required this.methodName,
    required this.httpMethod,
    required this.path,
    required this.parameters,
    required this.responseType,
    this.requestBodyType,
  });
}

class ServiceDef {
  final String name;
  final List<OperationDef> operations;

  const ServiceDef({required this.name, required this.operations});
}

class ApiSpec {
  final String name;
  final List<EnumDef> enums;
  final List<ModelDef> models;
  final ServiceDef service;

  const ApiSpec({
    required this.name,
    required this.enums,
    required this.models,
    required this.service,
  });
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `dart test test/ir/api_spec_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/src/ir/ test/ir/
git commit -m "Add IR data classes for ApiSpec"
```

---

### Task 3: NameGiver

The single shared unit for producing valid Dart identifiers.

**Files:**
- Create: `lib/src/resolve/name_giver.dart`
- Test: `test/resolve/name_giver_test.dart`

**Interfaces:**
- Produces a `NameGiver` class with:
  - `String className(String raw)` -> PascalCase
  - `String memberName(String raw)` -> camelCase, reserved-word safe
  - `String enumValueName(String raw)` -> camelCase, reserved-word safe
- Splits on non-alphanumeric boundaries and camelCase humps; strips illegal leading digits; appends `_` to Dart reserved words.

- [ ] **Step 1: Write the failing test `test/resolve/name_giver_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

void main() {
  final names = NameGiver();

  test('className produces PascalCase', () {
    expect(names.className('asset_state'), 'AssetState');
    expect(names.className('AggregationEnum'), 'AggregationEnum');
    expect(names.className('HTTP validation error'), 'HttpValidationError');
  });

  test('memberName produces camelCase', () {
    expect(names.memberName('asset_id'), 'assetId');
    expect(names.memberName('id'), 'id');
    expect(names.memberName('target-date'), 'targetDate');
  });

  test('memberName escapes reserved words', () {
    expect(names.memberName('class'), 'class_');
    expect(names.memberName('default'), 'default_');
  });

  test('enumValueName handles values that start with a digit', () {
    expect(names.enumValueName('2xx'), r'$2xx');
    expect(names.enumValueName('month'), 'month');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/resolve/name_giver_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/resolve/name_giver.dart`**

```dart
const _reserved = {
  'abstract', 'else', 'import', 'super', 'as', 'enum', 'in', 'switch',
  'assert', 'export', 'interface', 'sync', 'async', 'extends', 'is', 'this',
  'await', 'extension', 'late', 'throw', 'break', 'external', 'library',
  'true', 'case', 'factory', 'mixin', 'try', 'catch', 'false', 'new',
  'typedef', 'class', 'final', 'null', 'var', 'const', 'finally', 'on',
  'void', 'continue', 'for', 'operator', 'while', 'covariant', 'function',
  'part', 'with', 'default', 'get', 'required', 'yield', 'deferred', 'hide',
  'rethrow', 'do', 'if', 'return', 'dynamic', 'implements', 'set', 'show',
  'static',
};

/// Produces valid Dart identifiers from arbitrary OpenAPI names.
class NameGiver {
  String className(String raw) {
    final parts = _words(raw);
    return parts.map(_capitalize).join();
  }

  String memberName(String raw) {
    final parts = _words(raw);
    if (parts.isEmpty) return '_';
    final head = parts.first.toLowerCase();
    final tail = parts.skip(1).map(_capitalize).join();
    final name = '$head$tail';
    return _reserved.contains(name) ? '${name}_' : name;
  }

  String enumValueName(String raw) {
    final name = memberName(raw);
    return RegExp(r'^[0-9]').hasMatch(name) ? '\$$name' : name;
  }

  List<String> _words(String raw) {
    final spaced = raw
        .replaceAllMapped(
          RegExp('([a-z0-9])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAll(RegExp('[^a-zA-Z0-9]+'), ' ');
    return spaced.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  String _capitalize(String w) =>
      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/resolve/name_giver_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/resolve/name_giver.dart test/resolve/name_giver_test.dart
git commit -m "Add NameGiver for valid Dart identifiers"
```

---

### Task 4: DartTypeResolver

Maps a raw OpenAPI schema node (a `Map`) to a `DartType`. Reused by parser and emitters.

**Files:**
- Create: `lib/src/resolve/dart_type_resolver.dart`
- Test: `test/resolve/dart_type_resolver_test.dart`

**Interfaces:**
- Consumes: `NameGiver` (Task 3), `DartType` (Task 2).
- Produces: `DartTypeResolver(NameGiver names)` with `DartType resolve(Map<String, dynamic> schema)`.
- Rules: `$ref` -> className of the ref tail; `format: date-time` -> `DateTime`; `type: integer` -> `int`; `number` -> `double`; `boolean` -> `bool`; `string` -> `String`; `array` -> `List<itemType>`; `anyOf: [X, {type: null}]` -> `X` with `isNullable: true`; unknown -> `dynamic`.

- [ ] **Step 1: Write the failing test `test/resolve/dart_type_resolver_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

void main() {
  final resolver = DartTypeResolver(NameGiver());

  test('maps primitive types', () {
    expect(resolver.resolve({'type': 'string'}).display, 'String');
    expect(resolver.resolve({'type': 'integer'}).display, 'int');
    expect(resolver.resolve({'type': 'number'}).display, 'double');
    expect(resolver.resolve({'type': 'boolean'}).display, 'bool');
  });

  test('maps date-time format to DateTime', () {
    expect(
      resolver.resolve({'type': 'string', 'format': 'date-time'}).display,
      'DateTime',
    );
  });

  test('resolves a ref to the class name', () {
    expect(
      resolver.resolve({r'$ref': '#/components/schemas/Task'}).display,
      'Task',
    );
  });

  test('maps arrays to List of item type', () {
    expect(
      resolver.resolve({
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/Task'},
      }).display,
      'List<Task>',
    );
  });

  test('anyOf with null becomes nullable', () {
    final t = resolver.resolve({
      'anyOf': [
        {'type': 'number'},
        {'type': 'null'},
      ],
    });
    expect(t.display, 'double?');
    expect(t.isNullable, isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/resolve/dart_type_resolver_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/resolve/dart_type_resolver.dart`**

```dart
import '../ir/dart_type.dart';
import 'name_giver.dart';

/// Maps an OpenAPI schema node to a Dart type.
class DartTypeResolver {
  final NameGiver _names;

  DartTypeResolver(this._names);

  DartType resolve(Map<String, dynamic> schema) {
    final ref = schema[r'$ref'];
    if (ref is String) {
      return DartType(_names.className(ref.split('/').last));
    }

    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      final nonNull = anyOf
          .cast<Map<String, dynamic>>()
          .where((s) => s['type'] != 'null')
          .toList();
      final hasNull = anyOf.any((s) => (s as Map)['type'] == 'null');
      if (nonNull.length == 1) {
        final inner = resolve(nonNull.single);
        return DartType(inner.name, isNullable: hasNull || inner.isNullable);
      }
      return DartType('dynamic', isNullable: hasNull);
    }

    final type = schema['type'];
    switch (type) {
      case 'string':
        return schema['format'] == 'date-time'
            ? const DartType('DateTime')
            : const DartType('String');
      case 'integer':
        return const DartType('int');
      case 'number':
        return const DartType('double');
      case 'boolean':
        return const DartType('bool');
      case 'array':
        final items = schema['items'];
        final inner = items is Map<String, dynamic>
            ? resolve(items)
            : const DartType('dynamic');
        return DartType('List<${inner.display}>');
      default:
        return const DartType('dynamic');
    }
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/resolve/dart_type_resolver_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/resolve/dart_type_resolver.dart test/resolve/dart_type_resolver_test.dart
git commit -m "Add DartTypeResolver for schema-to-Dart mapping"
```

---

### Task 5: SpecLoader

Decodes raw spec bytes (JSON or YAML) into a `Map<String, dynamic>`.

**Files:**
- Create: `lib/src/parser/spec_loader.dart`
- Test: `test/parser/spec_loader_test.dart`

**Interfaces:**
- Produces: `SpecLoader` with `Map<String, dynamic> load(String content, {required String path})`. Chooses YAML vs JSON by file extension (`.yaml`/`.yml` -> YAML, else JSON) and returns a deep plain `Map<String, dynamic>` / `List` structure.

- [ ] **Step 1: Write the failing test `test/parser/spec_loader_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/parser/spec_loader.dart';
import 'package:test/test.dart';

void main() {
  final loader = SpecLoader();

  test('loads JSON content', () {
    final map = loader.load('{"openapi": "3.1.0"}', path: 'spec.json');
    expect(map['openapi'], '3.1.0');
  });

  test('loads YAML content into plain maps', () {
    final map = loader.load('openapi: 3.1.0\ninfo:\n  title: Demo\n',
        path: 'spec.yaml');
    expect(map['openapi'], '3.1.0');
    expect((map['info'] as Map)['title'], 'Demo');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/spec_loader_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/parser/spec_loader.dart`**

```dart
import 'dart:convert';

import 'package:yaml/yaml.dart';

/// Loads OpenAPI spec content into plain Dart maps.
class SpecLoader {
  Map<String, dynamic> load(String content, {required String path}) {
    final isYaml = path.endsWith('.yaml') || path.endsWith('.yml');
    final decoded = isYaml ? _normalize(loadYaml(content)) : jsonDecode(content);
    return (decoded as Map).cast<String, dynamic>();
  }

  dynamic _normalize(dynamic node) {
    if (node is YamlMap) {
      return <String, dynamic>{
        for (final entry in node.entries)
          entry.key.toString(): _normalize(entry.value),
      };
    }
    if (node is YamlList) {
      return node.map(_normalize).toList();
    }
    return node;
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/parser/spec_loader_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/parser/spec_loader.dart test/parser/spec_loader_test.dart
git commit -m "Add SpecLoader for JSON and YAML specs"
```

---

### Task 6: SpecParser

Turns a loaded spec map into the `ApiSpec` IR. This is the core normalization step.

**Files:**
- Create: `lib/src/parser/spec_parser.dart`
- Test: `test/parser/spec_parser_test.dart`

**Interfaces:**
- Consumes: `NameGiver` (Task 3), `DartTypeResolver` (Task 4), IR classes (Task 2).
- Produces: `SpecParser(NameGiver names, DartTypeResolver resolver)` with `ApiSpec parse(Map<String, dynamic> spec, {required String name})`.
- Behavior:
  - A schema under `components/schemas` with an `enum` list -> `EnumDef`.
  - A schema with `type: object` (or with `properties`) -> `ModelDef`. Field `isRequired` comes from the schema's `required` list. `defaultValue` is set only for enum/string/number defaults expressible as a literal; otherwise null. (Keep defaults minimal: pass through string and number `default` values as Dart literals; ignore list/map defaults.)
  - Each path+method -> `OperationDef`. `methodName` from `operationId` via `NameGiver.memberName`. Parameters with `in: path` -> `ParamLocation.path`, `in: query` -> `ParamLocation.query`. `requestBody` JSON schema -> `requestBodyType` and a body `ParamDef`. Response type from the `200` response JSON schema; default `dynamic` if absent.
  - The single `ServiceDef` name is `NameGiver.className('${name} service')`.

- [ ] **Step 1: Write the failing test `test/parser/spec_parser_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/parser/spec_parser.dart';
import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

SpecParser _parser() {
  final names = NameGiver();
  return SpecParser(names, DartTypeResolver(names));
}

void main() {
  test('parses enums', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'AggregationEnum': {
            'type': 'string',
            'enum': ['month', 'year'],
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    expect(spec.enums.single.name, 'AggregationEnum');
    expect(
      spec.enums.single.values.map((v) => v.jsonValue),
      ['month', 'year'],
    );
  });

  test('parses models with required and nullable fields', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Task': {
            'type': 'object',
            'required': ['id'],
            'properties': {
              'id': {'type': 'string'},
              'costs': {
                'anyOf': [
                  {'type': 'number'},
                  {'type': 'null'},
                ],
              },
              'asset_id': {'type': 'string'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final task = spec.models.single;
    final id = task.fields.firstWhere((f) => f.jsonKey == 'id');
    final costs = task.fields.firstWhere((f) => f.jsonKey == 'costs');
    final assetId = task.fields.firstWhere((f) => f.jsonKey == 'asset_id');

    expect(id.isRequired, isTrue);
    expect(costs.type.isNullable, isTrue);
    expect(assetId.dartName, 'assetId');
  });

  test('parses an operation with path param and response type', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/assets/{asset_id}/schedule': {
          'get': {
            'operationId': 'get_schedule_for_asset',
            'parameters': [
              {
                'in': 'path',
                'name': 'asset_id',
                'required': true,
                'schema': {'type': 'string'},
              },
            ],
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'schema': {r'$ref': '#/components/schemas/Schedule'},
                  },
                },
              },
            },
          },
        },
      },
    }, name: 'demo');

    final op = spec.service.operations.single;
    expect(op.methodName, 'getScheduleForAsset');
    expect(op.httpMethod, 'GET');
    expect(op.path, '/assets/{asset_id}/schedule');
    expect(op.parameters.single.location, ParamLocation.path);
    expect(op.responseType.name, 'Schedule');
    expect(spec.service.name, 'DemoService');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/parser/spec_parser.dart`**

```dart
import '../ir/api_spec.dart';
import '../ir/dart_type.dart';
import '../resolve/dart_type_resolver.dart';
import '../resolve/name_giver.dart';

/// Turns a loaded OpenAPI map into the [ApiSpec] IR.
class SpecParser {
  final NameGiver _names;
  final DartTypeResolver _resolver;

  SpecParser(this._names, this._resolver);

  ApiSpec parse(Map<String, dynamic> spec, {required String name}) {
    final schemas = _schemas(spec);
    final enums = <EnumDef>[];
    final models = <ModelDef>[];

    for (final entry in schemas.entries) {
      final schema = entry.value;
      if (schema is! Map<String, dynamic>) continue;
      if (schema['enum'] is List) {
        enums.add(_enum(entry.key, schema));
      } else if (schema['type'] == 'object' || schema['properties'] is Map) {
        models.add(_model(entry.key, schema));
      }
    }

    return ApiSpec(
      name: name,
      enums: enums,
      models: models,
      service: _service(spec, name),
    );
  }

  Map<String, dynamic> _schemas(Map<String, dynamic> spec) {
    final components = spec['components'];
    if (components is! Map) return {};
    final schemas = components['schemas'];
    return schemas is Map ? schemas.cast<String, dynamic>() : {};
  }

  EnumDef _enum(String rawName, Map<String, dynamic> schema) {
    final values = (schema['enum'] as List)
        .map((v) => EnumValueDef(
              dartName: _names.enumValueName(v.toString()),
              jsonValue: v.toString(),
            ))
        .toList();
    return EnumDef(name: _names.className(rawName), values: values);
  }

  ModelDef _model(String rawName, Map<String, dynamic> schema) {
    final required = (schema['required'] as List?)?.cast<String>() ?? const [];
    final properties =
        (schema['properties'] as Map?)?.cast<String, dynamic>() ?? const {};
    final fields = <FieldDef>[];

    for (final entry in properties.entries) {
      final propSchema = (entry.value as Map).cast<String, dynamic>();
      final type = _resolver.resolve(propSchema);
      fields.add(FieldDef(
        dartName: _names.memberName(entry.key),
        jsonKey: entry.key,
        type: type,
        isRequired: required.contains(entry.key),
        defaultValue: _defaultLiteral(propSchema['default']),
      ));
    }

    return ModelDef(name: _names.className(rawName), fields: fields);
  }

  String? _defaultLiteral(dynamic value) {
    if (value is String) return "'$value'";
    if (value is num || value is bool) return value.toString();
    return null;
  }

  ServiceDef _service(Map<String, dynamic> spec, String name) {
    final paths = (spec['paths'] as Map?)?.cast<String, dynamic>() ?? const {};
    final operations = <OperationDef>[];

    for (final pathEntry in paths.entries) {
      final methods = (pathEntry.value as Map).cast<String, dynamic>();
      for (final methodEntry in methods.entries) {
        final op = (methodEntry.value as Map).cast<String, dynamic>();
        operations.add(_operation(
          path: pathEntry.key,
          httpMethod: methodEntry.key.toUpperCase(),
          op: op,
        ));
      }
    }

    return ServiceDef(
      name: _names.className('$name service'),
      operations: operations,
    );
  }

  OperationDef _operation({
    required String path,
    required String httpMethod,
    required Map<String, dynamic> op,
  }) {
    final params = <ParamDef>[];
    for (final raw in (op['parameters'] as List?) ?? const []) {
      final p = (raw as Map).cast<String, dynamic>();
      final location =
          p['in'] == 'path' ? ParamLocation.path : ParamLocation.query;
      params.add(ParamDef(
        dartName: _names.memberName(p['name'] as String),
        wireName: p['name'] as String,
        type: _resolver.resolve((p['schema'] as Map).cast<String, dynamic>()),
        location: location,
      ));
    }

    DartType? bodyType;
    final body = op['requestBody'];
    final bodySchema = _jsonSchema(body is Map ? body.cast<String, dynamic>() : null);
    if (bodySchema != null) {
      bodyType = _resolver.resolve(bodySchema);
      params.add(ParamDef(
        dartName: 'body',
        wireName: 'body',
        type: bodyType,
        location: ParamLocation.body,
      ));
    }

    final responses = (op['responses'] as Map?)?.cast<String, dynamic>();
    final okSchema = _jsonSchema(
      (responses?['200'] as Map?)?.cast<String, dynamic>(),
    );
    final responseType =
        okSchema == null ? const DartType('dynamic') : _resolver.resolve(okSchema);

    return OperationDef(
      methodName: _names.memberName(op['operationId'] as String? ?? '${httpMethod.toLowerCase()}_$path'),
      httpMethod: httpMethod,
      path: path,
      parameters: params,
      requestBodyType: bodyType,
      responseType: responseType,
    );
  }

  Map<String, dynamic>? _jsonSchema(Map<String, dynamic>? container) {
    final content = (container?['content'] as Map?)?.cast<String, dynamic>();
    final json = (content?['application/json'] as Map?)?.cast<String, dynamic>();
    final schema = json?['schema'];
    return schema is Map ? schema.cast<String, dynamic>() : null;
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/parser/spec_parser.dart test/parser/spec_parser_test.dart
git commit -m "Add SpecParser producing the ApiSpec IR"
```

---

### Task 7: SourceWriter

Shared emitter helper for file headers and import blocks. Keeps emitters DRY.

**Files:**
- Create: `lib/src/emit/source_writer.dart`
- Test: `test/emit/source_writer_test.dart`

**Interfaces:**
- Produces: `SourceWriter` with static `String header()` returning the generated-code banner line plus a trailing blank line, and `String importLine(String uri)` returning `import '<uri>';`.

- [ ] **Step 1: Write the failing test `test/emit/source_writer_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/emit/source_writer.dart';
import 'package:test/test.dart';

void main() {
  test('header has the generated banner', () {
    expect(
      SourceWriter.header(),
      startsWith('// GENERATED CODE - DO NOT MODIFY BY HAND'),
    );
  });

  test('importLine formats a directive', () {
    expect(
      SourceWriter.importLine('package:json_annotation/json_annotation.dart'),
      "import 'package:json_annotation/json_annotation.dart';",
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/source_writer_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/emit/source_writer.dart`**

```dart
/// Shared helpers for emitting Dart source files.
class SourceWriter {
  static String header() =>
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n\n';

  static String importLine(String uri) => "import '$uri';";
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/emit/source_writer_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/source_writer.dart test/emit/source_writer_test.dart
git commit -m "Add SourceWriter emitter helper"
```

---

### Task 8: EnumEmitter

Emits `enums.dart` content from `List<EnumDef>`.

**Files:**
- Create: `lib/src/emit/enum_emitter.dart`
- Test: `test/emit/enum_emitter_test.dart`

**Interfaces:**
- Consumes: `EnumDef`/`EnumValueDef` (Task 2), `SourceWriter` (Task 7).
- Produces: `EnumEmitter` with `String emit(List<EnumDef> enums)`. Output imports `json_annotation`, and each enum value carries `@JsonValue('<jsonValue>')`.

- [ ] **Step 1: Write the failing test `test/emit/enum_emitter_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/emit/enum_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:test/test.dart';

void main() {
  test('emits an enum with JsonValue annotations', () {
    final out = EnumEmitter().emit(const [
      EnumDef(
        name: 'AggregationEnum',
        values: [
          EnumValueDef(dartName: 'month', jsonValue: 'month'),
          EnumValueDef(dartName: 'year', jsonValue: 'year'),
        ],
      ),
    ]);

    expect(out, contains('enum AggregationEnum {'));
    expect(out, contains("@JsonValue('month')"));
    expect(out, contains('month,'));
    expect(out, contains("import 'package:json_annotation/json_annotation.dart';"));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/enum_emitter_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/emit/enum_emitter.dart`**

```dart
import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the enums file from the IR.
class EnumEmitter {
  String emit(List<EnumDef> enums) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(
        SourceWriter.importLine(
          'package:json_annotation/json_annotation.dart',
        ),
      )
      ..writeln();

    for (final e in enums) {
      buffer.writeln('enum ${e.name} {');
      for (final v in e.values) {
        buffer
          ..writeln("  @JsonValue('${v.jsonValue}')")
          ..writeln('  ${v.dartName},');
      }
      buffer
        ..writeln('}')
        ..writeln();
    }

    return buffer.toString();
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/emit/enum_emitter_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/enum_emitter.dart test/emit/enum_emitter_test.dart
git commit -m "Add EnumEmitter"
```

---

### Task 9: ModelEmitter

Emits `models.dart` content from `List<ModelDef>`, json_serializable annotated.

**Files:**
- Create: `lib/src/emit/model_emitter.dart`
- Test: `test/emit/model_emitter_test.dart`

**Interfaces:**
- Consumes: `ModelDef`/`FieldDef` (Task 2), `SourceWriter` (Task 7).
- Produces: `ModelEmitter` with `String emit(List<ModelDef> models, {required String partFileName, required String enumsImport})`. Each class is `@JsonSerializable()` with a `part` directive, constructor, `fromJson` factory and `toJson`. A field whose `jsonKey != dartName` gets `@JsonKey(name: '<jsonKey>')`. Required fields are `required` in the constructor; non-required nullable fields are optional.

- [ ] **Step 1: Write the failing test `test/emit/model_emitter_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/emit/model_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('emits a JsonSerializable class with mapped keys', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Task',
          fields: [
            FieldDef(
              dartName: 'id',
              jsonKey: 'id',
              type: DartType('String'),
              isRequired: true,
            ),
            FieldDef(
              dartName: 'assetId',
              jsonKey: 'asset_id',
              type: DartType('String'),
              isRequired: true,
            ),
            FieldDef(
              dartName: 'costs',
              jsonKey: 'costs',
              type: DartType('double', isNullable: true),
              isRequired: false,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
    );

    expect(out, contains("part 'demo.models.g.dart';"));
    expect(out, contains('@JsonSerializable()'));
    expect(out, contains('class Task {'));
    expect(out, contains("@JsonKey(name: 'asset_id')"));
    expect(out, contains('final String assetId;'));
    expect(out, contains('final double? costs;'));
    expect(out, contains('required this.id'));
    expect(out, contains('factory Task.fromJson(Map<String, dynamic> json) =>'));
    expect(out, contains('Map<String, dynamic> toJson() => _\$TaskToJson(this);'));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/model_emitter_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/emit/model_emitter.dart`**

```dart
import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the models file from the IR.
class ModelEmitter {
  String emit(
    List<ModelDef> models, {
    required String partFileName,
    required String enumsImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(
        SourceWriter.importLine(
          'package:json_annotation/json_annotation.dart',
        ),
      )
      ..writeln(SourceWriter.importLine(enumsImport))
      ..writeln()
      ..writeln("part '$partFileName';")
      ..writeln();

    for (final model in models) {
      _emitClass(buffer, model);
    }

    return buffer.toString();
  }

  void _emitClass(StringBuffer buffer, ModelDef model) {
    buffer
      ..writeln('@JsonSerializable()')
      ..writeln('class ${model.name} {');

    for (final field in model.fields) {
      if (field.jsonKey != field.dartName) {
        buffer.writeln("  @JsonKey(name: '${field.jsonKey}')");
      }
      buffer.writeln('  final ${field.type.display} ${field.dartName};');
    }

    buffer
      ..writeln()
      ..writeln('  ${model.name}({');
    for (final field in model.fields) {
      final prefix = field.isRequired ? 'required ' : '';
      final suffix = field.defaultValue != null ? ' = ${field.defaultValue}' : '';
      buffer.writeln('    ${prefix}this.${field.dartName}$suffix,');
    }
    buffer
      ..writeln('  });')
      ..writeln()
      ..writeln(
        '  factory ${model.name}.fromJson(Map<String, dynamic> json) =>',
      )
      ..writeln('      _\$${model.name}FromJson(json);')
      ..writeln()
      ..writeln(
        '  Map<String, dynamic> toJson() => _\$${model.name}ToJson(this);',
      )
      ..writeln('}')
      ..writeln();
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/emit/model_emitter_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/model_emitter.dart test/emit/model_emitter_test.dart
git commit -m "Add ModelEmitter"
```

---

### Task 10: ServiceEmitter

Emits the single Chopper service file from `ServiceDef`.

**Files:**
- Create: `lib/src/emit/service_emitter.dart`
- Test: `test/emit/service_emitter_test.dart`

**Interfaces:**
- Consumes: `ServiceDef`/`OperationDef`/`ParamDef` (Task 2), `SourceWriter` (Task 7).
- Produces: `ServiceEmitter` with `String emit(ServiceDef service, {required String partFileName, required String modelsImport, required String enumsImport})`. Output: `import 'package:chopper/chopper.dart';` plus model/enum imports, `part`, `@ChopperApi(baseUrl: '')`, one abstract class extending `ChopperService`, a method per operation with `@Get`/`@Post`/etc. annotations, `@Path`/`@Query`/`@Body` parameter annotations, and a `static <Name> create([ChopperClient? client]) => _$<Name>(client);`.

- [ ] **Step 1: Write the failing test `test/emit/service_emitter_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/emit/service_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('emits a Chopper service with annotated methods', () {
    final out = ServiceEmitter().emit(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'getScheduleForAsset',
            httpMethod: 'GET',
            path: '/assets/{asset_id}/schedule',
            parameters: [
              ParamDef(
                dartName: 'assetId',
                wireName: 'asset_id',
                type: DartType('String'),
                location: ParamLocation.path,
              ),
            ],
            responseType: DartType('Schedule'),
          ),
        ],
      ),
      partFileName: 'demo.service.chopper.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
    );

    expect(out, contains("import 'package:chopper/chopper.dart';"));
    expect(out, contains("part 'demo.service.chopper.dart';"));
    expect(out, contains("@ChopperApi(baseUrl: '')"));
    expect(out, contains('abstract class DemoService extends ChopperService {'));
    expect(out, contains("@Get(path: '/assets/{asset_id}/schedule')"));
    expect(out, contains('Future<Response<Schedule>> getScheduleForAsset('));
    expect(out, contains("@Path('asset_id') String assetId"));
    expect(out, contains('static DemoService create([ChopperClient? client]) =>'));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/emit/service_emitter.dart`**

```dart
import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the single Chopper service file from the IR.
class ServiceEmitter {
  String emit(
    ServiceDef service, {
    required String partFileName,
    required String modelsImport,
    required String enumsImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln(SourceWriter.importLine(modelsImport))
      ..writeln(SourceWriter.importLine(enumsImport))
      ..writeln()
      ..writeln("part '$partFileName';")
      ..writeln()
      ..writeln("@ChopperApi(baseUrl: '')")
      ..writeln('abstract class ${service.name} extends ChopperService {');

    for (final op in service.operations) {
      _emitMethod(buffer, op);
    }

    buffer
      ..writeln(
        '  static ${service.name} create([ChopperClient? client]) =>',
      )
      ..writeln('      _\$${service.name}(client);')
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }

  void _emitMethod(StringBuffer buffer, OperationDef op) {
    final verb = _verb(op.httpMethod);
    final args = op.parameters.map(_param).join(',\n    ');
    buffer
      ..writeln("  @$verb(path: '${op.path}')")
      ..writeln(
        '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
      );
    if (args.isNotEmpty) {
      buffer.writeln('    $args,');
    }
    buffer
      ..writeln('  );')
      ..writeln();
  }

  String _param(ParamDef p) {
    switch (p.location) {
      case ParamLocation.path:
        return "@Path('${p.wireName}') ${p.type.display} ${p.dartName}";
      case ParamLocation.query:
        return "@Query('${p.wireName}') ${p.type.display} ${p.dartName}";
      case ParamLocation.body:
        return '@Body() ${p.type.display} ${p.dartName}';
    }
  }

  String _verb(String httpMethod) {
    switch (httpMethod) {
      case 'GET':
        return 'Get';
      case 'POST':
        return 'Post';
      case 'PUT':
        return 'Put';
      case 'PATCH':
        return 'Patch';
      case 'DELETE':
        return 'Delete';
      default:
        return 'Get';
    }
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/service_emitter.dart test/emit/service_emitter_test.dart
git commit -m "Add ServiceEmitter for the Chopper service"
```

---

### Task 11: ClientEmitter and barrel

Emits `client.dart` (ChopperClient assembly) and `api.dart` (barrel exports).

**Files:**
- Create: `lib/src/emit/client_emitter.dart`
- Test: `test/emit/client_emitter_test.dart`

**Interfaces:**
- Consumes: `ServiceDef` (Task 2), `SourceWriter` (Task 7).
- Produces: `ClientEmitter` with:
  - `String emitClient(ServiceDef service, {required String serviceImport})` -> a function `ChopperClient createClient({required Uri baseUrl, List<Interceptor>? interceptors})` that builds a `ChopperClient` with `JsonConverter` and the service registered.
  - `String emitBarrel({required String enumsImport, required String modelsImport, required String serviceImport, required String clientImport})` -> a file of `export` directives.

- [ ] **Step 1: Write the failing test `test/emit/client_emitter_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/emit/client_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:test/test.dart';

void main() {
  final emitter = ClientEmitter();

  test('emits a ChopperClient factory with the service', () {
    final out = emitter.emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
    );

    expect(out, contains("import 'package:chopper/chopper.dart';"));
    expect(out, contains('ChopperClient createClient('));
    expect(out, contains('DemoService.create('));
    expect(out, contains('converter: const JsonConverter()'));
  });

  test('emits a barrel of exports', () {
    final out = emitter.emitBarrel(
      enumsImport: 'demo.enums.dart',
      modelsImport: 'demo.models.dart',
      serviceImport: 'demo.service.dart',
      clientImport: 'demo.client.dart',
    );

    expect(out, contains("export 'demo.enums.dart';"));
    expect(out, contains("export 'demo.models.dart';"));
    expect(out, contains("export 'demo.service.dart';"));
    expect(out, contains("export 'demo.client.dart';"));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/client_emitter_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/emit/client_emitter.dart`**

```dart
import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the Chopper client assembly and the barrel export file.
class ClientEmitter {
  String emitClient(
    ServiceDef service, {
    required String serviceImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln()
      ..writeln('ChopperClient createClient({')
      ..writeln('  required Uri baseUrl,')
      ..writeln('  List<Interceptor>? interceptors,')
      ..writeln('}) {')
      ..writeln('  return ChopperClient(')
      ..writeln('    baseUrl: baseUrl,')
      ..writeln('    converter: const JsonConverter(),')
      ..writeln('    interceptors: interceptors ?? const [],')
      ..writeln('    services: [${service.name}.create()],')
      ..writeln('  );')
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }

  String emitBarrel({
    required String enumsImport,
    required String modelsImport,
    required String serviceImport,
    required String clientImport,
  }) {
    final buffer = StringBuffer()..write(SourceWriter.header());
    for (final uri in [enumsImport, modelsImport, serviceImport, clientImport]) {
      buffer.writeln("export '$uri';");
    }
    return buffer.toString();
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/emit/client_emitter_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/client_emitter.dart test/emit/client_emitter_test.dart
git commit -m "Add ClientEmitter and barrel"
```

---

### Task 12: SwaggerBuilder and build_runner wiring

Tie the pipeline together behind a build_runner `Builder`. The builder reads a spec asset and writes the fixed set of output files.

**Files:**
- Create: `lib/src/builder/swagger_builder.dart`
- Modify: `lib/swagger_generator_flutter.dart` (export the builder factory)
- Create: `build.yaml`
- Test: `test/builder/swagger_builder_test.dart`

**Interfaces:**
- Consumes: `SpecLoader` (Task 5), `SpecParser` (Task 6), `NameGiver` (Task 3), `DartTypeResolver` (Task 4), all emitters (Tasks 8-11).
- Produces:
  - `class SwaggerBuilder implements Builder` with `buildExtensions = {'.openapi.json': ['.enums.dart', '.models.dart', '.service.dart', '.client.dart', '.api.dart']}` and a `build(BuildStep)` implementation.
  - A top-level `Builder swaggerBuilder(BuilderOptions options) => SwaggerBuilder();` factory referenced from `build.yaml`.
  - A pure helper `Map<String, String> generateSources(String content, {required String path, required String baseName})` returning a map of output-extension -> file content, so the pipeline is unit-testable without the build package's IO. Keys: `'.enums.dart'`, `'.models.dart'`, `'.service.dart'`, `'.client.dart'`, `'.api.dart'`.

- [ ] **Step 1: Write the failing test `test/builder/swagger_builder_test.dart`**

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/builder/swagger_builder_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/builder/swagger_builder.dart`**

```dart
import 'package:build/build.dart';

import '../emit/client_emitter.dart';
import '../emit/enum_emitter.dart';
import '../emit/model_emitter.dart';
import '../emit/service_emitter.dart';
import '../parser/spec_loader.dart';
import '../parser/spec_parser.dart';
import '../resolve/dart_type_resolver.dart';
import '../resolve/name_giver.dart';

Builder swaggerBuilder(BuilderOptions options) => SwaggerBuilder();

/// Generates Dart sources from a `*.openapi.json` spec asset.
class SwaggerBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {
        '.openapi.json': [
          '.enums.dart',
          '.models.dart',
          '.service.dart',
          '.client.dart',
          '.api.dart',
        ],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final content = await buildStep.readAsString(input);
    final baseName = input.pathSegments.last.replaceAll('.openapi.json', '');

    final sources = generateSources(
      content,
      path: input.path,
      baseName: baseName,
    );

    for (final entry in sources.entries) {
      await buildStep.writeAsString(
        input.changeExtension(entry.key),
        entry.value,
      );
    }
  }
}

/// Runs the full pipeline and returns output extension -> file content.
Map<String, String> generateSources(
  String content, {
  required String path,
  required String baseName,
}) {
  final names = NameGiver();
  final resolver = DartTypeResolver(names);
  final spec = SpecParser(names, resolver)
      .parse(SpecLoader().load(content, path: path), name: baseName);

  final enumsFile = '$baseName.enums.dart';
  final modelsFile = '$baseName.models.dart';
  final serviceFile = '$baseName.service.dart';
  final clientFile = '$baseName.client.dart';

  final emitter = ClientEmitter();

  return {
    '.enums.dart': EnumEmitter().emit(spec.enums),
    '.models.dart': ModelEmitter().emit(
      spec.models,
      partFileName: '$baseName.models.g.dart',
      enumsImport: enumsFile,
    ),
    '.service.dart': ServiceEmitter().emit(
      spec.service,
      partFileName: '$baseName.service.chopper.dart',
      modelsImport: modelsFile,
      enumsImport: enumsFile,
    ),
    '.client.dart': emitter.emitClient(
      spec.service,
      serviceImport: serviceFile,
    ),
    '.api.dart': emitter.emitBarrel(
      enumsImport: enumsFile,
      modelsImport: modelsFile,
      serviceImport: serviceFile,
      clientImport: clientFile,
    ),
  };
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/builder/swagger_builder_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Wire `lib/swagger_generator_flutter.dart`**

```dart
/// Generates Dart code from OpenAPI (Swagger) specifications.
library;

export 'src/builder/swagger_builder.dart';
```

- [ ] **Step 6: Create `build.yaml`**

```yaml
builders:
  swagger_generator:
    import: "package:swagger_generator_flutter/swagger_generator_flutter.dart"
    builder_factories: ["swaggerBuilder"]
    build_extensions:
      ".openapi.json":
        - ".enums.dart"
        - ".models.dart"
        - ".service.dart"
        - ".client.dart"
        - ".api.dart"
    auto_apply: dependents
    build_to: source
    runs_before:
      - "json_serializable:json_serializable"
      - "chopper_generator:chopper_generator"
```

- [ ] **Step 7: Run the full test suite and analyzer**

Run: `dart test && dart analyze`
Expected: all tests PASS, "No issues found!"

- [ ] **Step 8: Commit**

```bash
git add lib/ build.yaml test/builder/
git commit -m "Add SwaggerBuilder and build_runner wiring"
```

---

### Task 13: End-to-end generation against the real spec

Prove the pipeline runs on the bundled spec and that the generated code is structurally valid.

**Files:**
- Create: `test/e2e/generation_test.dart`

**Interfaces:**
- Consumes: `generateSources` (Task 12). Reads the real spec from `example/input_folder/resource-scheduler-openapi.json`.

- [ ] **Step 1: Write the failing test `test/e2e/generation_test.dart`**

```dart
import 'dart:io';

import 'package:swagger_generator_flutter/src/builder/swagger_builder.dart';
import 'package:test/test.dart';

void main() {
  test('generates all files from the bundled spec without throwing', () {
    final file = File('example/input_folder/resource-scheduler-openapi.json');
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
}
```

- [ ] **Step 2: Run the test to verify it fails or passes**

Run: `dart test test/e2e/generation_test.dart`
Expected: PASS if earlier tasks are complete. If it throws, fix the parser/emitter for the construct that broke (add a focused unit test in the owning task first, then fix).

- [ ] **Step 3: Run the complete suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!"

- [ ] **Step 4: Commit**

```bash
git add test/e2e/
git commit -m "Add end-to-end generation test against the bundled spec"
```

---

## Notes for the implementer

- Build phase chaining (our builder -> json_serializable -> chopper_generator) is configured in `build.yaml` but only exercised when a consuming project runs `dart run build_runner build`. Verifying that full chain is a follow-up (best done in the `example/` app once it depends on this package); the unit and e2e tests here cover the generation logic itself.
- `dart format .` before each commit if the analyzer flags formatting.
- Keep each emitter ignorant of OpenAPI: they only see IR. All schema interpretation lives in `SpecParser` and `DartTypeResolver`.
