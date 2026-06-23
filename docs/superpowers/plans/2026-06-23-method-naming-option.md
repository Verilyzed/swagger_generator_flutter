# Method Naming Option Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A `method_names` build option that selects service-method names from `operationId` (default) or the verb and request path.

**Architecture:** `BuilderConfig` reads `method_names` into a `nameFromPath` bool, `SwaggerBuilder.build` threads it through `generateSources` into `SpecParser`, and `_operation` chooses the raw name accordingly.

**Tech Stack:** Dart, `package:build`, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Default behavior unchanged: `method_names` absent or `operationId` keeps the current naming.

---

### Task 1: SpecParser nameFromPath flag

**Files:**
- Modify: `lib/src/parser/spec_parser.dart`
- Test: `test/parser/spec_parser_test.dart`

**Interfaces:**
- Produces: `SpecParser(NameGiver, DartTypeResolver, {bool nameFromPath = false})`; when `nameFromPath` is true, `_operation` derives the method name from `'<verb>_<path>'` instead of `operationId`.

- [ ] **Step 1: Add a failing test to `test/parser/spec_parser_test.dart`**

```dart
  test('names methods from the path when nameFromPath is true', () {
    final names = NameGiver();
    final parser = SpecParser(
      names,
      OpenApi31TypeResolver(names),
      nameFromPath: true,
    );
    final spec = parser.parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/health': {
          'get': {
            'operationId': 'GetServerHealth',
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.methodName, 'getHealth');
  });

  test('names methods from the operationId by default', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/health': {
          'get': {
            'operationId': 'GetServerHealth',
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.methodName, 'getServerHealth');
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/parser/spec_parser_test.dart`
Expected: FAIL (no `nameFromPath` named parameter on `SpecParser`).

- [ ] **Step 3: Add the flag to `SpecParser` in `lib/src/parser/spec_parser.dart`**

Change the constructor and add a field:

```dart
  final NameGiver _names;
  final DartTypeResolver _resolver;
  final bool _nameFromPath;

  SpecParser(this._names, this._resolver, {bool nameFromPath = false})
      : _nameFromPath = nameFromPath;
```

In `_operation`, replace the `methodName` argument:

```dart
    return OperationDef(
      methodName: _names.memberName(
        _nameFromPath
            ? '${httpMethod.toLowerCase()}_$path'
            : op['operationId'] as String? ??
                '${httpMethod.toLowerCase()}_$path',
      ),
      httpMethod: httpMethod,
      path: path,
      parameters: params,
      requestBodyType: bodyType,
      responseType: responseType,
    );
```

- [ ] **Step 4: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/parser/spec_parser.dart test/parser/spec_parser_test.dart
git commit -m "Add nameFromPath option to SpecParser"
```

---

### Task 2: BuilderConfig method_names option

**Files:**
- Modify: `lib/src/builder/builder_config.dart`
- Test: `test/builder/builder_config_test.dart`

**Interfaces:**
- Produces: `BuilderConfig.nameFromPath` (bool), set from the `method_names` option (`'path'` -> true).

- [ ] **Step 1: Add failing tests to `test/builder/builder_config_test.dart`**

```dart
  test('nameFromPath is true when method_names is path', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({'method_names': 'path'}),
    );
    expect(config.nameFromPath, isTrue);
  });

  test('nameFromPath defaults to false', () {
    expect(
      BuilderConfig.fromOptions(const BuilderOptions({})).nameFromPath,
      isFalse,
    );
    expect(
      BuilderConfig.fromOptions(
        const BuilderOptions({'method_names': 'operationId'}),
      ).nameFromPath,
      isFalse,
    );
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/builder/builder_config_test.dart`
Expected: FAIL (no `nameFromPath` getter).

- [ ] **Step 3: Add `nameFromPath` to `BuilderConfig` in `lib/src/builder/builder_config.dart`**

Add the field and constructor parameter:

```dart
  final String inputFolder;
  final String outputFolder;
  final bool nameFromPath;

  const BuilderConfig({
    required this.inputFolder,
    required this.outputFolder,
    this.nameFromPath = false,
  });
```

In `fromOptions`, read the option and pass it to the constructor:

```dart
    final nameFromPath = options.config['method_names'] == 'path';
    return BuilderConfig(
      inputFolder: input,
      outputFolder: output,
      nameFromPath: nameFromPath,
    );
```

- [ ] **Step 4: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/builder/builder_config.dart test/builder/builder_config_test.dart
git commit -m "Read the method_names option into BuilderConfig"
```

---

### Task 3: Wire the flag through the builder and document it

**Files:**
- Modify: `lib/src/builder/swagger_builder.dart`
- Modify: `test/builder/swagger_builder_test.dart`
- Modify: `README.md`

**Interfaces:**
- Consumes: `BuilderConfig.nameFromPath` (Task 2), `SpecParser` (Task 1).
- Produces: `generateSources(content, {required path, required baseName, bool nameFromPath = false})`; `build` passes `config.nameFromPath`.

- [ ] **Step 1: Add a failing assertion to `test/builder/swagger_builder_test.dart`**

In the `generateSources produces the five output files` test, the input spec
has a `/tasks` GET with `operationId: list_tasks`. Add an assertion that path
naming changes the method name. After the existing service assertions add:

```dart
    final pathNamed = generateSources(
      content,
      path: 'lib/api/demo.openapi.json',
      baseName: 'demo',
      nameFromPath: true,
    );
    expect(pathNamed['.service.dart'], contains('getTasks('));
```

(The default call still produces `listTasks(`; the path-named call produces
`getTasks(` from `GET /tasks`.)

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/builder/swagger_builder_test.dart`
Expected: FAIL (`generateSources` has no `nameFromPath` parameter).

- [ ] **Step 3: Thread the flag through `lib/src/builder/swagger_builder.dart`**

In `build`, pass the config flag:

```dart
    final sources = generateSources(
      content,
      path: input.path,
      baseName: baseName,
      nameFromPath: config.nameFromPath,
    );
```

Change `generateSources` to accept and use the flag:

```dart
Map<String, String> generateSources(
  String content, {
  required String path,
  required String baseName,
  bool nameFromPath = false,
}) {
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
  final spec = SpecParser(names, resolver, nameFromPath: nameFromPath)
      .parse(normalized, name: baseName);
```

(Leave the rest of `generateSources` - the emitter calls - unchanged.)

- [ ] **Step 4: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Document `method_names` in `README.md`**

In the "Build options" table, add a row, and a sentence after the table:

```markdown
| `method_names` | `operationId` | How service method names are derived: `operationId` (default) or `path` (from the HTTP verb and request path). |
```

After the table, add:

```markdown
With `method_names: path`, `GET /vaults/{vaultUuid}/items` generates
`getVaultsVaultUuidItems`. The path form includes parameter segments so names
stay unique.
```

(Add the `method_names` row to the existing `swagger_generator` options example
in the README as a comment or option line is not required; the table documents
it.)

- [ ] **Step 6: Run the analyzer and commit**

Run: `dart analyze`
Expected: "No issues found!".

```bash
git add lib/src/builder/swagger_builder.dart test/builder/swagger_builder_test.dart README.md
git commit -m "Wire method_names through the builder and document it"
```

---

## Notes for the implementer

- The path naming reuses the exact fallback expression already in `_operation`, so there is one source of truth for the path form.
- `method_names` is a generation option read per consuming project; the generator `build.yaml` needs no change (options are supplied by consumers).
