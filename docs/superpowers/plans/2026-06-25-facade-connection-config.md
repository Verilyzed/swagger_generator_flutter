# Facade Connection Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure a connection directly on the per-spec facade (`baseUrl`, `httpClient`, `interceptors`, `authenticator`), and stop requiring callers to use `createClient`.

**Architecture:** `createClient` gains `httpClient` and `authenticator`. The facade moves from the service file into the client file (next to the converter and `createClient`) and gains a direct-parameter constructor plus a `fromClient` constructor.

**Tech Stack:** Dart, `package:build`, `chopper`, `package:http`, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- `Authenticator` comes from `package:chopper/chopper.dart`; `Client` from `package:http/http.dart`.
- Facade name: service name with the `Service` suffix replaced by `Api`.

---

### Task 1: createClient gains httpClient and authenticator

**Files:**
- Modify: `lib/src/emit/client_emitter.dart`
- Modify: `test/emit/client_emitter_test.dart`

**Interfaces:**
- Produces: the generated `createClient` exposes `httpClient` (-> `client:`) and `authenticator` (-> `authenticator:`); the client file imports `package:http/http.dart' show Client`.

- [ ] **Step 1: Write failing assertions**

In `test/emit/client_emitter_test.dart`, append to the first test (the one that
emits the converter and `createClient`):

```dart
    expect(out, contains("import 'package:http/http.dart' show Client;"));
    expect(out, contains('  Client? httpClient,'));
    expect(out, contains('  Authenticator? authenticator,'));
    expect(out, contains('    client: httpClient,'));
    expect(out, contains('    authenticator: authenticator,'));
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/emit/client_emitter_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement in `lib/src/emit/client_emitter.dart`**

Add the http import after the chopper import:

```dart
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln("import 'package:http/http.dart' show Client;")
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln(SourceWriter.importLine(modelsImport));
```

Change the generated `createClient` signature and the `ChopperClient(...)` call:

```dart
      ..writeln('ChopperClient createClient({')
      ..writeln('  required Uri baseUrl,')
      ..writeln('  Client? httpClient,')
      ..writeln('  List<Interceptor>? interceptors,')
      ..writeln('  Authenticator? authenticator,')
      ..writeln('}) {')
      ..writeln('  return ChopperClient(')
      ..writeln('    baseUrl: baseUrl,')
      ..writeln('    client: httpClient,')
      ..writeln('    converter: const JsonSerializableConverter({');
```

And after the factory map closes, add `authenticator:`:

```dart
    buffer
      ..writeln('    }),')
      ..writeln('    interceptors: interceptors ?? const [],')
      ..writeln('    authenticator: authenticator,')
      ..writeln('    services: [${service.name}.create()],')
      ..writeln('  );')
      ..writeln('}')
      ..writeln();
```

- [ ] **Step 4: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/client_emitter.dart test/emit/client_emitter_test.dart
git commit -m "Add httpClient and authenticator to the generated createClient"
```

---

### Task 2: Move the facade into the client file with direct-parameter constructors

**Files:**
- Modify: `lib/src/emit/client_emitter.dart`
- Modify: `lib/src/emit/service_emitter.dart`
- Modify: `lib/src/builder/swagger_builder.dart`
- Modify: `test/emit/client_emitter_test.dart`
- Modify: `test/emit/service_emitter_test.dart`
- Modify: `test/e2e/generation_test.dart`

**Interfaces:**
- Produces:
  - `ClientEmitter.emitClient(service, {serviceImport, modelsImport, enumsImport, models, enumNames, overrideTypes, overridesImport})` - now also emits the facade class with a direct-parameter constructor and a `fromClient` constructor, imports `enums` when a facade signature uses an enum, and includes `MultipartFile` in the http show-list when a file part is forwarded.
  - `ServiceEmitter.emit(...)` - no longer emits the facade.

- [ ] **Step 1: Move the facade assertions in the tests**

In `test/emit/service_emitter_test.dart`, in the first test, delete the facade
assertion block (everything from `expect(out, contains('class DemoApi {'));`
through `expect(out, contains('      gadgetId: gadgetId,'));`) and replace it with:

```dart
    expect(out, isNot(contains('class DemoApi')));
```

(Keep the chopper-method assertions above it: the `listGadgets({`, `@Query('limit') int? limit,`,
`int limit = 50` negative, `@Query('status') StatusEnum? status,`,
`@Path('gadget_id') required String gadgetId,`, and `listGadgets(@Query` negative.)

In `test/emit/client_emitter_test.dart`, update the two existing `emitClient(...)`
calls to pass the new required params `enumsImport: 'demo.enums.dart'` and
`enumNames: const {}`. Then append a facade test:

```dart
  test('emits a facade with direct-parameter and fromClient constructors', () {
    final out = emitter.emitClient(
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
                defaultValue: '50',
              ),
            ],
            responseType: DartType('List<Gadget>'),
          ),
        ],
      ),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      models: const [ModelDef(name: 'Gadget', fields: [])],
      enumNames: const {},
    );

    expect(out, contains('class DemoApi {'));
    expect(out, contains('  DemoApi({'));
    expect(out, contains('    required Uri baseUrl,'));
    expect(out, contains('    Client? httpClient,'));
    expect(out, contains('    Authenticator? authenticator,'));
    expect(out, contains('  }) : this.fromClient(createClient('));
    expect(
      out,
      contains('  DemoApi.fromClient(ChopperClient client)'),
    );
    expect(
      out,
      contains('      : _service = DemoService.create(client);'),
    );
    expect(out, contains('      limit: limit ?? 50,'));
  });

  test('imports enums when a facade signature uses an enum', () {
    final out = emitter.emitClient(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'listGadgets',
            httpMethod: 'GET',
            path: '/gadgets',
            parameters: [
              ParamDef(
                dartName: 'status',
                wireName: 'status',
                type: DartType('StatusEnum', isNullable: true),
                location: ParamLocation.query,
              ),
            ],
            responseType: DartType('dynamic'),
          ),
        ],
      ),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      models: const [],
      enumNames: const {'StatusEnum'},
    );

    expect(out, contains("import 'demo.enums.dart';"));
  });
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/emit/`
Expected: FAIL (`emitClient` has no `enumsImport`/`enumNames`; no facade in client output).

- [ ] **Step 3: Update `ClientEmitter.emitClient`**

Add the `enumsImport` and `enumNames` parameters, compute the http show-list, add
the conditional enums import, and call `_emitFacade` before returning:

```dart
  String emitClient(
    ServiceDef service, {
    required String serviceImport,
    required String modelsImport,
    required String enumsImport,
    required List<ModelDef> models,
    required Set<String> enumNames,
    Set<String> overrideTypes = const {},
    String? overridesImport,
  }) {
    final usesMultipart = service.operations.any(
      (op) => op.parameters.any((p) => p.location == ParamLocation.partFile),
    );
    final httpShow = usesMultipart ? 'Client, MultipartFile' : 'Client';

    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln("import 'package:http/http.dart' show $httpShow;")
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln(SourceWriter.importLine(modelsImport));
    if (_usesEnum(service, enumNames)) {
      buffer.writeln(SourceWriter.importLine(enumsImport));
    }
    if (overridesImport != null && overrideTypes.isNotEmpty) {
      buffer.writeln(SourceWriter.importLine(overridesImport));
    }
    buffer
      ..writeln()
      // ... unchanged: JsonFactory typedef, JsonSerializableConverter class,
      //     createClient (with httpClient/authenticator from Task 1),
      //     factory map loops, closing of createClient ...
      ;

    _emitFacade(buffer, service);

    return buffer.toString();
  }
```

(The `http` show-list replaces the unconditional `show Client;` added in Task 1.
Leave the converter and `createClient` body exactly as Task 1 left them.)

Add the facade methods and helpers to `ClientEmitter` (moved from `ServiceEmitter`,
with the new constructors):

```dart
  void _emitFacade(StringBuffer buffer, ServiceDef service) {
    final apiName = service.name.endsWith('Service')
        ? '${service.name.substring(0, service.name.length - 'Service'.length)}Api'
        : '${service.name}Api';

    buffer
      ..writeln('class $apiName {')
      ..writeln('  final ${service.name} _service;')
      ..writeln()
      ..writeln('  $apiName({')
      ..writeln('    required Uri baseUrl,')
      ..writeln('    Client? httpClient,')
      ..writeln('    List<Interceptor>? interceptors,')
      ..writeln('    Authenticator? authenticator,')
      ..writeln('  }) : this.fromClient(createClient(')
      ..writeln('          baseUrl: baseUrl,')
      ..writeln('          httpClient: httpClient,')
      ..writeln('          interceptors: interceptors,')
      ..writeln('          authenticator: authenticator,')
      ..writeln('        ));')
      ..writeln()
      ..writeln('  $apiName.fromClient(ChopperClient client)')
      ..writeln('      : _service = ${service.name}.create(client);')
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

  bool _usesEnum(ServiceDef service, Set<String> enumNames) {
    if (enumNames.isEmpty) return false;
    for (final op in service.operations) {
      if (_identifiers(op.responseType.name).any(enumNames.contains)) {
        return true;
      }
      for (final p in op.parameters) {
        if (_identifiers(p.type.name).any(enumNames.contains)) return true;
      }
    }
    return false;
  }

  Iterable<String> _identifiers(String type) =>
      RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(type).map((m) => m[0]!);
```

- [ ] **Step 4: Remove the facade from `ServiceEmitter`**

In `lib/src/emit/service_emitter.dart`, delete the `_emitFacade(buffer, service);`
call (so `emit` goes straight to `return buffer.toString();` after the abstract
class), and delete the now-unused methods `_emitFacade`, `_emitFacadeMethod`,
`_facadeParam`, and `_facadeArg`. Keep `_usesEnum`, `_usesOverride`, and
`_identifiers` (still used for the chopper service's imports).

- [ ] **Step 5: Pass `enumsImport` and `enumNames` in `lib/src/builder/swagger_builder.dart`**

In `generateSources`, update the `.client.dart` emit call:

```dart
    '.client.dart': emitter.emitClient(
      spec.service,
      serviceImport: serviceFile,
      modelsImport: modelsFile,
      enumsImport: enumsFile,
      models: spec.models,
      enumNames: spec.enums.map((e) => e.name).toSet(),
      overrideTypes: usedOverrides,
      overridesImport: overridesImport,
    ),
```

- [ ] **Step 6: Update the end-to-end test**

In `test/e2e/generation_test.dart`, in the first test (`generates all files from
the bundled spec without throwing`), add:

```dart
    expect(sources['.client.dart'], contains('class ResourceSchedulerApi {'));
    expect(sources['.service.dart'], isNot(contains('class ResourceSchedulerApi')));
```

- [ ] **Step 7: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 8: Commit**

```bash
git add lib/src/emit/client_emitter.dart lib/src/emit/service_emitter.dart lib/src/builder/swagger_builder.dart test/emit/ test/e2e/generation_test.dart
git commit -m "Move the facade into the client file with connection-parameter constructors"
```

---

### Task 3: Add the http dependency, regenerate, and document

**Files:**
- Modify: `example/pubspec.yaml`
- Modify: `example/lib/generated/*` (regeneration)
- Modify: `README.md`

**Interfaces:**
- Consumes: Tasks 1-2.

- [ ] **Step 1: Add `http` to the example**

In `example/pubspec.yaml`, under `dependencies`, add `http` next to `chopper`:

```yaml
  chopper: ^8.0.0
  http: ^1.0.0
```

Run: `cd example && dart pub get && cd ..`
Expected: resolves without error.

- [ ] **Step 2: Regenerate the example**

```bash
cd example && dart run build_runner build --delete-conflicting-outputs && flutter analyze 2>&1 | tail -1
cd ..
grep -n "class ResourceSchedulerApi" example/lib/generated/resource_scheduler.client.dart | head -1
grep -n "class ResourceSchedulerApi" example/lib/generated/resource_scheduler.service.dart | head -1
grep -n "Client? httpClient" example/lib/generated/resource_scheduler.client.dart | head -1
```
Expected: `flutter analyze` clean; the facade is in `.client.dart`, not in
`.service.dart`; `createClient`/facade expose `httpClient`.

- [ ] **Step 3: Document in `README.md`**

Update the usage section to construct the facade directly, e.g.:

```dart
final api = ResourceSchedulerApi(
  baseUrl: Uri.parse('https://api.example.com'),
  authenticator: myAuthenticator,
  interceptors: [HttpLoggingInterceptor()],
);
```

Note that the generated client depends on `package:http` (add it to your
`dependencies`), that each spec exposes a uniquely named `<Name>Api` facade (so
multiple specs do not collide), and that `<Name>Api.fromClient(chopperClient)`
reuses an existing `ChopperClient`.

- [ ] **Step 4: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add example/pubspec.yaml example/lib/generated README.md
git commit -m "Regenerate example with facade connection config and document it"
```

---

## Notes for the implementer

- The chopper abstract service stays in the service file; only the facade moves.
- `_usesEnum`/`_identifiers` are duplicated in `ClientEmitter` (the facade needs
  them) and `ServiceEmitter` (the chopper service needs them); this small
  duplication is acceptable and a candidate for a shared helper later.
- `createClient` stays public as the facade's internal builder; it is not removed.
- The http show-list is `Client` normally and `Client, MultipartFile` when the
  service forwards a file part.
