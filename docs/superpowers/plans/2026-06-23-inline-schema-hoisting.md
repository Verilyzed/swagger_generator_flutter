# Inline Schema Hoisting and Non-JSON Responses Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate typed models for inline (anonymous) object/enum schemas wherever they appear, and resolve responses/bodies from any content type, by normalizing the spec with a hoisting pre-pass before the existing pipeline runs.

**Architecture:** A new `SchemaHoister` walks a deep copy of the loaded spec and lifts every inline object/enum in a type position into `components/schemas` under a generated name, replacing it in place with a `$ref`. The parser then handles everything as named schemas; its inline-enum special case is removed (the hoister subsumes it), and response/body extraction is generalized beyond `application/json`.

**Tech Stack:** Dart, `package:build`, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- The hoister works on a deep copy; the input spec map is not mutated.
- Generated names use `NameGiver.className` and are unique (numeric suffix on collision).
- Existing behavior preserved: a bare `object` (no `properties`), `additionalProperties` maps, primitives, `$ref`s, and top-level named schemas are not hoisted.
- Out of scope: parameter-schema hoisting, `oneOf`/`discriminator`.

---

### Task 1: SchemaHoister

**Files:**
- Create: `lib/src/parser/schema_hoister.dart`
- Test: `test/parser/schema_hoister_test.dart`

**Interfaces:**
- Consumes: `NameGiver.className`.
- Produces: `SchemaHoister(NameGiver names)` with `Map<String, dynamic> hoist(Map<String, dynamic> spec)` returning a normalized deep copy.

- [ ] **Step 1: Write the failing test `test/parser/schema_hoister_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/parser/schema_hoister.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

SchemaHoister _hoister() => SchemaHoister(NameGiver());

void main() {
  test('hoists an inline response object to <OperationId>Response', () {
    final out = _hoister().hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/health': {
          'get': {
            'operationId': 'getServerHealth',
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'name': {'type': 'string'},
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    });

    final schema = out['components']['schemas']['GetServerHealthResponse'];
    expect(schema['properties'].containsKey('name'), isTrue);
    expect(
      out['paths']['/health']['get']['responses']['200']['content']
          ['application/json']['schema'],
      {r'$ref': '#/components/schemas/GetServerHealthResponse'},
    );
  });

  test('hoists an inline request body to <OperationId>Request', () {
    final out = _hoister().hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/x': {
          'post': {
            'operationId': 'createX',
            'requestBody': {
              'content': {
                'application/json': {
                  'schema': {
                    'type': 'object',
                    'properties': {
                      'a': {'type': 'string'},
                    },
                  },
                },
              },
            },
          },
        },
      },
    });

    expect(
      out['components']['schemas'].containsKey('CreateXRequest'),
      isTrue,
    );
  });

  test('hoists a nested property object and recurses', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'properties': {
              'recipe': {
                'type': 'object',
                'properties': {
                  'length': {'type': 'integer'},
                },
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final schemas = out['components']['schemas'] as Map;
    expect(schemas.containsKey('ItemRecipe'), isTrue);
    expect(
      (schemas['Item']['properties'] as Map)['recipe'],
      {r'$ref': '#/components/schemas/ItemRecipe'},
    );
  });

  test('hoists an inline enum and keeps a default on the ref', () {
    final out = _hoister().hoist({
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
    });

    final schemas = out['components']['schemas'] as Map;
    expect(schemas['ItemCategory']['enum'], ['LOGIN', 'PASSWORD']);
    expect((schemas['Item']['properties'] as Map)['category'], {
      r'$ref': '#/components/schemas/ItemCategory',
      'default': 'LOGIN',
    });
  });

  test('hoists an array items object to <Context>Item', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'Patch': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'op': {'type': 'string'},
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final schemas = out['components']['schemas'] as Map;
    expect(schemas.containsKey('PatchItem'), isTrue);
    expect(schemas['Patch']['items'], {r'$ref': '#/components/schemas/PatchItem'});
  });

  test('de-duplicates a generated name that already exists', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'ItemRecipe': {'type': 'string'},
          'Item': {
            'type': 'object',
            'properties': {
              'recipe': {
                'type': 'object',
                'properties': {
                  'length': {'type': 'integer'},
                },
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final schemas = out['components']['schemas'] as Map;
    expect(schemas.containsKey('ItemRecipe2'), isTrue);
    expect((schemas['Item']['properties'] as Map)['recipe'],
        {r'$ref': '#/components/schemas/ItemRecipe2'});
  });

  test('leaves refs, additionalProperties, and bare objects untouched', () {
    final input = {
      'components': {
        'schemas': {
          'A': {
            'type': 'object',
            'properties': {
              'ref': {r'$ref': '#/components/schemas/B'},
              'map': {
                'type': 'object',
                'additionalProperties': {'type': 'string'},
              },
              'bare': {'type': 'object'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    };
    final out = _hoister().hoist(input);
    final props = out['components']['schemas']['A']['properties'] as Map;
    expect(props['ref'], {r'$ref': '#/components/schemas/B'});
    expect(props['map']['additionalProperties'], {'type': 'string'});
    expect(props['bare'], {'type': 'object'});
    // input not mutated
    expect(
      (input['components'] as Map)['schemas'],
      isNot(contains('AMap')),
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/schema_hoister_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/parser/schema_hoister.dart`**

```dart
import 'dart:convert';

import '../resolve/name_giver.dart';

/// Lifts inline (anonymous) object and enum schemas into named entries under
/// `components/schemas`, replacing each in place with a `$ref`. The rest of the
/// pipeline then treats them like any other named schema.
class SchemaHoister {
  final NameGiver _names;

  SchemaHoister(this._names);

  Map<String, dynamic> hoist(Map<String, dynamic> spec) {
    final copy = (jsonDecode(jsonEncode(spec)) as Map).cast<String, dynamic>();

    final components =
        (copy['components'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final schemas =
        (components['schemas'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    components['schemas'] = schemas;
    copy['components'] = components;

    final used = schemas.keys.toSet();

    for (final key in schemas.keys.toList()) {
      final schema = schemas[key];
      if (schema is Map<String, dynamic>) {
        _hoistChildren(schema, key, schemas, used);
      }
    }

    final paths = (copy['paths'] as Map?)?.cast<String, dynamic>();
    if (paths != null) {
      for (final pathItem in paths.values) {
        if (pathItem is! Map) continue;
        for (final op in pathItem.values) {
          if (op is Map) {
            _hoistOperation(op.cast<String, dynamic>(), schemas, used);
          }
        }
      }
    }

    return copy;
  }

  void _hoistOperation(
    Map<String, dynamic> op,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final opId = (op['operationId'] as String?) ?? 'operation';

    final requestBody = op['requestBody'];
    if (requestBody is Map) {
      _hoistContent(
        requestBody.cast<String, dynamic>(),
        '$opId request',
        schemas,
        used,
      );
    }

    final responses = op['responses'];
    if (responses is Map) {
      for (final response in responses.values) {
        if (response is Map) {
          _hoistContent(
            response.cast<String, dynamic>(),
            '$opId response',
            schemas,
            used,
          );
        }
      }
    }
  }

  void _hoistContent(
    Map<String, dynamic> container,
    String name,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final content = container['content'];
    if (content is! Map) return;
    for (final media in content.values) {
      if (media is! Map) continue;
      final mediaMap = media.cast<String, dynamic>();
      final schema = mediaMap['schema'];
      if (schema is Map) {
        mediaMap['schema'] = _hoistType(
          schema.cast<String, dynamic>(),
          name,
          schemas,
          used,
        );
      }
    }
  }

  dynamic _hoistType(
    Map<String, dynamic> schema,
    String name,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    if (schema.containsKey(r'$ref')) return schema;

    _hoistChildren(schema, name, schemas, used);

    final isObject = schema['properties'] is Map;
    final isEnum = schema['enum'] is List;
    if (!isObject && !isEnum) return schema;

    final key = _uniqueName(name, used);
    final defaultValue = schema.remove('default');
    schemas[key] = schema;
    final ref = <String, dynamic>{r'$ref': '#/components/schemas/$key'};
    if (defaultValue != null) ref['default'] = defaultValue;
    return ref;
  }

  void _hoistChildren(
    Map<String, dynamic> schema,
    String name,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final properties = schema['properties'];
    if (properties is Map) {
      final props = properties.cast<String, dynamic>();
      for (final key in props.keys.toList()) {
        final value = props[key];
        if (value is Map) {
          props[key] = _hoistType(
            value.cast<String, dynamic>(),
            '$name $key',
            schemas,
            used,
          );
        }
      }
    }

    final items = schema['items'];
    if (items is Map) {
      schema['items'] = _hoistType(
        items.cast<String, dynamic>(),
        '$name item',
        schemas,
        used,
      );
    }

    final allOf = schema['allOf'];
    if (allOf is List) {
      for (final member in allOf) {
        if (member is Map) {
          _hoistChildren(member.cast<String, dynamic>(), name, schemas, used);
        }
      }
    }
  }

  String _uniqueName(String rawName, Set<String> used) {
    final base = _names.className(rawName);
    var name = base;
    var counter = 2;
    while (used.contains(name)) {
      name = '$base$counter';
      counter++;
    }
    used.add(name);
    return name;
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/parser/schema_hoister_test.dart`
Expected: PASS (7 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/parser/schema_hoister.dart test/parser/schema_hoister_test.dart
git commit -m "Add SchemaHoister to lift inline schemas into named ones"
```

---

### Task 2: Integrate the hoister and generalize content extraction

**Files:**
- Modify: `lib/src/parser/spec_parser.dart`
- Modify: `lib/src/builder/swagger_builder.dart`
- Modify: `test/parser/spec_parser_test.dart`

**Interfaces:**
- Consumes: `SchemaHoister` (Task 1).
- Produces: `generateSources` hoists before parsing; `SpecParser._model` no longer synthesizes inline enums (the `enums` parameter is dropped, `enumNames` stays for defaults); `_jsonSchema` becomes `_contentSchema` (prefers `application/json`, else the first content type).

- [ ] **Step 1: Replace the inline-enum parser test with ref-to-enum and text/plain tests**

In `test/parser/spec_parser_test.dart`, replace the test named
`'synthesizes a named enum for an inline-enum field'` with these two tests:

```dart
  test('formats an enum default from a ref-to-enum field', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'ItemCategory': {
            'type': 'string',
            'enum': ['LOGIN', 'PASSWORD'],
          },
          'Item': {
            'type': 'object',
            'properties': {
              'category': {
                r'$ref': '#/components/schemas/ItemCategory',
                'default': 'LOGIN',
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final field =
        spec.models.firstWhere((m) => m.name == 'Item').fields.single;
    expect(field.type.name, 'ItemCategory');
    expect(field.defaultValue, 'ItemCategory.login');
  });

  test('resolves a text/plain response as its schema type', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/heartbeat': {
          'get': {
            'operationId': 'getHeartbeat',
            'responses': {
              '200': {
                'content': {
                  'text/plain': {
                    'schema': {'type': 'string'},
                  },
                },
              },
            },
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.responseType.display, 'String');
  });
```

- [ ] **Step 2: Run the parser test to verify the new ones fail**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: FAIL (`resolves a text/plain response` fails - `_jsonSchema` ignores `text/plain`; the ref-to-enum test passes already, that is fine).

- [ ] **Step 3: Remove inline-enum synthesis from `_model` in `lib/src/parser/spec_parser.dart`**

Change the `_model` signature to drop the `enums` parameter:

```dart
  ModelDef _model(
    String rawName,
    Map<String, dynamic> schema, {
    required Set<String> enumNames,
  }) {
```

Replace the per-property type block (the `if (propSchema['enum'] is List ...)`
branch) with a plain resolve:

```dart
    for (final entry in properties.entries) {
      final propSchema = (entry.value as Map).cast<String, dynamic>();
      final type = _resolver.resolve(propSchema);
      final isRequired = required.contains(entry.key);
      final defaultValue = _defaultLiteral(
        propSchema['default'],
        typeName: type.name,
        enumNames: enumNames,
      );
      final fieldType = !isRequired &&
              defaultValue == null &&
              !type.isNullable &&
              type.name != 'dynamic'
          ? DartType(type.name, isNullable: true)
          : type;
      fields.add(FieldDef(
        dartName: _names.memberName(entry.key),
        jsonKey: entry.key,
        type: fieldType,
        isRequired: isRequired,
        defaultValue: defaultValue,
      ));
    }
```

Update the `_model` call in `parse` to drop `enums`:

```dart
        models.add(_model(
          entry.key,
          schema,
          enumNames: enumNames,
        ));
```

- [ ] **Step 4: Generalize `_jsonSchema` to `_contentSchema`**

Replace the `_jsonSchema` method with:

```dart
  Map<String, dynamic>? _contentSchema(Map<String, dynamic>? container) {
    final content = (container?['content'] as Map?)?.cast<String, dynamic>();
    if (content == null || content.isEmpty) return null;
    final media = content['application/json'] ?? content.values.first;
    final schema = (media as Map?)?['schema'];
    return schema is Map ? schema.cast<String, dynamic>() : null;
  }
```

Update the two call sites in `_operation` (the request body and the `200`
response) to call `_contentSchema` instead of `_jsonSchema`.

- [ ] **Step 5: Wire the hoister into `generateSources` in `lib/src/builder/swagger_builder.dart`**

Add the import:

```dart
import '../parser/schema_hoister.dart';
```

Replace the loading block in `generateSources` so it hoists first:

```dart
  final names = NameGiver();
  final loaded = SpecLoader().load(content, path: path);
  final normalized = SchemaHoister(names).hoist(loaded);
  final schemas =
      ((normalized['components'] as Map?)?['schemas'] as Map?)
          ?.cast<String, dynamic>() ??
      const {};
  final resolver = resolverForVersion(
    normalized['openapi'] as String?,
    names,
    schemas: schemas,
  );
  final spec = SpecParser(names, resolver).parse(normalized, name: baseName);
```

- [ ] **Step 6: Run the parser test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 7: Commit**

```bash
git add lib/src/parser/spec_parser.dart lib/src/builder/swagger_builder.dart test/parser/spec_parser_test.dart
git commit -m "Hoist inline schemas before parsing and resolve any content type"
```

---

### Task 3: Regenerate the 1Password spec and round-trip

Verification only - no example changes committed beyond the regenerated output
the user keeps tracked.

**Files:**
- None new committed. Temporary mock + consumer, reverted.

**Interfaces:**
- Consumes: Tasks 1-2 and `example/lib/specs/newapi.openapi.json`.

- [ ] **Step 1: Regenerate and confirm clean, typed output**

From the repo root:
```bash
cd example && dart run build_runner build && flutter analyze 2>&1 | grep -i newapi || echo "newapi clean"
cd ..
```
Expected: `newapi clean`. Confirm the new models and types:
```bash
grep -E "class GetServerHealthResponse|class PatchItem" example/lib/generated/newapi.models.dart
grep "Future<Response<GetServerHealthResponse>> getServerHealth" example/lib/generated/newapi.service.dart
grep "Future<Response<String>> getHeartbeat" example/lib/generated/newapi.service.dart
```
Expected: `GetServerHealthResponse` is a model, `getServerHealth` returns it, and `getHeartbeat` returns `Response<String>`. If any `newapi.*` analyzer error remains, fix the owning unit (hoister/parser) with a failing test first, regenerate, and repeat.

- [ ] **Step 2: Start a mock for the two endpoints**

Create `example/tool/mock_health.py`:
```python
import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            body = json.dumps({"name": "connect", "version": "1.0"}).encode()
            ctype = "application/json"
        else:
            body = b"."
            ctype = "text/plain"
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
```
Run it in the background from the repo root:
```bash
python3 example/tool/mock_health.py
```
Confirm:
```bash
curl -s --retry 8 --retry-connrefused --retry-delay 1 http://localhost:8000/health
curl -s http://localhost:8000/heartbeat
```
Expected: a JSON object for `/health` and `.` for `/heartbeat`.

- [ ] **Step 3: Write the consumer `example/bin/health_check.dart`**

Confirm method names first:
```bash
grep -E "getServerHealth|getHeartbeat" example/lib/generated/newapi.service.dart
```
Then:
```dart
import 'package:chopper/chopper.dart';
import 'package:example/generated/newapi.api.dart';

Future<void> main() async {
  final client = createClient(baseUrl: Uri.parse('http://localhost:8000'));
  final service = NewapiService.create(client);

  final health = await service.getServerHealth();
  print('health -> ${health.statusCode}, is GetServerHealthResponse: '
      '${health.body is GetServerHealthResponse}');
  if (health.body is! GetServerHealthResponse) {
    throw StateError('health did not deserialize: ${health.body.runtimeType}');
  }
  print('  name=${(health.body as GetServerHealthResponse).name}');

  final beat = await service.getHeartbeat();
  print('heartbeat -> ${beat.statusCode}, body is String: '
      '${beat.body is String}');
  if (beat.body is! String) {
    throw StateError('heartbeat did not deserialize: ${beat.body.runtimeType}');
  }

  client.dispose();
  print('RUNTIME OK');
}
```
(The barrel import is `package:example/generated/newapi.api.dart` because output
is in `lib/generated/`.)

- [ ] **Step 4: Run the consumer**

Run from `example/`:
```bash
dart run bin/health_check.dart
```
Expected: prints `is GetServerHealthResponse: true`, `body is String: true`, and
`RUNTIME OK`. If `getHeartbeat` throws on a non-JSON body, the converter is
decoding plain text - capture it and fix the `ClientEmitter` converter (skip
`jsonDecode` for non-JSON), with a failing emitter test, regenerate, and repeat.

- [ ] **Step 5: Tear down**

From the repo root:
```bash
pkill -f mock_health.py
rm -f example/bin/health_check.dart example/tool/mock_health.py
rmdir example/bin example/tool 2>/dev/null
cd example && dart run build_runner build >/dev/null 2>&1 && cd ..
git add example/lib/generated
git status --short
```
Expected: `example/lib/generated` reflects the new typed output (committed with
the example), and no stray mock/consumer files remain.

- [ ] **Step 6: Commit the regenerated example output**

```bash
git add example/lib/generated
git commit -m "Regenerate example with typed inline-object and text responses"
```

---

## Notes for the implementer

- The hoister recurses into a node's children before deciding to hoist the node, so nested inline schemas get their own names with the parent name as prefix.
- `allOf` members are recursed into (their nested inline schemas are hoisted) but never hoisted themselves, since the parser flattens them.
- After hoisting, an inline enum becomes a named enum schema, so the parser's existing enum classification and `enumNames`-based default formatting handle it - that is why the inline-enum branch is removed from `_model`.
- `getServerHealth`'s operationId in the spec is `GetServerHealth`; `className('GetServerHealth response')` yields `GetServerHealthResponse`.
