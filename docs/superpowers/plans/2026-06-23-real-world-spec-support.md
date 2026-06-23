# Real-World / OpenAPI 3.0 Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate compiling, correct Dart from OpenAPI 3.0 and 3.1 specs - handling `nullable`, inline enums, `allOf`, Chopper name collisions, and acronym casing - proven by regenerating the 1Password spec clean and a model round-trip.

**Architecture:** Split `DartTypeResolver` into a shared base plus `OpenApi30TypeResolver`/`OpenApi31TypeResolver`, selected by a version factory and injected into the unchanged `SpecParser`. `SpecParser` gains `allOf` flatten and inline-enum synthesis; `NameGiver` gains collision rename and acronym splitting. Emitters are untouched.

**Tech Stack:** Dart, `package:build`, `chopper`, `json_serializable`, `package:test`; FastAPI/Python mock for the round-trip.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Default (no-options) and existing 3.1 behavior must stay correct; the existing example (`resource_scheduler`) keeps generating cleanly.
- Out of scope: param-level inline enums, nested `allOf`, `oneOf`/`discriminator`, JSON Schema 3.1 keywords beyond nullability.

---

### Task 1: Resolver strategy and version factory

**Files:**
- Modify: `lib/src/resolve/dart_type_resolver.dart`
- Create: `lib/src/resolve/resolver_factory.dart`
- Modify: `test/resolve/dart_type_resolver_test.dart`
- Create: `test/resolve/resolver_factory_test.dart`
- Modify: `test/parser/spec_parser_test.dart` (the `_parser()` helper)
- Modify: `lib/src/builder/swagger_builder.dart` (`generateSources`)

**Interfaces:**
- Produces: abstract `DartTypeResolver` with `DartType resolve(Map)`, overridable `Map<String,dynamic> coreSchema(Map)` and `bool isNullable(Map)`; `OpenApi30TypeResolver`, `OpenApi31TypeResolver`; `DartTypeResolver resolverForVersion(String? version, NameGiver names)`.

- [ ] **Step 1: Update the existing resolver test to use the 3.1 subclass and add 3.0 cases**

In `test/resolve/dart_type_resolver_test.dart`, change the top instantiation from `DartTypeResolver(NameGiver())` to `OpenApi31TypeResolver(NameGiver())`, and append these tests inside `main()`:

```dart
  test('3.1 resolver maps type array with null to nullable', () {
    expect(
      OpenApi31TypeResolver(NameGiver())
          .resolve({
            'type': ['string', 'null'],
          })
          .display,
      'String?',
    );
  });

  test('3.0 resolver reads nullable true', () {
    final r = OpenApi30TypeResolver(NameGiver());
    expect(r.resolve({'type': 'string', 'nullable': true}).display, 'String?');
    expect(r.resolve({'type': 'string'}).display, 'String');
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/resolve/dart_type_resolver_test.dart`
Expected: FAIL (`OpenApi31TypeResolver`/`OpenApi30TypeResolver` undefined).

- [ ] **Step 3: Rewrite `lib/src/resolve/dart_type_resolver.dart`**

```dart
import '../ir/dart_type.dart';
import 'name_giver.dart';

/// Maps an OpenAPI schema node to a Dart type. Version-specific nullability and
/// type-form handling live in the subclasses; the shared core mapping lives
/// here.
abstract class DartTypeResolver {
  final NameGiver _names;

  DartTypeResolver(this._names);

  DartType resolve(Map<String, dynamic> schema) {
    final core = coreSchema(schema);
    final nullable = isNullable(schema);
    final inner = _resolveCore(core);
    return nullable || inner.isNullable
        ? DartType(inner.name, isNullable: true)
        : inner;
  }

  /// The non-null schema to resolve a type from (version-specific).
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema);

  /// Whether the schema is nullable (version-specific).
  bool isNullable(Map<String, dynamic> schema);

  DartType _resolveCore(Map<String, dynamic> schema) {
    final ref = schema[r'$ref'];
    if (ref is String) {
      return DartType(_names.className(ref.split('/').last));
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
      case 'object':
        final additional = schema['additionalProperties'];
        if (additional is Map) {
          final value = resolve(Map<String, dynamic>.from(additional));
          return DartType('Map<String, ${value.display}>');
        }
        return const DartType('Map<String, dynamic>');
      default:
        return const DartType('dynamic');
    }
  }
}

/// OpenAPI 3.0: nullability via `nullable: true`.
class OpenApi30TypeResolver extends DartTypeResolver {
  OpenApi30TypeResolver(super.names);

  @override
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema) => schema;

  @override
  bool isNullable(Map<String, dynamic> schema) => schema['nullable'] == true;
}

/// OpenAPI 3.1: nullability via `anyOf` null or a `type` array containing null.
class OpenApi31TypeResolver extends DartTypeResolver {
  OpenApi31TypeResolver(super.names);

  @override
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema) {
    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      final nonNull = anyOf
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((s) => s['type'] != 'null')
          .toList();
      return nonNull.length == 1 ? nonNull.single : const <String, dynamic>{};
    }
    final type = schema['type'];
    if (type is List) {
      final nonNull = type.where((t) => t != 'null').toList();
      return {
        ...schema,
        'type': nonNull.length == 1 ? nonNull.single : null,
      };
    }
    return schema;
  }

  @override
  bool isNullable(Map<String, dynamic> schema) {
    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      return anyOf.whereType<Map>().any((e) => e['type'] == 'null');
    }
    final type = schema['type'];
    if (type is List) return type.contains('null');
    return false;
  }
}
```

- [ ] **Step 4: Run the resolver test to verify it passes**

Run: `dart test test/resolve/dart_type_resolver_test.dart`
Expected: PASS (existing cases plus the two new ones).

- [ ] **Step 5: Create `lib/src/resolve/resolver_factory.dart`**

```dart
import 'dart_type_resolver.dart';
import 'name_giver.dart';

/// Selects a resolver from the spec's `openapi` version. Defaults to 3.1.
DartTypeResolver resolverForVersion(String? openApiVersion, NameGiver names) {
  if (openApiVersion != null && openApiVersion.startsWith('3.0')) {
    return OpenApi30TypeResolver(names);
  }
  return OpenApi31TypeResolver(names);
}
```

- [ ] **Step 6: Create `test/resolve/resolver_factory_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:swagger_generator_flutter/src/resolve/resolver_factory.dart';
import 'package:test/test.dart';

void main() {
  final names = NameGiver();

  test('selects the 3.0 resolver for 3.0.x', () {
    expect(resolverForVersion('3.0.2', names), isA<OpenApi30TypeResolver>());
  });

  test('selects the 3.1 resolver for 3.1.x and unknown', () {
    expect(resolverForVersion('3.1.0', names), isA<OpenApi31TypeResolver>());
    expect(resolverForVersion(null, names), isA<OpenApi31TypeResolver>());
  });
}
```

- [ ] **Step 7: Update the two direct instantiation sites**

In `test/parser/spec_parser_test.dart`, change the `_parser()` helper:

```dart
SpecParser _parser() {
  final names = NameGiver();
  return SpecParser(names, OpenApi31TypeResolver(names));
}
```

and add the import:

```dart
import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
```

In `lib/src/builder/swagger_builder.dart`, in `generateSources`, replace the resolver construction so it reads the version and uses the factory:

```dart
  final names = NameGiver();
  final loaded = SpecLoader().load(content, path: path);
  final resolver = resolverForVersion(loaded['openapi'] as String?, names);
  final spec = SpecParser(names, resolver).parse(loaded, name: baseName);
```

Update the imports in `swagger_builder.dart`: remove the
`dart_type_resolver.dart` import if now unused and add
`import '../resolve/resolver_factory.dart';` (keep the `name_giver.dart` import).

- [ ] **Step 8: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 9: Commit**

```bash
git add lib/src/resolve/ test/resolve/ test/parser/spec_parser_test.dart lib/src/builder/swagger_builder.dart
git commit -m "Add version-specific resolvers selected by a factory"
```

---

### Task 2: NameGiver collision rename and acronym splitting

**Files:**
- Modify: `lib/src/resolve/name_giver.dart`
- Modify: `test/resolve/name_giver_test.dart`

**Interfaces:**
- Produces: `className` splits uppercase runs (`APIRequest` -> `ApiRequest`) and appends `Model` when the result is a Chopper-reserved type name (`Field` -> `FieldModel`).

- [ ] **Step 1: Add failing tests to `test/resolve/name_giver_test.dart`**

Append inside `main()`:

```dart
  test('className splits acronym runs', () {
    expect(names.className('APIRequest'), 'ApiRequest');
    expect(names.className('HTTPValidationError'), 'HttpValidationError');
    expect(names.className('FullItem'), 'FullItem');
  });

  test('className renames Chopper-colliding names', () {
    expect(names.className('Field'), 'FieldModel');
    expect(names.className('Response'), 'ResponseModel');
    expect(names.className('Vault'), 'Vault');
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/resolve/name_giver_test.dart`
Expected: FAIL (`Apirequest` != `ApiRequest`; `Field` != `FieldModel`).

- [ ] **Step 3: Update `lib/src/resolve/name_giver.dart`**

Add the reserved set near `_reserved`:

```dart
const _chopperTypeNames = {
  'Field', 'Part', 'PartFile', 'Header', 'Body', 'Query', 'QueryMap',
  'Path', 'Response', 'Request', 'Tag', 'Method', 'Converter', 'Interceptor',
};
```

Replace `className` with:

```dart
  String className(String raw) {
    final name = _words(raw).map(_capitalize).join();
    return _chopperTypeNames.contains(name) ? '${name}Model' : name;
  }
```

Replace `_words` so it also splits an uppercase run that precedes a capitalized
word:

```dart
  List<String> _words(String raw) {
    final spaced = raw
        .replaceAllMapped(
          RegExp('([A-Z]+)([A-Z][a-z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAllMapped(
          RegExp('([a-z0-9])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAll(RegExp('[^a-zA-Z0-9]+'), ' ');
    return spaced
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/resolve/name_giver_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/resolve/name_giver.dart test/resolve/name_giver_test.dart
git commit -m "Rename Chopper-colliding class names and split acronym runs"
```

---

### Task 3: allOf flatten in the parser

**Files:**
- Modify: `lib/src/parser/spec_parser.dart`
- Test: `test/parser/spec_parser_test.dart`

**Interfaces:**
- Consumes: the `schemas` map, the existing `_model` field-building.
- Produces: a schema with `allOf` is classified as a model whose fields are the merged properties (with merged `required`) of all members, resolving `$ref` members to their target schema.

- [ ] **Step 1: Add a failing test to `test/parser/spec_parser_test.dart`**

```dart
  test('flattens allOf into a single model', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'required': ['id'],
            'properties': {
              'id': {'type': 'string'},
              'title': {'type': 'string'},
            },
          },
          'FullItem': {
            'allOf': [
              {r'$ref': '#/components/schemas/Item'},
              {
                'type': 'object',
                'properties': {
                  'sections': {'type': 'string'},
                },
              },
            ],
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final full = spec.models.firstWhere((m) => m.name == 'FullItem');
    final keys = full.fields.map((f) => f.jsonKey).toSet();
    expect(keys, containsAll(<String>['id', 'title', 'sections']));
    expect(full.fields.firstWhere((f) => f.jsonKey == 'id').isRequired, isTrue);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: FAIL (`FullItem` not in models - allOf currently skipped).

- [ ] **Step 3: Handle allOf in `lib/src/parser/spec_parser.dart`**

In `parse`, broaden the classification so allOf schemas count as models. Change
the classification loop's model condition:

```dart
      if (schema['enum'] is List) {
        enums.add(_enum(entry.key, schema));
      } else if (schema['allOf'] is List ||
          schema['type'] == 'object' ||
          schema['properties'] is Map) {
        models.add(_model(entry.key, schema, enumNames: enumNames));
      }
```

Also add allOf names to the early enum/model name pass is not needed; only the
classification changes. In `_model`, compute merged properties/required before
building fields:

```dart
  ModelDef _model(
    String rawName,
    Map<String, dynamic> schema, {
    Set<String> enumNames = const {},
  }) {
    final merged = _mergedObject(schema);
    final required = merged.required;
    final properties = merged.properties;
    final fields = <FieldDef>[];

    for (final entry in properties.entries) {
      final propSchema = (entry.value as Map).cast<String, dynamic>();
      final type = _resolver.resolve(propSchema);
      fields.add(FieldDef(
        dartName: _names.memberName(entry.key),
        jsonKey: entry.key,
        type: type,
        isRequired: required.contains(entry.key),
        defaultValue: _defaultLiteral(
          propSchema['default'],
          typeName: type.name,
          enumNames: enumNames,
        ),
      ));
    }

    return ModelDef(name: _names.className(rawName), fields: fields);
  }

  ({Map<String, dynamic> properties, List<String> required}) _mergedObject(
    Map<String, dynamic> schema,
  ) {
    final allOf = schema['allOf'];
    if (allOf is! List) {
      return (
        properties:
            (schema['properties'] as Map?)?.cast<String, dynamic>() ?? const {},
        required:
            (schema['required'] as List?)?.cast<String>() ?? const <String>[],
      );
    }

    final properties = <String, dynamic>{};
    final required = <String>[];
    for (final raw in allOf) {
      if (raw is! Map) continue;
      var member = raw.cast<String, dynamic>();
      final ref = member[r'$ref'];
      if (ref is String) {
        final target = _schemasCache[ref.split('/').last];
        if (target is Map<String, dynamic>) member = target;
      }
      properties.addAll(
        (member['properties'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
      required.addAll(
        (member['required'] as List?)?.cast<String>() ?? const <String>[],
      );
    }
    return (properties: properties, required: required);
  }
```

To let `_mergedObject` resolve `$ref` members, store the schemas map on the
parser. Add a field and set it in `parse`:

```dart
  Map<String, dynamic> _schemasCache = const {};
```

and at the start of `parse`, after computing `schemas`:

```dart
    _schemasCache = schemas;
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: PASS (existing parser tests plus the allOf one).

- [ ] **Step 5: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/parser/spec_parser.dart test/parser/spec_parser_test.dart
git commit -m "Flatten allOf schemas into a single model"
```

---

### Task 4: Inline-enum synthesis in the parser

**Files:**
- Modify: `lib/src/parser/spec_parser.dart`
- Test: `test/parser/spec_parser_test.dart`

**Interfaces:**
- Consumes: `_model`, the `enums`/`enumNames` collections, `_resolver.isNullable`.
- Produces: a model field whose schema has an inline `enum` (and no `$ref`) yields a synthesized `EnumDef` named `className('<Model> <field>')` added to the spec, and the field is typed as that enum (nullable per the resolver). An inline-enum default becomes `<EnumName>.<member>`.

- [ ] **Step 1: Add a failing test to `test/parser/spec_parser_test.dart`**

```dart
  test('synthesizes a named enum for an inline-enum field', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'properties': {
              'category': {
                'type': 'string',
                'enum': ['LOGIN', 'PASSWORD'],
                'default': 'LOGIN',
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final itemEnum = spec.enums.firstWhere((e) => e.name == 'ItemCategory');
    expect(itemEnum.values.map((v) => v.jsonValue), ['LOGIN', 'PASSWORD']);

    final field = spec.models.single.fields.single;
    expect(field.type.name, 'ItemCategory');
    expect(field.defaultValue, 'ItemCategory.login');
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: FAIL (no `ItemCategory` enum; field is `String`).

- [ ] **Step 3: Thread the enum collections into `_model` and synthesize inline enums**

In `parse`, pass the mutable `enums` list and `enumNames` set into `_model`:

```dart
      } else if (schema['allOf'] is List ||
          schema['type'] == 'object' ||
          schema['properties'] is Map) {
        models.add(_model(
          entry.key,
          schema,
          enums: enums,
          enumNames: enumNames,
        ));
      }
```

Change `_model`'s signature and the per-field logic so an inline-enum property
synthesizes an enum:

```dart
  ModelDef _model(
    String rawName,
    Map<String, dynamic> schema, {
    required List<EnumDef> enums,
    required Set<String> enumNames,
  }) {
    final merged = _mergedObject(schema);
    final required = merged.required;
    final properties = merged.properties;
    final fields = <FieldDef>[];

    for (final entry in properties.entries) {
      final propSchema = (entry.value as Map).cast<String, dynamic>();
      final DartType type;
      if (propSchema['enum'] is List && propSchema[r'$ref'] == null) {
        final enumName = _names.className('$rawName ${entry.key}');
        if (!enumNames.contains(enumName)) {
          enums.add(EnumDef(
            name: enumName,
            values: (propSchema['enum'] as List)
                .map((v) => EnumValueDef(
                      dartName: _names.enumValueName(v.toString()),
                      jsonValue: v.toString(),
                    ))
                .toList(),
          ));
          enumNames.add(enumName);
        }
        type = DartType(enumName, isNullable: _resolver.isNullable(propSchema));
      } else {
        type = _resolver.resolve(propSchema);
      }
      fields.add(FieldDef(
        dartName: _names.memberName(entry.key),
        jsonKey: entry.key,
        type: type,
        isRequired: required.contains(entry.key),
        defaultValue: _defaultLiteral(
          propSchema['default'],
          typeName: type.name,
          enumNames: enumNames,
        ),
      ));
    }

    return ModelDef(name: _names.className(rawName), fields: fields);
  }
```

(The `enumNames` set now contains the synthesized name before `_defaultLiteral`
runs, so an inline-enum default is formatted as `<EnumName>.<member>`.)

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/parser/spec_parser.dart test/parser/spec_parser_test.dart
git commit -m "Synthesize named enums for inline-enum fields"
```

---

### Task 5: Regenerate the 1Password spec and round-trip a few paths

Prove the real spec generates clean and that a model round-trips. Verification
only - no package changes committed; the temporary mock and generated files are
removed.

**Files:**
- None committed. Temporary: a mock server script, generated `example/lib/newapi.*`, `example/bin/newapi_check.dart`.

**Interfaces:**
- Consumes: Tasks 1-4 and `example/lib/newapi.openapi.json`.

- [ ] **Step 1: Regenerate and confirm the generated code analyzes clean**

From the repo root:
```bash
cd example && dart run build_runner build && flutter analyze 2>&1 | grep -i newapi || echo "newapi clean"
cd ..
```
Expected: `newapi clean` (no `newapi.*` errors). Confirm the gaps are gone:
```bash
grep -c "^enum " example/lib/newapi.enums.dart
grep -E "class FullItem|class Patch|class FieldModel" example/lib/newapi.models.dart
```
Expected: a non-zero enum count, and `FullItem`, `Patch`, `FieldModel` present.
If any `newapi.*` analyzer error remains, identify the construct, add a focused
failing unit test in the owning unit (resolver/parser/name_giver), fix it,
re-run `dart test` and `dart analyze`, regenerate, and repeat.

- [ ] **Step 2: Write a minimal mock server `example/tool/mock_1password.py`**

```python
import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def _send(self, payload):
        body = json.dumps(payload).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/vaults":
            self._send([
                {"id": "v1", "name": "Personal", "type": "PERSONAL"},
            ])
        else:
            self._send({})

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        item = json.loads(self.rfile.read(length) or b"{}")
        item["id"] = "generated-id"
        item["version"] = (item.get("version") or 0) + 1
        self._send(item)

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
```

- [ ] **Step 3: Start the mock and confirm it responds**

Run from the repo root in the background:
```bash
python3 example/tool/mock_1password.py
```
Confirm:
```bash
curl -s --retry 8 --retry-connrefused --retry-delay 1 http://localhost:8000/vaults
```
Expected: a JSON array with one vault (`"type":"PERSONAL"`).

- [ ] **Step 4: Write the consumer `example/bin/newapi_check.dart`**

Discover the exact service class and method names first:
```bash
grep -E "abstract class|Future<Response" example/lib/newapi.service.dart
```
Then write the consumer using those names. Template (adjust names to match):

```dart
import 'package:chopper/chopper.dart';
import 'package:example/newapi.api.dart';

Future<void> main() async {
  final client = createClient(baseUrl: Uri.parse('http://localhost:8000'));
  final service = <ServiceClass>.create(client);

  final vaults = await service.<getVaultsMethod>();
  print('vaults -> ${vaults.statusCode}, list of Vault: '
      '${vaults.body is List<Vault>}');
  if (vaults.body is! List<Vault>) {
    throw StateError('vault list did not deserialize: ${vaults.body.runtimeType}');
  }

  final created = await service.<createItemMethod>('v1', FullItem(/* required fields */));
  print('create -> ${created.statusCode}, is FullItem: ${created.body is FullItem}');
  final item = created.body;
  if (item is! FullItem) {
    throw StateError('item did not deserialize: ${created.body.runtimeType}');
  }
  print('  round-trip: id=${item.id} version=${item.version}');

  client.dispose();
  print('RUNTIME OK');
}
```

Fill the `FullItem(...)` constructor with whatever required fields the generated
class declares (read `example/lib/newapi.models.dart`). The mock sets `id` to
`generated-id` and bumps `version`, so the returned typed `FullItem` proves the
model-in -> json -> modified -> model-out loop.

- [ ] **Step 5: Run the consumer**

Run from `example/`:
```bash
dart run bin/newapi_check.dart
```
Expected: prints `list of Vault: true`, `is FullItem: true`, the bumped
`version`, and `RUNTIME OK`, no exception. If a type fails to deserialize, the
converter/model for that type has a remaining gap - capture it, fix the owning
generator unit with a failing test, regenerate, and repeat.

- [ ] **Step 6: Tear down**

Run from the repo root:
```bash
pkill -f mock_1password.py
rm -f example/lib/newapi.* example/bin/newapi_check.dart example/tool/mock_1password.py
rmdir example/bin example/tool 2>/dev/null
cd example && dart run build_runner build >/dev/null 2>&1 && cd ..
git checkout -- example/
git status --short
```
Expected: `git status --short` shows no `example/` changes. (`example/lib/newapi.openapi.json` is currently untracked; decide separately whether to keep it.)

- [ ] **Step 7: Record the result**

No commit. The deliverable is the verified `RUNTIME OK` plus the clean
`flutter analyze` from Step 1.

---

## Notes for the implementer

- The resolver split keeps `SpecParser` unchanged structurally; it just receives a different resolver. `_resolveCore` recurses through `resolve`, so nested array/object nullability stays version-aware.
- `_mergedObject` handles one level of `allOf`; a member that is itself `allOf` is out of scope.
- Inline-enum synthesis adds to the same `enums`/`enumNames` the named-enum pass uses, so defaults referencing the synthesized enum resolve correctly.
- `example/lib/newapi.openapi.json` already exists (the input). Leave it in place; only the generated `newapi.*` Dart files are temporary.
