# Date Fields and Optional Parameters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Map `format: date` to a date-only `DateTime`, and make optional service parameters nullable with their defaults applied client-side in a generated facade.

**Architecture:** `DartType` carries an `isDateOnly` flag set by the resolver; `ModelEmitter` gives date fields a generated `DateConverter`. `ServiceEmitter` drops baked defaults from the Chopper method (params become nullable) and emits a facade class (`<Base>Api`) that applies defaults and delegates to the Chopper service.

**Tech Stack:** Dart, `package:build`, `json_serializable`, `chopper`, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Facade name: service name with the `Service` suffix replaced by `Api`.
- The `DateConverter` writes date-only (`toIso8601String().split('T').first`).

---

### Task 1: `isDateOnly` on DartType and the resolver

**Files:**
- Modify: `lib/src/ir/dart_type.dart`
- Modify: `lib/src/resolve/dart_type_resolver.dart`
- Modify: `test/resolve/dart_type_resolver_test.dart`

**Interfaces:**
- Produces: `DartType(name, {bool isNullable, bool isDateOnly})`; `resolve` of a
  `{'type': 'string', 'format': 'date'}` schema returns a `DartType` with
  `name == 'DateTime'` and `isDateOnly == true`, preserved through nullable
  wrapping.

- [ ] **Step 1: Write failing resolver tests**

Add to `test/resolve/dart_type_resolver_test.dart` inside `main`:

```dart
  test('maps date format to a date-only DateTime', () {
    final t = resolver.resolve({'type': 'string', 'format': 'date'});
    expect(t.name, 'DateTime');
    expect(t.isDateOnly, isTrue);
  });

  test('keeps isDateOnly when a date field is nullable', () {
    final t = resolver.resolve({
      'type': ['string', 'null'],
      'format': 'date',
    });
    expect(t.name, 'DateTime');
    expect(t.isNullable, isTrue);
    expect(t.isDateOnly, isTrue);
  });

  test('date-time is not flagged date-only', () {
    final t = resolver.resolve({'type': 'string', 'format': 'date-time'});
    expect(t.name, 'DateTime');
    expect(t.isDateOnly, isFalse);
  });
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/resolve/dart_type_resolver_test.dart`
Expected: FAIL (`isDateOnly` is not defined).

- [ ] **Step 3: Add the flag to `lib/src/ir/dart_type.dart`**

```dart
/// A resolved Dart type with nullability.
class DartType {
  final String name;
  final bool isNullable;
  final bool isDateOnly;

  const DartType(
    this.name, {
    this.isNullable = false,
    this.isDateOnly = false,
  });

  String get display => isNullable ? '$name?' : name;
}
```

- [ ] **Step 4: Map `date` and preserve the flag in `lib/src/resolve/dart_type_resolver.dart`**

In `resolve`, preserve `isDateOnly` when re-wrapping nullable:

```dart
  DartType resolve(Map<String, dynamic> schema) {
    final core = coreSchema(schema);
    final nullable = isNullable(schema);
    final inner = _resolveCore(core);
    return nullable || inner.isNullable
        ? DartType(inner.name, isNullable: true, isDateOnly: inner.isDateOnly)
        : inner;
  }
```

In `_resolveCore`, the `'string'` case:

```dart
      case 'string':
        if (schema['format'] == 'date-time') return const DartType('DateTime');
        if (schema['format'] == 'date') {
          return const DartType('DateTime', isDateOnly: true);
        }
        return const DartType('String');
```

- [ ] **Step 5: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/ir/dart_type.dart lib/src/resolve/dart_type_resolver.dart test/resolve/dart_type_resolver_test.dart
git commit -m "Map format date to a date-only DateTime"
```

---

### Task 2: DateConverter in the model emitter

**Files:**
- Modify: `lib/src/emit/model_emitter.dart`
- Modify: `test/emit/model_emitter_test.dart`

**Interfaces:**
- Consumes: `DartType.isDateOnly` from Task 1.
- Produces: a date-only field emits `@DateConverter()`; the `DateConverter` class
  is emitted once per models file when any date-only field exists.

- [ ] **Step 1: Write failing tests**

Append to `test/emit/model_emitter_test.dart`:

```dart
  test('emits DateConverter and annotates a date field', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Event',
          fields: [
            FieldDef(
              dartName: 'occurredAt',
              jsonKey: 'occurred_at',
              type: DartType('DateTime', isNullable: true, isDateOnly: true),
              isRequired: false,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(out, contains('class DateConverter implements JsonConverter<DateTime, String> {'));
    expect(out, contains("object.toIso8601String().split('T').first"));
    expect(out, contains('@DateConverter()'));
    expect(out, contains('final DateTime? occurredAt;'));
  });

  test('omits DateConverter when no date field exists', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Plain',
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
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(out, isNot(contains('DateConverter')));
  });
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/emit/model_emitter_test.dart`
Expected: FAIL (no `DateConverter`).

- [ ] **Step 3: Emit the converter and annotation in `lib/src/emit/model_emitter.dart`**

After the `part` line block in `emit`, before the model loop, add the converter
when needed:

```dart
      ..writeln("part '$partFileName';")
      ..writeln();

    if (models.any((m) => m.fields.any((f) => f.type.isDateOnly))) {
      buffer
        ..writeln(
          'class DateConverter implements JsonConverter<DateTime, String> {',
        )
        ..writeln('  const DateConverter();')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  DateTime fromJson(String json) => DateTime.parse(json);')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  String toJson(DateTime object) =>')
        ..writeln("      object.toIso8601String().split('T').first;")
        ..writeln('}')
        ..writeln();
    }

    for (final model in models) {
      _emitClass(buffer, model, enumNames);
    }
```

In `_emitClass`, after writing the `@JsonKey(...)` line and before the field
declaration, add the converter annotation:

```dart
      if (keyArgs.isNotEmpty) {
        buffer.writeln('  @JsonKey(${keyArgs.join(', ')})');
      }
      if (field.type.isDateOnly) {
        buffer.writeln('  @DateConverter()');
      }
      buffer.writeln('  final ${field.type.display} ${field.dartName};');
```

- [ ] **Step 4: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/model_emitter.dart test/emit/model_emitter_test.dart
git commit -m "Serialize date fields as date-only via a generated converter"
```

---

### Task 3: Nullable optional parameters in the Chopper service

**Files:**
- Modify: `lib/src/emit/service_emitter.dart`
- Modify: `test/emit/service_emitter_test.dart`

**Interfaces:**
- Produces: a non-required parameter is emitted as `Type? name` with no default;
  required and path parameters keep `required`.

- [ ] **Step 1: Update the existing assertion to expect nullable, no default**

In `test/emit/service_emitter_test.dart`, the first test currently asserts
`"@Query('limit') int limit = 50,"`. Replace that line with:

```dart
    expect(out, contains("@Query('limit') int? limit,"));
    expect(out, isNot(contains('int limit = 50')));
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: FAIL (still emits `int limit = 50`).

- [ ] **Step 3: Drop the default branch in `_namedParam` in `lib/src/emit/service_emitter.dart`**

```dart
  String _namedParam(ParamDef p) {
    final annotation = _annotation(p);
    if (p.isRequired) {
      return '$annotation required ${p.type.display} ${p.dartName}';
    }
    final nullable = p.type.isNullable ? p.type.display : '${p.type.name}?';
    return '$annotation $nullable ${p.dartName}';
  }
```

- [ ] **Step 4: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/service_emitter.dart test/emit/service_emitter_test.dart
git commit -m "Emit optional Chopper parameters as nullable without defaults"
```

---

### Task 4: Facade class applying client-side defaults

**Files:**
- Modify: `lib/src/emit/service_emitter.dart`
- Modify: `test/emit/service_emitter_test.dart`

**Interfaces:**
- Consumes: nullable parameters from Task 3.
- Produces: after the Chopper service, `ServiceEmitter` emits a class named
  `<service.name with Service replaced by Api>` that wraps the service, mirrors
  method signatures without Chopper annotations, and delegates with
  `name: name ?? <default>` for optional parameters that have a default.

- [ ] **Step 1: Write failing facade assertions**

Append to the first test in `test/emit/service_emitter_test.dart` (the one with
`listGadgets`, the `limit` default `'50'`, and `status`):

```dart
    expect(out, contains('class DemoApi {'));
    expect(out, contains('final DemoService _service;'));
    expect(
      out,
      contains('DemoApi(ChopperClient client) : _service = DemoService.create(client);'),
    );
    expect(out, contains('Future<Response<List<Gadget>>> listGadgets({'));
    expect(out, contains('    int? limit,'));
    expect(out, contains('    StatusEnum? status,'));
    expect(out, contains('      limit: limit ?? 50,'));
    expect(out, contains('      status: status,'));
    expect(out, contains('  Future<Response<Gadget>> getGadget({'));
    expect(out, contains('    required String gadgetId,'));
    expect(out, contains('      gadgetId: gadgetId,'));
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: FAIL (no facade class).

- [ ] **Step 3: Emit the facade in `lib/src/emit/service_emitter.dart`**

In `emit`, after the Chopper class is closed (after the `..writeln('}')` /
`..writeln()` that ends the abstract class) and before `return buffer.toString();`,
emit the facade:

```dart
    _emitFacade(buffer, service);

    return buffer.toString();
  }

  void _emitFacade(StringBuffer buffer, ServiceDef service) {
    final apiName = service.name.endsWith('Service')
        ? '${service.name.substring(0, service.name.length - 'Service'.length)}Api'
        : '${service.name}Api';

    buffer
      ..writeln('class $apiName {')
      ..writeln('  final ${service.name} _service;')
      ..writeln()
      ..writeln(
        '  $apiName(ChopperClient client) : _service = ${service.name}.create(client);',
      )
      ..writeln();

    for (final op in service.operations) {
      _emitFacadeMethod(buffer, op);
    }

    buffer
      ..writeln('}')
      ..writeln();
  }

  void _emitFacadeMethod(StringBuffer buffer, OperationDef op) {
    buffer.write(
      '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
    );

    if (op.parameters.isEmpty) {
      buffer
        ..writeln(') =>')
        ..writeln('      _service.${op.methodName}();')
        ..writeln();
      return;
    }

    buffer.writeln('{');
    for (final p in op.parameters) {
      buffer.writeln('    ${_facadeParam(p)},');
    }
    buffer
      ..writeln('  }) =>')
      ..writeln('      _service.${op.methodName}(');
    for (final p in op.parameters) {
      buffer.writeln('        ${_facadeArg(p)},');
    }
    buffer
      ..writeln('      );')
      ..writeln();
  }

  String _facadeParam(ParamDef p) {
    if (p.isRequired) return 'required ${p.type.display} ${p.dartName}';
    final nullable = p.type.isNullable ? p.type.display : '${p.type.name}?';
    return '$nullable ${p.dartName}';
  }

  String _facadeArg(ParamDef p) {
    if (!p.isRequired && p.defaultValue != null) {
      return '${p.dartName}: ${p.dartName} ?? ${p.defaultValue}';
    }
    return '${p.dartName}: ${p.dartName}';
  }
```

- [ ] **Step 4: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/service_emitter.dart test/emit/service_emitter_test.dart
git commit -m "Generate a facade that applies optional parameter defaults"
```

---

### Task 5: Regenerate and verify end-to-end

Verification only.

**Files:**
- None new committed. Temporary mock + consumer, reverted.

**Interfaces:**
- Consumes: Tasks 1-4, `example/lib/specs/*.json`.

- [ ] **Step 1: Regenerate and confirm clean output**

From the repo root:
```bash
cd example && dart run build_runner build --delete-conflicting-outputs && flutter analyze 2>&1 | tail -1
cd ..
grep -n "class DateConverter" example/lib/generated/resource_scheduler.models.dart | head -1
grep -n "@DateConverter" example/lib/generated/resource_scheduler.models.dart | head -1
grep -n "class ResourceSchedulerApi" example/lib/generated/resource_scheduler.service.dart | head -1
grep -nE "order: order \?\?|limit: limit \?\?" example/lib/generated/resource_scheduler.service.dart | head -2
```
Expected: `flutter analyze` clean; the models file has `DateConverter` and a
`@DateConverter()` on the date field; the service file has the
`ResourceSchedulerApi` facade with `?? <default>` delegation. If json_serializable
errors on the nullable date converter, that error text guides the fix (e.g. widen
the converter to `JsonConverter<DateTime?, String?>`); apply it, add a test, and
re-run.

- [ ] **Step 2: Start a mock that records the query and returns a date**

Create `example/tool/mock_params.py`:
```python
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

seen = {}


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/seen":
            body = json.dumps(seen).encode()
        else:
            seen.clear()
            seen.update({k: v[0] for k, v in parse_qs(parsed.query).items()})
            body = json.dumps([
                {"subject": "S", "occurred_at": "2026-06-24"},
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
Run in the background from the repo root: `python3 example/tool/mock_params.py`

This mock returns a list of objects with a `date` field and remembers the query
string of the most recent non-`/seen` request.

- [ ] **Step 3: Identify the right method and write the consumer**

Inspect `example/lib/generated/resource_scheduler.service.dart` for a GET method
that has an optional query parameter with a default (e.g. `order` defaulting to
`SortOrderEnum.asc`, or `limit`) and returns a list of a model that has the
`occurred_at` date field. Use that method, its model type, and the matching mock
path. Then create `example/bin/params_check.dart`:

```dart
import 'package:chopper/chopper.dart';
import 'package:example/generated/resource_scheduler.api.dart';

Future<void> main() async {
  final api = ResourceSchedulerApi(
    createClient(baseUrl: Uri.parse('http://localhost:8000')),
  );

  // Call the chosen list method passing null for the defaulted query param.
  // Replace <method>, <requiredArgs>, and <defaultedParam> with the real names.
  final res = await api.<method>(<requiredArgs>, <defaultedParam>: null);
  print('status: ${res.statusCode}');

  // Confirm a date field deserialized to a DateTime.
  final first = (res.body as List).first;
  print('date field runtime type: ${first.<dateField>.runtimeType}');

  print('DONE');
}
```

- [ ] **Step 4: Run the consumer and check the recorded query**

```bash
cd example && dart run bin/params_check.dart && cd ..
curl -s http://localhost:8000/seen
```
Expected: the consumer prints `DONE` with the date field's runtime type
`DateTime`; `/seen` shows the defaulted query parameter present with its default
value (e.g. `{"order": "asc"}`), proving the facade applied the client-side
default when `null` was passed.

- [ ] **Step 5: Tear down**

```bash
pkill -f mock_params.py
rm -f example/bin/params_check.dart example/tool/mock_params.py
rmdir example/bin example/tool 2>/dev/null
cd example && dart run build_runner build >/dev/null 2>&1 && cd ..
git status --short
```
Expected: only `example/lib/generated` changes remain; no mock/consumer files.

- [ ] **Step 6: Commit the regenerated example**

```bash
git add example/lib/generated
git commit -m "Regenerate example with date fields and parameter facade"
```

---

## Notes for the implementer

- The facade lives in the service file, which already imports chopper, models,
  and (conditionally) enums and `MultipartFile`; no import or barrel change is
  needed.
- `ResourceSchedulerService.create` stays available; the facade is additive.
- A `date` used as a query or path parameter maps to `DateTime` but is serialized
  by Chopper's default `toString()` (no converter). No date parameters exist in
  the current specs; this is a known limitation, not a task.
