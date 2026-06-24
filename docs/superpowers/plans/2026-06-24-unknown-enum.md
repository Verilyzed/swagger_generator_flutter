# Unknown Enum Values Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Map any unrecognized enum string to a `$unknown` sentinel instead of throwing during deserialization.

**Architecture:** `EnumEmitter` appends a `$unknown` member to each enum; `ModelEmitter` adds `unknownEnumValue: <Enum>.$unknown` to each enum-typed field's `@JsonKey`. The sentinel name is collision-safe because `NameGiver` never produces a `$`-prefixed name from a spec value.

**Tech Stack:** Dart, `package:build`, `json_serializable`, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- The sentinel member is named `$unknown` and has no `@JsonValue`.

---

### Task 1: EnumEmitter $unknown sentinel

**Files:**
- Modify: `lib/src/emit/enum_emitter.dart`
- Modify: `test/emit/enum_emitter_test.dart`

**Interfaces:**
- Produces: every emitted enum ends with a `$unknown` member with no `@JsonValue`.

- [ ] **Step 1: Add a failing assertion to `test/emit/enum_emitter_test.dart`**

In the existing `emits an enum with JsonValue annotations` test, add:

```dart
    expect(out, contains(r'  $unknown,'));
    expect(out, contains('// Fallback for values not present in the spec.'));
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/enum_emitter_test.dart`
Expected: FAIL (no `$unknown` member).

- [ ] **Step 3: Append the sentinel in `lib/src/emit/enum_emitter.dart`**

Replace the per-enum block:

```dart
    for (final e in enums) {
      buffer.writeln('enum ${e.name} {');
      for (final v in e.values) {
        buffer
          ..writeln("  @JsonValue('${v.jsonValue}')")
          ..writeln('  ${v.dartName},');
      }
      buffer
        ..writeln('  // Fallback for values not present in the spec.')
        ..writeln(r'  $unknown,')
        ..writeln('}')
        ..writeln();
    }
```

- [ ] **Step 4: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/enum_emitter.dart test/emit/enum_emitter_test.dart
git commit -m "Append a fallback member to generated enums"
```

---

### Task 2: ModelEmitter unknownEnumValue on enum fields

**Files:**
- Modify: `lib/src/emit/model_emitter.dart`
- Modify: `lib/src/builder/swagger_builder.dart`
- Modify: `test/emit/model_emitter_test.dart`

**Interfaces:**
- Produces: `ModelEmitter.emit(models, {required String partFileName, required String enumsImport, required Set<String> enumNames})`; an enum-typed field gets `@JsonKey(... unknownEnumValue: <Enum>.$unknown)`.

- [ ] **Step 1: Add failing tests and update existing calls in `test/emit/model_emitter_test.dart`**

Every existing `ModelEmitter().emit(...)` call gains `enumNames: const {}`. Then
append two tests:

```dart
  test('adds unknownEnumValue to an enum field', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Item',
          fields: [
            FieldDef(
              dartName: 'category',
              jsonKey: 'category',
              type: DartType('ItemCategory'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {'ItemCategory'},
    );

    expect(out, contains(r'@JsonKey(unknownEnumValue: ItemCategory.$unknown)'));
  });

  test('merges name and unknownEnumValue for a renamed enum field', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Item',
          fields: [
            FieldDef(
              dartName: 'errorCode',
              jsonKey: 'error_code',
              type: DartType('ErrorCode'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {'ErrorCode'},
    );

    expect(
      out,
      contains(
        r"@JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)",
      ),
    );
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/model_emitter_test.dart`
Expected: FAIL (`emit` has no `enumNames` parameter).

- [ ] **Step 3: Update `lib/src/emit/model_emitter.dart`**

Change `emit` to take `enumNames` and pass it to `_emitClass`:

```dart
  String emit(
    List<ModelDef> models, {
    required String partFileName,
    required String enumsImport,
    required Set<String> enumNames,
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
      _emitClass(buffer, model, enumNames);
    }

    return buffer.toString();
  }
```

Change `_emitClass` to add the `@JsonKey` from name and enum:

```dart
  void _emitClass(StringBuffer buffer, ModelDef model, Set<String> enumNames) {
    buffer
      ..writeln('@JsonSerializable()')
      ..writeln('class ${model.name} {');

    for (final field in model.fields) {
      final enumName = _enumOf(field.type.name, enumNames);
      final keyArgs = <String>[];
      if (field.jsonKey != field.dartName) {
        keyArgs.add("name: '${field.jsonKey}'");
      }
      if (enumName != null) {
        keyArgs.add('unknownEnumValue: $enumName.\$unknown');
      }
      if (keyArgs.isNotEmpty) {
        buffer.writeln('  @JsonKey(${keyArgs.join(', ')})');
      }
      buffer.writeln('  final ${field.type.display} ${field.dartName};');
    }
```

(Leave the rest of `_emitClass` - the constructor, fromJson, toJson - unchanged.)

Add the helper at the end of the class:

```dart
  String? _enumOf(String typeName, Set<String> enumNames) {
    for (final id in RegExp(r'[A-Za-z_][A-Za-z0-9_]*')
        .allMatches(typeName)
        .map((m) => m[0]!)) {
      if (enumNames.contains(id)) return id;
    }
    return null;
  }
```

- [ ] **Step 4: Pass `enumNames` in `lib/src/builder/swagger_builder.dart`**

In `generateSources`, change the `.models.dart` entry:

```dart
    '.models.dart': ModelEmitter().emit(
      spec.models,
      partFileName: '$baseName.models.g.dart',
      enumsImport: enumsFile,
      enumNames: spec.enums.map((e) => e.name).toSet(),
    ),
```

- [ ] **Step 5: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/emit/model_emitter.dart lib/src/builder/swagger_builder.dart test/emit/model_emitter_test.dart
git commit -m "Route unknown enum values to the fallback member"
```

---

### Task 3: Regenerate and round-trip an unknown enum

Verification only.

**Files:**
- None new committed. Temporary mock + consumer, reverted.

**Interfaces:**
- Consumes: Tasks 1-2 and `example/lib/specs/newapi.json`.

- [ ] **Step 1: Regenerate and confirm clean output with the sentinel**

From the repo root:
```bash
cd example && dart run build_runner build && flutter analyze 2>&1 | tail -1
cd ..
grep -E '\$unknown' example/lib/generated/newapi.enums.dart | head -2
grep "unknownEnumValue" example/lib/generated/newapi.models.dart | head -2
```
Expected: `flutter analyze` clean; the enums file has `$unknown` members and the
models file has `unknownEnumValue:` on enum fields. If json_serializable rejects
`unknownEnumValue` on a `List<Enum>` field, narrow `_enumOf` to scalar fields
(return the name only when `typeName` equals an enum name exactly), add an
emitter test for that, regenerate, and continue.

- [ ] **Step 2: Start a mock that returns an unknown vault type**

Create `example/tool/mock_unknown.py`:
```python
import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps([
            {"id": "v1", "name": "Personal", "type": "BOGUS_VALUE"},
        ]).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
```
Run it in the background from the repo root: `python3 example/tool/mock_unknown.py`
Confirm: `curl -s http://localhost:8000/vaults` returns the vault with
`"type": "BOGUS_VALUE"`.

- [ ] **Step 3: Write the consumer `example/bin/unknown_check.dart`**

Confirm the enum type name in `example/lib/generated/newapi.enums.dart` (the
vault type enum) and the list method name in `newapi.service.dart` first, then:

```dart
import 'package:chopper/chopper.dart';
import 'package:example/generated/newapi.api.dart';

Future<void> main() async {
  final client = createClient(baseUrl: Uri.parse('http://localhost:8000'));
  final service = NewapiService.create(client);

  final res = await service.getVaults();
  final vaults = res.body as List<Vault>;
  final type = vaults.first.type;
  print('vault.type for an unknown value -> $type');
  if (type != VaultType.$unknown) {
    throw StateError('unknown enum did not fall back: $type');
  }

  client.dispose();
  print('RUNTIME OK');
}
```
(Use the actual enum name and `getVaults` method name from the generated files;
`VaultType` is the inline enum hoisted from `Vault.type`.)

- [ ] **Step 4: Run the consumer**

Run from `example/`: `dart run bin/unknown_check.dart`
Expected: prints the type as the `$unknown` sentinel and `RUNTIME OK`, with no
`CheckedFromJsonException`. This proves an unrecognized enum value deserializes
instead of throwing.

- [ ] **Step 5: Tear down**

```bash
pkill -f mock_unknown.py
rm -f example/bin/unknown_check.dart example/tool/mock_unknown.py
rmdir example/bin example/tool 2>/dev/null
cd example && dart run build_runner build >/dev/null 2>&1 && cd ..
git add example/lib/generated
git status --short
```
Expected: `example/lib/generated` reflects the regenerated output (sentinel +
`unknownEnumValue`), and no mock/consumer files remain.

- [ ] **Step 6: Commit the regenerated example**

```bash
git add example/lib/generated
git commit -m "Regenerate example with unknown-enum fallback"
```

---

## Notes for the implementer

- `$unknown` is collision-safe: `NameGiver` only prepends `$` to names that start with a digit, so it never produces `$unknown` from a spec value.
- A value that arrived unknown serializes back as the string `"$unknown"`; the original is not preserved (documented in the spec).
- `_enumOf` scans the field type's identifiers, so it matches both a scalar `StatusEnum` and the inner enum of a `List<StatusEnum>`; Task 3 Step 1 narrows it if json_serializable does not support `unknownEnumValue` on list elements.
