# Runtime-Working Generated Client Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the generated Chopper client work at runtime: typed responses deserialize into the generated models, and optional/defaulted parameters can be omitted. Proven by a live request/response round-trip against the test backend.

**Architecture:** Add `isRequired`/`defaultValue` to the IR `ParamDef`; the parser fills them; `ServiceEmitter` emits optional params as named with defaults; `ClientEmitter` emits a `JsonSerializableConverter` (factory map of every model's `fromJson`) and wires it into `createClient`. The test backend's `Widget` entity is renamed to `Gadget`.

**Tech Stack:** Dart, `package:build`, `chopper`, `json_serializable`, `package:test`; FastAPI backend (Python).

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Service methods keep returning `Future<Response<T>>`.
- Generator behavior covered by emitter/parser unit tests; runtime behavior covered by the live round-trip in the final task.
- Backend stays self-contained under `backend/` and deletable.

---

### Task 1: ParamDef gains isRequired and defaultValue

**Files:**
- Modify: `lib/src/ir/api_spec.dart`
- Test: `test/ir/api_spec_test.dart`

**Interfaces:**
- Produces: `ParamDef` with two new optional fields `bool isRequired` (default `false`) and `String? defaultValue`. Existing positional/required fields unchanged.

- [ ] **Step 1: Add a failing test to `test/ir/api_spec_test.dart`**

Append this test inside the existing `main()`:

```dart
  test('ParamDef carries optionality and default', () {
    const param = ParamDef(
      dartName: 'limit',
      wireName: 'limit',
      type: DartType('int'),
      location: ParamLocation.query,
      isRequired: false,
      defaultValue: '50',
    );
    expect(param.isRequired, isFalse);
    expect(param.defaultValue, '50');
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/ir/api_spec_test.dart`
Expected: FAIL (no named parameter `isRequired` / `defaultValue`).

- [ ] **Step 3: Update `ParamDef` in `lib/src/ir/api_spec.dart`**

Replace the existing `ParamDef` class with:

```dart
class ParamDef {
  final String dartName;
  final String wireName;
  final DartType type;
  final ParamLocation location;
  final bool isRequired;
  final String? defaultValue;

  const ParamDef({
    required this.dartName,
    required this.wireName,
    required this.type,
    required this.location,
    this.isRequired = false,
    this.defaultValue,
  });
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/ir/api_spec_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/ir/api_spec.dart test/ir/api_spec_test.dart
git commit -m "Add isRequired and defaultValue to ParamDef"
```

---

### Task 2: Parser fills param optionality and defaults

**Files:**
- Modify: `lib/src/parser/spec_parser.dart`
- Test: `test/parser/spec_parser_test.dart`

**Interfaces:**
- Consumes: `ParamDef.isRequired`/`defaultValue` (Task 1), the existing `_defaultLiteral(value, {typeName, enumNames})`.
- Produces: each `ParamDef` has `isRequired` (path params always true; query/body from the spec's `required`) and `defaultValue` (from the parameter schema's `default`, enum-aware). `_service`/`_operation` receive `enumNames`.

- [ ] **Step 1: Add failing tests to `test/parser/spec_parser_test.dart`**

Append inside `main()`:

```dart
  test('parses query param optionality and defaults', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'StatusEnum': {
            'type': 'string',
            'enum': ['active', 'inactive'],
          },
        },
      },
      'paths': {
        '/gadgets': {
          'get': {
            'operationId': 'list_gadgets',
            'parameters': [
              {
                'in': 'query',
                'name': 'limit',
                'required': false,
                'schema': {'type': 'integer', 'default': 50},
              },
              {
                'in': 'query',
                'name': 'status',
                'required': false,
                'schema': {r'$ref': '#/components/schemas/StatusEnum', 'default': 'active'},
              },
            ],
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    final op = spec.service.operations.single;
    final limit = op.parameters.firstWhere((p) => p.wireName == 'limit');
    final status = op.parameters.firstWhere((p) => p.wireName == 'status');
    expect(limit.isRequired, isFalse);
    expect(limit.defaultValue, '50');
    expect(status.defaultValue, 'StatusEnum.active');
  });

  test('path params are required', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/gadgets/{gadget_id}': {
          'get': {
            'operationId': 'get_gadget',
            'parameters': [
              {
                'in': 'path',
                'name': 'gadget_id',
                'required': true,
                'schema': {'type': 'string'},
              },
            ],
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.parameters.single.isRequired, isTrue);
  });
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: FAIL (isRequired defaults false for path; defaultValue null - both new assertions fail).

- [ ] **Step 3: Thread `enumNames` through `_service`/`_operation` and set the fields**

In `lib/src/parser/spec_parser.dart`:

In `parse`, change the service call to pass `enumNames`:

```dart
      service: _service(spec, name, enumNames),
```

Change the `_service` signature and its `_operation` call:

```dart
  ServiceDef _service(
    Map<String, dynamic> spec,
    String name,
    Set<String> enumNames,
  ) {
    final paths = (spec['paths'] as Map?)?.cast<String, dynamic>() ?? const {};
    final operations = <OperationDef>[];

    for (final pathEntry in paths.entries) {
      final methods = (pathEntry.value as Map).cast<String, dynamic>();
      for (final methodEntry in methods.entries) {
        if (!_httpMethods.contains(methodEntry.key.toLowerCase())) continue;
        final op = (methodEntry.value as Map).cast<String, dynamic>();
        operations.add(_operation(
          path: pathEntry.key,
          httpMethod: methodEntry.key.toUpperCase(),
          op: op,
          enumNames: enumNames,
        ));
      }
    }

    return ServiceDef(
      name: _names.className('$name service'),
      operations: operations,
    );
  }
```

Change `_operation` to accept `enumNames` and set the new `ParamDef` fields:

```dart
  OperationDef _operation({
    required String path,
    required String httpMethod,
    required Map<String, dynamic> op,
    required Set<String> enumNames,
  }) {
    final params = <ParamDef>[];
    for (final raw in (op['parameters'] as List?) ?? const []) {
      final p = (raw as Map).cast<String, dynamic>();
      final isPath = p['in'] == 'path';
      final schema = p['schema'] is Map
          ? (p['schema'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      final type = _resolver.resolve(schema);
      params.add(ParamDef(
        dartName: _names.memberName(p['name'] as String),
        wireName: p['name'] as String,
        type: type,
        location: isPath ? ParamLocation.path : ParamLocation.query,
        isRequired: isPath || p['required'] == true,
        defaultValue: _defaultLiteral(
          schema['default'],
          typeName: type.name,
          enumNames: enumNames,
        ),
      ));
    }

    DartType? bodyType;
    final body = op['requestBody'];
    final bodyMap = body is Map ? body.cast<String, dynamic>() : null;
    final bodySchema = _jsonSchema(bodyMap);
    if (bodySchema != null) {
      bodyType = _resolver.resolve(bodySchema);
      params.add(ParamDef(
        dartName: 'body',
        wireName: 'body',
        type: bodyType,
        location: ParamLocation.body,
        isRequired: bodyMap?['required'] == true,
      ));
    }

    final responses = (op['responses'] as Map?)?.cast<String, dynamic>();
    final okSchema = _jsonSchema(
      (responses?['200'] as Map?)?.cast<String, dynamic>(),
    );
    final responseType = okSchema == null
        ? const DartType('dynamic')
        : _resolver.resolve(okSchema);

    return OperationDef(
      methodName: _names.memberName(
        op['operationId'] as String? ?? '${httpMethod.toLowerCase()}_$path',
      ),
      httpMethod: httpMethod,
      path: path,
      parameters: params,
      requestBodyType: bodyType,
      responseType: responseType,
    );
  }
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: PASS (existing parser tests plus the two new ones).

- [ ] **Step 5: Commit**

```bash
git add lib/src/parser/spec_parser.dart test/parser/spec_parser_test.dart
git commit -m "Parse parameter optionality and defaults"
```

---

### Task 3: ServiceEmitter emits optional params as named

**Files:**
- Modify: `lib/src/emit/service_emitter.dart`
- Test: `test/emit/service_emitter_test.dart`

**Interfaces:**
- Consumes: `ParamDef.isRequired`/`defaultValue` (Tasks 1-2).
- Produces: required params (path always; required query/body) emitted positional; non-required params emitted in a trailing named group, each with its default (`= <default>`) or made nullable when there is no default.

- [ ] **Step 1: Replace the test in `test/emit/service_emitter_test.dart`**

Replace the existing single test body's expectations by extending the `ServiceDef` to include an optional query param, and asserting the named group. Use this full test file:

```dart
import 'package:swagger_generator_flutter/src/emit/service_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('emits required path positional and optional query named', () {
    final out = ServiceEmitter().emit(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'listGadgets',
            httpMethod: 'GET',
            path: '/gadgets',
            parameters: [
              ParamDef(
                dartName: 'limit',
                wireName: 'limit',
                type: DartType('int'),
                location: ParamLocation.query,
                isRequired: false,
                defaultValue: '50',
              ),
              ParamDef(
                dartName: 'status',
                wireName: 'status',
                type: DartType('StatusEnum', isNullable: true),
                location: ParamLocation.query,
                isRequired: false,
              ),
            ],
            responseType: DartType('List<Gadget>'),
          ),
          OperationDef(
            methodName: 'getGadget',
            httpMethod: 'GET',
            path: '/gadgets/{gadget_id}',
            parameters: [
              ParamDef(
                dartName: 'gadgetId',
                wireName: 'gadget_id',
                type: DartType('String'),
                location: ParamLocation.path,
                isRequired: true,
              ),
            ],
            responseType: DartType('Gadget'),
          ),
        ],
      ),
      partFileName: 'demo.service.chopper.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
    );

    expect(out, contains('Future<Response<List<Gadget>>> listGadgets({'));
    expect(out, contains("@Query('limit') int limit = 50,"));
    expect(out, contains("@Query('status') StatusEnum? status,"));
    expect(out, contains("@Path('gadget_id') String gadgetId,"));
    expect(out, isNot(contains('listGadgets(@Query')));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: FAIL (current emitter puts all params positional; no named group).

- [ ] **Step 3: Rewrite `_emitMethod` and the param helpers in `lib/src/emit/service_emitter.dart`**

Replace `_emitMethod` and `_param` with:

```dart
  void _emitMethod(StringBuffer buffer, OperationDef op) {
    final verb = _verb(op.httpMethod);
    final positional = op.parameters
        .where((p) => p.isRequired)
        .map((p) => '    ${_annotation(p)} ${p.type.display} ${p.dartName},')
        .toList();
    final named = op.parameters
        .where((p) => !p.isRequired)
        .map((p) => '    ${_namedParam(p)},')
        .toList();

    buffer
      ..writeln("  @$verb(path: '${op.path}')")
      ..write(
        '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
      );

    if (positional.isEmpty && named.isEmpty) {
      buffer.writeln(');');
    } else if (named.isEmpty) {
      buffer.writeln();
      for (final line in positional) {
        buffer.writeln(line);
      }
      buffer.writeln('  );');
    } else if (positional.isEmpty) {
      buffer.writeln('{');
      for (final line in named) {
        buffer.writeln(line);
      }
      buffer.writeln('  });');
    } else {
      buffer.writeln();
      for (final line in positional) {
        buffer.writeln(line);
      }
      buffer.writeln('    {');
      for (final line in named) {
        buffer.writeln(line);
      }
      buffer.writeln('  });');
    }

    buffer.writeln();
  }

  String _namedParam(ParamDef p) {
    final annotation = _annotation(p);
    if (p.defaultValue != null) {
      return '$annotation ${p.type.display} ${p.dartName} = ${p.defaultValue}';
    }
    final nullable = p.type.isNullable ? p.type.display : '${p.type.name}?';
    return '$annotation $nullable ${p.dartName}';
  }

  String _annotation(ParamDef p) {
    switch (p.location) {
      case ParamLocation.path:
        return "@Path('${p.wireName}')";
      case ParamLocation.query:
        return "@Query('${p.wireName}')";
      case ParamLocation.body:
        return '@Body()';
    }
  }
```

(Delete the old `_param` method. `_annotation` replaces it. `_verb` is unchanged.)

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/emit/service_emitter.dart test/emit/service_emitter_test.dart
git commit -m "Emit optional service parameters as named with defaults"
```

---

### Task 4: ClientEmitter emits a deserializing converter

**Files:**
- Modify: `lib/src/emit/client_emitter.dart`
- Test: `test/emit/client_emitter_test.dart`

**Interfaces:**
- Consumes: `ModelDef` (for names), `ServiceDef`.
- Produces: `emitClient(ServiceDef service, {required String serviceImport, required String modelsImport, required List<ModelDef> models})` emits a `JsonSerializableConverter` and a `createClient` that uses it with a factory map of every model's `fromJson`. `emitBarrel` unchanged.

- [ ] **Step 1: Replace the first test in `test/emit/client_emitter_test.dart`**

Replace the `emits a ChopperClient factory with the service` test with this (keep the barrel test unchanged). Add the `DartType`/`ModelDef` imports if missing.

```dart
  test('emits a deserializing converter and registers model factories', () {
    final out = emitter.emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      models: const [
        ModelDef(name: 'Gadget', fields: []),
        ModelDef(name: 'GadgetContainer', fields: []),
      ],
    );

    expect(out, contains("import 'demo.models.dart';"));
    expect(out, contains('class JsonSerializableConverter extends JsonConverter {'));
    expect(out, contains('Response<ResultType> convertResponse<ResultType, Item>('));
    expect(out, contains('converter: const JsonSerializableConverter({'));
    expect(out, contains('Gadget: Gadget.fromJson,'));
    expect(out, contains('GadgetContainer: GadgetContainer.fromJson,'));
    expect(out, contains('services: [DemoService.create()],'));
  });
```

Ensure these imports are present at the top of the test file:

```dart
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/client_emitter_test.dart`
Expected: FAIL (signature lacks `modelsImport`/`models`; no converter emitted).

- [ ] **Step 3: Rewrite `emitClient` in `lib/src/emit/client_emitter.dart`**

Replace the `emitClient` method with:

```dart
  String emitClient(
    ServiceDef service, {
    required String serviceImport,
    required String modelsImport,
    required List<ModelDef> models,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln(SourceWriter.importLine(modelsImport))
      ..writeln()
      ..writeln('typedef _FromJson = dynamic Function(Map<String, dynamic> json);')
      ..writeln()
      ..writeln('class JsonSerializableConverter extends JsonConverter {')
      ..writeln('  const JsonSerializableConverter(this.factories);')
      ..writeln()
      ..writeln('  final Map<Type, _FromJson> factories;')
      ..writeln()
      ..writeln('  T? _decodeMap<T>(Map<String, dynamic> values) {')
      ..writeln('    final factory = factories[T];')
      ..writeln('    return factory == null ? null : factory(values) as T;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  List<T> _decodeList<T>(Iterable values) => values')
      ..writeln('      .whereType<Map<String, dynamic>>()')
      ..writeln('      .map<T?>(_decodeMap<T>)')
      ..writeln('      .whereType<T>()')
      ..writeln('      .toList();')
      ..writeln()
      ..writeln('  dynamic _decode<T>(dynamic entity) {')
      ..writeln('    if (entity is Iterable) return _decodeList<T>(entity);')
      ..writeln('    if (entity is Map<String, dynamic>) return _decodeMap<T>(entity);')
      ..writeln('    return entity;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Response<ResultType> convertResponse<ResultType, Item>(')
      ..writeln('    Response response,')
      ..writeln('  ) {')
      ..writeln('    final decoded = super.convertResponse(response);')
      ..writeln('    return decoded.copyWith<ResultType>(')
      ..writeln('      body: _decode<Item>(decoded.body),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln()
      ..writeln('ChopperClient createClient({')
      ..writeln('  required Uri baseUrl,')
      ..writeln('  List<Interceptor>? interceptors,')
      ..writeln('}) {')
      ..writeln('  return ChopperClient(')
      ..writeln('    baseUrl: baseUrl,')
      ..writeln('    converter: const JsonSerializableConverter({');
    for (final model in models) {
      buffer.writeln('      ${model.name}: ${model.name}.fromJson,');
    }
    buffer
      ..writeln('    }),')
      ..writeln('    interceptors: interceptors ?? const [],')
      ..writeln('    services: [${service.name}.create()],')
      ..writeln('  );')
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/emit/client_emitter_test.dart`
Expected: PASS (the new test plus the unchanged barrel test).

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/client_emitter.dart test/emit/client_emitter_test.dart
git commit -m "Emit a JsonSerializableConverter that deserializes responses"
```

---

### Task 5: Wire models into the client emitter call

**Files:**
- Modify: `lib/src/builder/swagger_builder.dart`
- Test: `test/builder/swagger_builder_test.dart`

**Interfaces:**
- Consumes: the new `emitClient` signature (Task 4).
- Produces: `generateSources` passes `modelsImport` and `models` to `emitClient`. The five-file output is otherwise unchanged.

- [ ] **Step 1: Add an assertion to the existing builder test**

In `test/builder/swagger_builder_test.dart`, in the `generateSources produces the five output files` test, add after the existing `.client.dart` assertion:

```dart
    expect(sources['.client.dart'], contains('JsonSerializableConverter'));
    expect(sources['.client.dart'], contains('Task: Task.fromJson,'));
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/builder/swagger_builder_test.dart`
Expected: FAIL (emitClient call lacks required `modelsImport`/`models`, compile error; once fixed, the converter assertions drive it).

- [ ] **Step 3: Update the `emitClient` call in `lib/src/builder/swagger_builder.dart`**

In `generateSources`, change the `.client.dart` entry to:

```dart
    '.client.dart': emitter.emitClient(
      spec.service,
      serviceImport: serviceFile,
      modelsImport: modelsFile,
      models: spec.models,
    ),
```

- [ ] **Step 4: Run the test, full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/builder/swagger_builder.dart test/builder/swagger_builder_test.dart
git commit -m "Pass models into the client converter"
```

---

### Task 6: Rename the backend entity Widget to Gadget

**Files:**
- Modify: `backend/app/schemas.py`, `backend/app/main.py`, `backend/tests/test_schemas.py`, `backend/tests/test_container_schemas.py`, `backend/tests/test_routes.py`
- Regenerate: `backend/test_api.openapi.json`

**Interfaces:**
- Produces: the backend models/routes use `Gadget` (no `Widget`), and `backend/test_api.openapi.json` reflects the rename.

- [ ] **Step 1: Rename across the backend Python files**

Run from the repo root (case-sensitive replacement of both `Widget` and `widget`):

```bash
cd backend
for f in app/schemas.py app/main.py tests/test_schemas.py tests/test_container_schemas.py tests/test_routes.py; do
  sed -i '' 's/Widget/Gadget/g; s/widget/gadget/g' "$f"
done
cd ..
```

- [ ] **Step 2: Run the backend suite to verify the rename is consistent**

Run from `backend/`: `.venv/bin/python -m pytest -q`
Expected: PASS (17 tests; same count as before, now referencing Gadget and `/gadgets`).

- [ ] **Step 3: Regenerate the swagger file**

Run from `backend/`: `.venv/bin/python export_openapi.py`
Expected: prints `Wrote .../test_api.openapi.json (N schemas, M paths)`; the file now contains `Gadget`, `GadgetContainer`, `GadgetCreate` and `/gadgets` paths, no `Widget`.

- [ ] **Step 4: Confirm no Widget remains**

Run from the repo root:
```bash
grep -rn "Widget\|widget" backend/app backend/tests backend/test_api.openapi.json || echo "no widget references"
```
Expected: `no widget references`.

- [ ] **Step 5: Commit**

```bash
git add backend/
git commit -m "Rename backend entity Widget to Gadget"
```

---

### Task 7: Live round-trip verification

Prove the generated client deserializes real responses and that optional params can be omitted. Verification only - no package changes are committed.

**Files:**
- None committed. Temporary, reverted: `example/lib/gadgets.openapi.json`, generated `example/lib/gadgets.*`, `example/bin/runtime_check.dart`.

**Interfaces:**
- Consumes: the generator (Tasks 1-5) and the renamed backend spec (Task 6).

- [ ] **Step 1: Start the backend server**

Run from `backend/` in the background:
```bash
.venv/bin/uvicorn app.main:app --port 8000 --log-level warning
```
Confirm it is up:
```bash
curl -s --retry 8 --retry-connrefused --retry-delay 1 http://localhost:8000/gadgets/g1
```
Expected: a JSON object with `"id":"g1"` (or whatever the sample id is).

- [ ] **Step 2: Generate the client from the backend spec**

Run from the repo root:
```bash
cp backend/test_api.openapi.json example/lib/gadgets.openapi.json
cd example && dart run build_runner build && cd ..
```
Expected: build writes `example/lib/gadgets.*` including `gadgets.client.dart` and `gadgets.service.dart`. Inspect the service to learn the exact generated method names:
```bash
grep -E "Future<Response" example/lib/gadgets.service.dart
```

- [ ] **Step 3: Write the consumer `example/bin/runtime_check.dart`**

Use the actual method names from Step 2 (they are derived from the operationIds). Template (adjust the three method names to match):

```dart
import 'package:chopper/chopper.dart';
import 'package:example/gadgets.api.dart';

Future<void> main() async {
  final client = createClient(baseUrl: Uri.parse('http://localhost:8000'));
  final service = GadgetsService.create(client);

  final one = await service.<getGadgetMethodName>('g1');
  print('GET one -> ${one.statusCode}, body is Gadget: ${one.body is Gadget}');
  if (one.body is! Gadget) throw StateError('single response did not deserialize');

  final many = await service.<listGadgetsMethodName>();
  print('GET list -> ${many.statusCode}, body is List<Gadget>: '
      '${many.body is List<Gadget>}');
  if (many.body is! List<Gadget>) {
    throw StateError('list response did not deserialize');
  }

  client.dispose();
  print('RUNTIME OK');
}
```

(`<getGadgetMethodName>` / `<listGadgetsMethodName>` are the names printed in Step 2; the list call takes no arguments, proving optional params are omittable. `GadgetsService` is the generated service class name - confirm it from the file.)

- [ ] **Step 4: Run the consumer**

Run from `example/`:
```bash
dart run bin/runtime_check.dart
```
Expected: prints `body is Gadget: true`, `body is List<Gadget>: true`, and `RUNTIME OK`, with no exception. If it throws `type '_Map<String, dynamic>' is not a subtype of type 'Gadget?'` or similar, the converter is still wrong - capture the error, fix `ClientEmitter` (Task 4) with a failing emitter test that pins the corrected output, re-run `dart test` and `dart analyze`, regenerate, and repeat.

- [ ] **Step 5: Tear down**

Run from the repo root:
```bash
pkill -f "uvicorn app.main"
rm -f example/lib/gadgets.openapi.json example/lib/gadgets.* example/bin/runtime_check.dart
rmdir example/bin 2>/dev/null
cd example && dart run build_runner build >/dev/null 2>&1 && cd ..
git checkout -- example/
git status --short
```
Expected: `git status --short` shows no `example/` changes.

- [ ] **Step 6: Record the result**

No commit. The task deliverable is the verified `RUNTIME OK` output captured in the task report.

---

## Notes for the implementer

- The converter relies on the standard Chopper pattern: `super.convertResponse` decodes the JSON to `Map`/`List`, then `_decode<Item>` builds the typed model from the registered `fromJson`. Request bodies need no converter changes because `jsonEncode` calls the model's `toJson`.
- Path parameters are always `isRequired`, so they always land in the positional group; only genuinely optional query/body params move to the named group.
- If `dart analyze` rejects the `const JsonSerializableConverter({...})` map (const tear-offs), drop `const` on that one expression and re-run; the behavior is identical.
