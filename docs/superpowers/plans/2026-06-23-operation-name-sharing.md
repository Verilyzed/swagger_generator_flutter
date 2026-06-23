# Shared Operation Naming Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Name hoisted request/response models with the same rule as method names, via one shared `operationBaseName` helper, so `Operation...` names disappear and `method_names: path` is honored.

**Architecture:** A new `operationBaseName` helper is the single source of truth; `SpecParser` uses it for method names and `SchemaHoister` uses it (with the path and verb, plus a `nameFromPath` flag) for request/response model names.

**Tech Stack:** Dart, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Behavior with an `operationId` and default naming is unchanged.

---

### Task 1: Shared operationBaseName helper, used by the parser

**Files:**
- Create: `lib/src/parser/operation_name.dart`
- Modify: `lib/src/parser/spec_parser.dart`
- Test: `test/parser/operation_name_test.dart`

**Interfaces:**
- Produces: `String operationBaseName({required String httpMethod, required String path, String? operationId, required bool nameFromPath})`.

- [ ] **Step 1: Write the failing test `test/parser/operation_name_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/parser/operation_name.dart';
import 'package:test/test.dart';

void main() {
  test('uses operationId by default', () {
    expect(
      operationBaseName(
        httpMethod: 'GET',
        path: '/x',
        operationId: 'getX',
        nameFromPath: false,
      ),
      'getX',
    );
  });

  test('falls back to verb and path without an operationId', () {
    expect(
      operationBaseName(
        httpMethod: 'POST',
        path: '/x/{id}',
        operationId: null,
        nameFromPath: false,
      ),
      'post_/x/{id}',
    );
  });

  test('uses verb and path when nameFromPath is true', () {
    expect(
      operationBaseName(
        httpMethod: 'GET',
        path: '/x',
        operationId: 'getX',
        nameFromPath: true,
      ),
      'get_/x',
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/operation_name_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/parser/operation_name.dart`**

```dart
/// The raw name an operation is derived from, before identifier formatting.
///
/// Shared by the method-name path (`memberName`) and the hoisted request and
/// response model names (`className`), so both stay in sync.
String operationBaseName({
  required String httpMethod,
  required String path,
  String? operationId,
  required bool nameFromPath,
}) =>
    nameFromPath
        ? '${httpMethod.toLowerCase()}_$path'
        : operationId ?? '${httpMethod.toLowerCase()}_$path';
```

- [ ] **Step 4: Use the helper in `lib/src/parser/spec_parser.dart`**

Add the import:

```dart
import 'operation_name.dart';
```

Replace the `methodName` argument in `_operation`:

```dart
      methodName: _names.memberName(
        operationBaseName(
          httpMethod: httpMethod,
          path: path,
          operationId: op['operationId'] as String?,
          nameFromPath: _nameFromPath,
        ),
      ),
```

- [ ] **Step 5: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS (including the existing method-name tests), "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/parser/operation_name.dart lib/src/parser/spec_parser.dart test/parser/operation_name_test.dart
git commit -m "Extract operationBaseName and use it for method names"
```

---

### Task 2: Hoister names models from the operation

**Files:**
- Modify: `lib/src/parser/schema_hoister.dart`
- Modify: `lib/src/builder/swagger_builder.dart`
- Test: `test/parser/schema_hoister_test.dart`

**Interfaces:**
- Consumes: `operationBaseName` (Task 1).
- Produces: `SchemaHoister(NameGiver, {bool nameFromPath = false})`; hoisted request/response models are named from the operation (operationId or path) instead of `operation`.

- [ ] **Step 1: Add failing tests to `test/parser/schema_hoister_test.dart`**

```dart
  test('names a hoisted response model from the path without an operationId', () {
    final out = _hoister().hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/vaults/{vaultUuid}/items': {
          'post': {
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'id': {'type': 'string'},
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

    expect(_schemas(out), contains('PostVaultsVaultUuidItemsResponse'));
    expect(_schemas(out), isNot(contains('OperationResponse')));
  });

  test('names a hoisted model from the path when nameFromPath is true', () {
    final out = SchemaHoister(NameGiver(), nameFromPath: true).hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/health': {
          'get': {
            'operationId': 'GetServerHealth',
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

    expect(_schemas(out), contains('GetHealthResponse'));
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/schema_hoister_test.dart`
Expected: FAIL (model named `OperationResponse`; `nameFromPath` not accepted).

- [ ] **Step 3: Add `nameFromPath` and the path/verb to `lib/src/parser/schema_hoister.dart`**

Add the import:

```dart
import 'operation_name.dart';
```

Change the field and constructor:

```dart
  final NameGiver _names;
  final bool _nameFromPath;

  SchemaHoister(this._names, {bool nameFromPath = false})
      : _nameFromPath = nameFromPath;
```

Change the paths loop in `hoist` to pass the path and verb:

```dart
    final paths = (copy['paths'] as Map?)?.cast<String, dynamic>();
    if (paths != null) {
      for (final pathEntry in paths.entries) {
        final pathItem = pathEntry.value;
        if (pathItem is! Map) continue;
        for (final opEntry in pathItem.cast<String, dynamic>().entries) {
          final op = opEntry.value;
          if (op is Map) {
            _hoistOperation(
              op.cast<String, dynamic>(),
              pathEntry.key,
              opEntry.key,
              schemas,
              used,
            );
          }
        }
      }
    }
```

Change `_hoistOperation` to compute the base name from the operation:

```dart
  void _hoistOperation(
    Map<String, dynamic> op,
    String path,
    String httpMethod,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final base = operationBaseName(
      httpMethod: httpMethod,
      path: path,
      operationId: op['operationId'] as String?,
      nameFromPath: _nameFromPath,
    );

    final requestBody = op['requestBody'];
    if (requestBody is Map) {
      _hoistContent(
        requestBody.cast<String, dynamic>(),
        '$base request',
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
            '$base response',
            schemas,
            used,
          );
        }
      }
    }
  }
```

- [ ] **Step 4: Pass `nameFromPath` into the hoister in `lib/src/builder/swagger_builder.dart`**

In `generateSources`, change the hoist call:

```dart
  final normalized = SchemaHoister(names, nameFromPath: nameFromPath).hoist(loaded);
```

- [ ] **Step 5: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/parser/schema_hoister.dart lib/src/builder/swagger_builder.dart test/parser/schema_hoister_test.dart
git commit -m "Name hoisted models from the operation path or id"
```

---

## Notes for the implementer

- `operationBaseName` is the only place the operationId-vs-path decision lives; the parser applies `memberName` to it and the hoister applies `className` with a `request`/`response` suffix.
- The hoister now needs the verb and path, so `hoist` iterates entries (not just values) to pass the path key and method key down.
