# Model Overrides Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users replace specific schemas with a hand-written Dart type from one global file, configured by name.

**Architecture:** Two build options (`overrides_import`, `override_schemas`) flow through `generateSources`. The resolver short-circuits a `$ref` to an overridden schema to its Dart class name; the parser skips generating it; emitters import the global file where the type is used and register it in the client converter factory map.

**Tech Stack:** Dart, `package:build`, `json_serializable`, `chopper`, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Override Dart type name is `className(schemaKey)`.
- A file imports `overrides_import` only when it references an override type.

---

### Task 1: Build options for overrides

**Files:**
- Modify: `lib/src/builder/builder_config.dart`
- Modify: `test/builder/builder_config_test.dart`

**Interfaces:**
- Produces: `BuilderConfig.overridesImport` (String?), `BuilderConfig.overrideSchemas` (Set<String>); `fromOptions` reads `overrides_import` and `override_schemas` and throws when schemas are set without an import.

- [ ] **Step 1: Write failing tests**

Append to `test/builder/builder_config_test.dart` (inside `main`):

```dart
  test('reads override options', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({
        'input_folder': 'lib/specs',
        'output_folder': 'lib/generated',
        'overrides_import': 'package:example/overrides.dart',
        'override_schemas': ['OneOfThing', 'payment_method'],
      }),
    );

    expect(config.overridesImport, 'package:example/overrides.dart');
    expect(config.overrideSchemas, {'OneOfThing', 'payment_method'});
  });

  test('defaults overrides to empty', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({'input_folder': 'lib/specs'}),
    );

    expect(config.overridesImport, isNull);
    expect(config.overrideSchemas, isEmpty);
  });

  test('throws when override_schemas is set without overrides_import', () {
    expect(
      () => BuilderConfig.fromOptions(
        const BuilderOptions({
          'input_folder': 'lib/specs',
          'override_schemas': ['OneOfThing'],
        }),
      ),
      throwsArgumentError,
    );
  });
```

Add the import for `BuilderOptions` if not present: `import 'package:build/build.dart';`.

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/builder/builder_config_test.dart`
Expected: FAIL (no `overridesImport`/`overrideSchemas`).

- [ ] **Step 3: Implement in `lib/src/builder/builder_config.dart`**

Add fields and constructor params:

```dart
  final String inputFolder;
  final String outputFolder;
  final bool nameFromPath;
  final String? overridesImport;
  final Set<String> overrideSchemas;

  const BuilderConfig({
    required this.inputFolder,
    required this.outputFolder,
    this.nameFromPath = false,
    this.overridesImport,
    this.overrideSchemas = const {},
  });
```

In `fromOptions`, before the `return`, read and validate:

```dart
    final rawImport = options.config['overrides_import'];
    final overridesImport =
        rawImport is String && rawImport.trim().isNotEmpty
            ? rawImport.trim()
            : null;
    final rawSchemas = options.config['override_schemas'];
    final overrideSchemas = rawSchemas is List
        ? rawSchemas.map((e) => e.toString()).toSet()
        : <String>{};
    if (overrideSchemas.isNotEmpty && overridesImport == null) {
      throw ArgumentError.value(
        rawSchemas,
        'override_schemas',
        'override_schemas requires overrides_import to be set',
      );
    }
```

Pass them in the `return BuilderConfig(...)`:

```dart
    return BuilderConfig(
      inputFolder: input,
      outputFolder: output,
      nameFromPath: nameFromPath,
      overridesImport: overridesImport,
      overrideSchemas: overrideSchemas,
    );
```

- [ ] **Step 4: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/builder/builder_config.dart test/builder/builder_config_test.dart
git commit -m "Read model-override build options"
```

---

### Task 2: Resolver short-circuits a $ref to an override

**Files:**
- Modify: `lib/src/resolve/dart_type_resolver.dart`
- Modify: `lib/src/resolve/resolver_factory.dart`
- Modify: `test/resolve/dart_type_resolver_test.dart`

**Interfaces:**
- Consumes: override schema keys.
- Produces: `DartTypeResolver(names, {schemas, Set<String> overrides})`; a `$ref` whose target name is in `overrides` resolves to `DartType(className(name))`. `resolverForVersion(version, names, {schemas, Set<String> overrides})`.

- [ ] **Step 1: Write failing tests**

Append to `test/resolve/dart_type_resolver_test.dart`:

```dart
  test('resolves a ref to an override to its Dart type', () {
    final r = OpenApi31TypeResolver(
      NameGiver(),
      schemas: {
        'OneOfThing': {
          'oneOf': [
            {r'$ref': '#/components/schemas/A'},
            {r'$ref': '#/components/schemas/B'},
          ],
        },
      },
      overrides: {'OneOfThing'},
    );

    expect(
      r.resolve({r'$ref': '#/components/schemas/OneOfThing'}).name,
      'OneOfThing',
    );
  });
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/resolve/dart_type_resolver_test.dart`
Expected: FAIL (`overrides` param not defined; without it the bare `oneOf` resolves to `dynamic`).

- [ ] **Step 3: Add `overrides` to `lib/src/resolve/dart_type_resolver.dart`**

In the base class:

```dart
abstract class DartTypeResolver {
  final NameGiver _names;
  final Map<String, dynamic> _schemas;
  final Set<String> _overrides;

  DartTypeResolver(
    this._names, {
    Map<String, dynamic> schemas = const {},
    Set<String> overrides = const {},
  })  : _schemas = schemas,
        _overrides = overrides;
```

In `_resolveCore`, the `$ref` branch, check overrides first:

```dart
    final ref = schema[r'$ref'];
    if (ref is String) {
      final name = ref.split('/').last;
      if (_overrides.contains(name)) return DartType(_names.className(name));
      final target = _schemas[name];
      if (target is Map<String, dynamic> && _isAlias(target)) {
        return resolve(target);
      }
      return DartType(_names.className(name));
    }
```

Update both subclass constructors to forward `overrides`:

```dart
class OpenApi30TypeResolver extends DartTypeResolver {
  OpenApi30TypeResolver(super.names, {super.schemas, super.overrides});
  // ...
}

class OpenApi31TypeResolver extends DartTypeResolver {
  OpenApi31TypeResolver(super.names, {super.schemas, super.overrides});
  // ...
}
```

- [ ] **Step 4: Pass `overrides` through `lib/src/resolve/resolver_factory.dart`**

```dart
DartTypeResolver resolverForVersion(
  String? openApiVersion,
  NameGiver names, {
  Map<String, dynamic> schemas = const {},
  Set<String> overrides = const {},
}) {
  if (openApiVersion != null && openApiVersion.startsWith('3.0')) {
    return OpenApi30TypeResolver(names, schemas: schemas, overrides: overrides);
  }
  return OpenApi31TypeResolver(names, schemas: schemas, overrides: overrides);
}
```

- [ ] **Step 5: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/resolve/dart_type_resolver.dart lib/src/resolve/resolver_factory.dart test/resolve/dart_type_resolver_test.dart
git commit -m "Resolve a ref to an overridden schema as its Dart type"
```

---

### Task 3: Parser skips overridden schemas

**Files:**
- Modify: `lib/src/parser/spec_parser.dart`
- Modify: `test/parser/spec_parser_test.dart`

**Interfaces:**
- Consumes: override keys, the override-aware resolver from Task 2.
- Produces: `SpecParser(names, resolver, {nameFromPath, Set<String> overrideSchemas})`; an overridden schema key yields no model and no enum.

- [ ] **Step 1: Write a failing test**

Append to `test/parser/spec_parser_test.dart` (it already constructs a parser; mirror its setup). Use an override-aware resolver:

```dart
  test('skips generating an overridden schema', () {
    final names = NameGiver();
    final resolver = OpenApi31TypeResolver(
      names,
      schemas: {
        'OneOfThing': {
          'oneOf': [
            {r'$ref': '#/components/schemas/A'},
          ],
        },
      },
      overrides: {'OneOfThing'},
    );
    final spec = SpecParser(names, resolver, overrideSchemas: {'OneOfThing'})
        .parse({
      'components': {
        'schemas': {
          'OneOfThing': {
            'oneOf': [
              {r'$ref': '#/components/schemas/A'},
            ],
          },
          'Foo': {
            'type': 'object',
            'properties': {
              'thing': {r'$ref': '#/components/schemas/OneOfThing'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    expect(spec.models.map((m) => m.name), isNot(contains('OneOfThing')));
    expect(spec.models.map((m) => m.name), contains('Foo'));
    expect(spec.enums.map((e) => e.name), isNot(contains('OneOfThing')));
    final foo = spec.models.firstWhere((m) => m.name == 'Foo');
    expect(foo.fields.single.type.name, 'OneOfThing');
  });
```

Ensure the test file imports `OpenApi31TypeResolver` and `NameGiver` (add imports if missing):
```dart
import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: FAIL (`overrideSchemas` param not defined / `OneOfThing` is generated or absent as a field type).

- [ ] **Step 3: Implement in `lib/src/parser/spec_parser.dart`**

Add the constructor parameter and field. Current constructor:

```dart
  SpecParser(this._names, this._resolver, {bool nameFromPath = false})
      : _nameFromPath = nameFromPath;
```

Change to:

```dart
  SpecParser(
    this._names,
    this._resolver, {
    bool nameFromPath = false,
    Set<String> overrideSchemas = const {},
  })  : _nameFromPath = nameFromPath,
        _overrideSchemas = overrideSchemas;
```

Add the field near the other fields:

```dart
  final Set<String> _overrideSchemas;
```

In the enum-name pre-pass loop and the generation loop, skip overridden keys. The
pre-pass:

```dart
    for (final entry in schemas.entries) {
      if (_overrideSchemas.contains(entry.key)) continue;
      final schema = entry.value;
      if (schema is Map<String, dynamic> && schema['enum'] is List) {
        enumNames.add(_names.className(entry.key));
      }
    }
```

The generation loop:

```dart
    for (final entry in schemas.entries) {
      if (_overrideSchemas.contains(entry.key)) continue;
      final schema = entry.value;
      if (schema is! Map<String, dynamic>) continue;
      // ... unchanged ...
    }
```

- [ ] **Step 4: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/parser/spec_parser.dart test/parser/spec_parser_test.dart
git commit -m "Skip generating overridden schemas in the parser"
```

---

### Task 4: Emitters import overrides and register the factory

**Files:**
- Modify: `lib/src/emit/model_emitter.dart`
- Modify: `lib/src/emit/service_emitter.dart`
- Modify: `lib/src/emit/client_emitter.dart`
- Modify: `test/emit/model_emitter_test.dart`
- Modify: `test/emit/service_emitter_test.dart`
- Modify: `test/emit/client_emitter_test.dart`

**Interfaces:**
- Produces:
  - `ModelEmitter.emit(models, {partFileName, enumsImport, enumNames, Set<String> overrideTypes = const {}, String? overridesImport})` - imports `overridesImport` when a field references an override type.
  - `ServiceEmitter.emit(service, {partFileName, modelsImport, enumsImport, enumNames, Set<String> overrideTypes = const {}, String? overridesImport})` - imports `overridesImport` when a parameter or response references an override type.
  - `ClientEmitter.emitClient(service, {serviceImport, modelsImport, models, Set<String> overrideTypes = const {}, String? overridesImport})` - registers each override type as `Type: Type.fromJson` and imports `overridesImport` when any are present.

- [ ] **Step 1: Write failing emitter tests**

In `test/emit/model_emitter_test.dart`, update existing `emit(...)` calls to remain
valid (the new params are optional, so they keep working) and append:

```dart
  test('imports the overrides file when a field uses an override type', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Foo',
          fields: [
            FieldDef(
              dartName: 'thing',
              jsonKey: 'thing',
              type: DartType('OneOfThing'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, contains("import 'package:example/overrides.dart';"));
    expect(out, contains('final OneOfThing thing;'));
  });

  test('omits the overrides import when no field uses an override', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Foo',
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
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, isNot(contains('package:example/overrides.dart')));
  });
```

In `test/emit/service_emitter_test.dart`, append:

```dart
  test('imports the overrides file when a response uses an override type', () {
    final out = ServiceEmitter().emit(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'getThing',
            httpMethod: 'GET',
            path: '/thing',
            parameters: [],
            responseType: DartType('OneOfThing'),
          ),
        ],
      ),
      partFileName: 'demo.service.chopper.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, contains("import 'package:example/overrides.dart';"));
  });
```

In `test/emit/client_emitter_test.dart` (mirror its existing `emitClient` setup),
append:

```dart
  test('registers an override type in the factory map', () {
    final out = ClientEmitter().emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      models: const [],
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, contains("import 'package:example/overrides.dart';"));
    expect(out, contains('OneOfThing: OneOfThing.fromJson,'));
  });
```

(If `test/emit/client_emitter_test.dart` does not exist, create it with the
standard header `import 'package:swagger_generator_flutter/src/emit/client_emitter.dart';`,
`import 'package:swagger_generator_flutter/src/ir/api_spec.dart';`,
`import 'package:test/test.dart';` and a `void main() { ... }` wrapper.)

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/emit/`
Expected: FAIL (new named params not defined).

- [ ] **Step 3: Implement `ModelEmitter`**

Add params and the conditional import. Change the `emit` signature:

```dart
  String emit(
    List<ModelDef> models, {
    required String partFileName,
    required String enumsImport,
    required Set<String> enumNames,
    Set<String> overrideTypes = const {},
    String? overridesImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(
        SourceWriter.importLine(
          'package:json_annotation/json_annotation.dart',
        ),
      )
      ..writeln(SourceWriter.importLine(enumsImport));
    if (overridesImport != null && _usesOverride(models, overrideTypes)) {
      buffer.writeln(SourceWriter.importLine(overridesImport));
    }
    buffer
      ..writeln()
      ..writeln("part '$partFileName';")
      ..writeln();

    // ... unchanged: DateConverter block, model loop ...
  }
```

Add helpers at the end of the class:

```dart
  bool _usesOverride(List<ModelDef> models, Set<String> overrideTypes) {
    if (overrideTypes.isEmpty) return false;
    for (final model in models) {
      for (final field in model.fields) {
        for (final id in _identifiers(field.type.name)) {
          if (overrideTypes.contains(id)) return true;
        }
      }
    }
    return false;
  }

  Iterable<String> _identifiers(String type) =>
      RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(type).map((m) => m[0]!);
```

- [ ] **Step 4: Implement `ServiceEmitter`**

Add params to `emit` and a conditional import after the existing model/enum
imports, before the blank line that precedes `part`:

```dart
  String emit(
    ServiceDef service, {
    required String partFileName,
    required String modelsImport,
    required String enumsImport,
    required Set<String> enumNames,
    Set<String> overrideTypes = const {},
    String? overridesImport,
  }) {
    // ... existing chopper + MultipartFile + modelsImport + enums import ...
    if (overridesImport != null && _usesOverride(service, overrideTypes)) {
      buffer.writeln(SourceWriter.importLine(overridesImport));
    }
    buffer
      ..writeln()
      ..writeln("part '$partFileName';")
      // ... unchanged ...
  }
```

(Insert the override-import block immediately before the existing
`..writeln()` / `part` lines; keep the existing enum-import logic above it.)

Add a helper (reuse the existing `_identifiers`):

```dart
  bool _usesOverride(ServiceDef service, Set<String> overrideTypes) {
    if (overrideTypes.isEmpty) return false;
    for (final op in service.operations) {
      for (final id in _identifiers(op.responseType.name)) {
        if (overrideTypes.contains(id)) return true;
      }
      for (final p in op.parameters) {
        for (final id in _identifiers(p.type.name)) {
          if (overrideTypes.contains(id)) return true;
        }
      }
    }
    return false;
  }
```

- [ ] **Step 5: Implement `ClientEmitter`**

Add params, the conditional import, and factory-map entries. Change `emitClient`:

```dart
  String emitClient(
    ServiceDef service, {
    required String serviceImport,
    required String modelsImport,
    required List<ModelDef> models,
    Set<String> overrideTypes = const {},
    String? overridesImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln(SourceWriter.importLine(modelsImport));
    if (overridesImport != null && overrideTypes.isNotEmpty) {
      buffer.writeln(SourceWriter.importLine(overridesImport));
    }
    buffer
      ..writeln()
      // ... unchanged converter/createClient up to the factory map loop ...
```

In the factory-map section, after the existing model loop, add the overrides:

```dart
    for (final model in models) {
      buffer.writeln('      ${model.name}: ${model.name}.fromJson,');
    }
    for (final type in overrideTypes) {
      buffer.writeln('      $type: $type.fromJson,');
    }
```

- [ ] **Step 6: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 7: Commit**

```bash
git add lib/src/emit/model_emitter.dart lib/src/emit/service_emitter.dart lib/src/emit/client_emitter.dart test/emit/
git commit -m "Import overrides and register override factories in emitters"
```

---

### Task 5: Thread overrides through generateSources

**Files:**
- Modify: `lib/src/builder/swagger_builder.dart`
- Modify: `test/e2e/generation_test.dart`

**Interfaces:**
- Consumes: Tasks 1-4.
- Produces: `generateSources(content, {path, baseName, nameFromPath, String? overridesImport, Set<String> overrideSchemas})`; `SwaggerBuilder.build` passes `config.overridesImport` and `config.overrideSchemas`.

- [ ] **Step 1: Write a failing end-to-end test**

Append to `test/e2e/generation_test.dart`:

```dart
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
    expect(sources['.models.dart'], contains('final OneOfThing thing;'));
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
```

- [ ] **Step 2: Run to verify failure**

Run: `dart test test/e2e/generation_test.dart`
Expected: FAIL (`generateSources` has no `overridesImport`/`overrideSchemas`).

- [ ] **Step 3: Implement in `lib/src/builder/swagger_builder.dart`**

Change `generateSources`:

```dart
Map<String, String> generateSources(
  String content, {
  required String path,
  required String baseName,
  bool nameFromPath = false,
  String? overridesImport,
  Set<String> overrideSchemas = const {},
}) {
  final names = NameGiver();
  final loaded = SpecLoader().load(content, path: path);
  final normalized =
      SchemaHoister(names, nameFromPath: nameFromPath).hoist(loaded);
  final schemas =
      ((normalized['components'] as Map?)?['schemas'] as Map?)
          ?.cast<String, dynamic>() ??
      const {};
  final resolver = resolverForVersion(
    normalized['openapi'] as String?,
    names,
    schemas: schemas,
    overrides: overrideSchemas,
  );
  final spec = SpecParser(
    names,
    resolver,
    nameFromPath: nameFromPath,
    overrideSchemas: overrideSchemas,
  ).parse(normalized, name: baseName);

  final enumsFile = '$baseName.enums.dart';
  final modelsFile = '$baseName.models.dart';
  final serviceFile = '$baseName.service.dart';
  final clientFile = '$baseName.client.dart';

  final overrideTypes = overrideSchemas.map(names.className).toSet();
  final referenced = <String>{};
  final idRe = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
  for (final model in spec.models) {
    for (final field in model.fields) {
      referenced.addAll(idRe.allMatches(field.type.name).map((m) => m[0]!));
    }
  }
  for (final op in spec.service.operations) {
    referenced.addAll(idRe.allMatches(op.responseType.name).map((m) => m[0]!));
    for (final p in op.parameters) {
      referenced.addAll(idRe.allMatches(p.type.name).map((m) => m[0]!));
    }
  }
  final usedOverrides =
      overrideTypes.where(referenced.contains).toSet();

  final emitter = ClientEmitter();

  return {
    '.enums.dart': EnumEmitter().emit(spec.enums),
    '.models.dart': ModelEmitter().emit(
      spec.models,
      partFileName: '$baseName.models.g.dart',
      enumsImport: enumsFile,
      enumNames: spec.enums.map((e) => e.name).toSet(),
      overrideTypes: overrideTypes,
      overridesImport: overridesImport,
    ),
    '.service.dart': ServiceEmitter().emit(
      spec.service,
      partFileName: '$baseName.service.chopper.dart',
      modelsImport: modelsFile,
      enumsImport: enumsFile,
      enumNames: spec.enums.map((e) => e.name).toSet(),
      overrideTypes: overrideTypes,
      overridesImport: overridesImport,
    ),
    '.client.dart': emitter.emitClient(
      spec.service,
      serviceImport: serviceFile,
      modelsImport: modelsFile,
      models: spec.models,
      overrideTypes: usedOverrides,
      overridesImport: overridesImport,
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

In `SwaggerBuilder.build`, pass the config through:

```dart
    final sources = generateSources(
      content,
      path: input.path,
      baseName: baseName,
      nameFromPath: config.nameFromPath,
      overridesImport: config.overridesImport,
      overrideSchemas: config.overrideSchemas,
    );
```

- [ ] **Step 4: Run tests and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/builder/swagger_builder.dart test/e2e/generation_test.dart
git commit -m "Thread model overrides through the generation pipeline"
```

---

### Task 6: Regenerate the example and document the options

**Files:**
- Modify: `README.md` (build options table)
- Possibly modify: `example/lib/generated/*` (regeneration; expect no change - no overrides configured)

**Interfaces:**
- Consumes: Tasks 1-5.

- [ ] **Step 1: Regenerate and confirm no regression**

```bash
cd example && dart run build_runner build --delete-conflicting-outputs && flutter analyze 2>&1 | tail -1
cd ..
git status --short example/lib/generated
```
Expected: `flutter analyze` clean; no changes under `example/lib/generated` (the
example configures no overrides).

- [ ] **Step 2: Document the options in `README.md`**

Add two rows to the build options table:

```
| `overrides_import` | Import URI of a single file holding override types. Required if `override_schemas` is set. | _(none)_ |
| `override_schemas` | List of component schema keys to replace with a hand-written type named `className(key)` from `overrides_import`. | _(empty)_ |
```

Add a short note that an override type must provide `factory Type.fromJson(Map<String, dynamic>)` and `Map<String, dynamic> toJson()`, and that `oneOf`-only schemas are a typical use.

- [ ] **Step 3: Run the full suite and analyzer once more**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 4: Commit**

```bash
git add README.md example/lib/generated
git commit -m "Document model-override options and regenerate example"
```

---

## Notes for the implementer

- Override Dart type name is always `className(schemaKey)`; the user's class in the global file must match it.
- A generated file imports `overrides_import` only when it references an override type, mirroring the existing conditional enum import, so there are no unused-import warnings.
- The client factory map registers only override types that are actually referenced (`usedOverrides`), computed in `generateSources`.
- No committed example spec configures overrides, so regeneration should produce no diff; the end-to-end test in Task 5 is the behavioral guard.
