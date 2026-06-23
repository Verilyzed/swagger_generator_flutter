# Generator Ergonomics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Named service-method parameters, a cross-spec barrel file, `.json`/`.yaml`/`.yml` input extensions, and a README documenting every build option.

**Architecture:** `ServiceEmitter` emits all parameters in the named group. `BuilderConfig` accepts three input extensions. A new `ApiBundleBuilder` (keyed on `$lib$`) aggregates the per-spec `.api.dart` barrels into one file. The README gains a build-options section.

**Tech Stack:** Dart, `package:build`, `package:glob`, `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Generated files begin with `// GENERATED CODE - DO NOT MODIFY BY HAND`.
- `output_folder`, when set, must be under `lib/`.
- `barrel_file` default is `index.dart`.

---

### Task 1: All-named service parameters

**Files:**
- Modify: `lib/src/emit/service_emitter.dart`
- Modify: `test/emit/service_emitter_test.dart`

**Interfaces:**
- Produces: every operation parameter is emitted inside the named `{}` group - required params with the `required` keyword, optional params with a default or nullable type.

- [ ] **Step 1: Update the service emitter test assertion for a required path param**

In `test/emit/service_emitter_test.dart`, in the test `'emits required path positional and optional query named'`, change the path assertion:

```dart
    expect(out, contains("@Path('gadget_id') required String gadgetId,"));
```

(The `listGadgets({`, `@Query('limit') int limit = 50,`, and
`@Query('status') StatusEnum? status,` assertions stay.)

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/emit/service_emitter_test.dart`
Expected: FAIL (current output has `@Path('gadget_id') String gadgetId` without `required`).

- [ ] **Step 3: Rewrite `_emitMethod` and `_namedParam` in `lib/src/emit/service_emitter.dart`**

```dart
  void _emitMethod(StringBuffer buffer, OperationDef op) {
    final verb = _verb(op.httpMethod);
    final named =
        op.parameters.map((p) => '    ${_namedParam(p)},').toList();

    buffer
      ..writeln("  @$verb(path: '${op.path}')")
      ..write(
        '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
      );

    if (named.isEmpty) {
      buffer.writeln(');');
    } else {
      buffer.writeln('{');
      for (final line in named) {
        buffer.writeln(line);
      }
      buffer.writeln('  });');
    }

    buffer.writeln();
  }

  String _namedParam(ParamDef p) {
    final annotation = _annotation(p);
    if (p.isRequired) {
      return '$annotation required ${p.type.display} ${p.dartName}';
    }
    if (p.defaultValue != null) {
      return '$annotation ${p.type.display} ${p.dartName} = ${p.defaultValue}';
    }
    final nullable = p.type.isNullable ? p.type.display : '${p.type.name}?';
    return '$annotation $nullable ${p.dartName}';
  }
```

(`_annotation` and `_verb` are unchanged.)

- [ ] **Step 4: Run the test, full suite, and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 5: Commit**

```bash
git add lib/src/emit/service_emitter.dart test/emit/service_emitter_test.dart
git commit -m "Emit all service parameters as named"
```

---

### Task 2: Accept .json, .yaml, and .yml inputs

**Files:**
- Modify: `lib/src/builder/builder_config.dart`
- Modify: `test/builder/builder_config_test.dart`
- Modify: `build.yaml`

**Interfaces:**
- Produces: `BuilderConfig.buildExtensions` has `.json`/`.yaml`/`.yml` input keys; `captureStem` strips whichever matched.

- [ ] **Step 1: Add failing tests to `test/builder/builder_config_test.dart`**

```dart
  test('buildExtensions cover json, yaml, and yml inputs', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(config.buildExtensions.keys, containsAll(<String>[
      '{{}}.json',
      '{{}}.yaml',
      '{{}}.yml',
    ]));
  });

  test('outputPathFor strips a yaml suffix', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(
      config.outputPathFor('lib/demo.yaml', '.models.dart'),
      'lib/demo.models.dart',
    );
    expect(
      config.outputPathFor('lib/demo.json', '.enums.dart'),
      'lib/demo.enums.dart',
    );
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/builder/builder_config_test.dart`
Expected: FAIL (only `.openapi.json` key exists; `.yaml` not stripped).

- [ ] **Step 3: Update `lib/src/builder/builder_config.dart`**

Add the input extensions constant near `_extensions`:

```dart
  static const _inputExtensions = ['.json', '.yaml', '.yml'];
```

Replace `buildExtensions`:

```dart
  Map<String, List<String>> get buildExtensions => {
        for (final inExt in _inputExtensions)
          '$_inputPrefix{{}}$inExt': [
            for (final ext in _extensions) '$_outputPrefix{{}}$ext',
          ],
      };
```

Replace the suffix strip in `captureStem`:

```dart
    return path.replaceFirst(RegExp(r'\.(json|ya?ml)$'), '');
```

Update the doc comment on `captureStem` to say "the input prefix and the
`.json`/`.yaml`/`.yml` suffix removed".

- [ ] **Step 4: Update the generator `build.yaml` static extensions**

Replace the `swagger_generator` builder's `build_extensions` block with the
three input keys:

```yaml
    build_extensions:
      "{{}}.json":
        - "{{}}.enums.dart"
        - "{{}}.models.dart"
        - "{{}}.service.dart"
        - "{{}}.client.dart"
        - "{{}}.api.dart"
      "{{}}.yaml":
        - "{{}}.enums.dart"
        - "{{}}.models.dart"
        - "{{}}.service.dart"
        - "{{}}.client.dart"
        - "{{}}.api.dart"
      "{{}}.yml":
        - "{{}}.enums.dart"
        - "{{}}.models.dart"
        - "{{}}.service.dart"
        - "{{}}.client.dart"
        - "{{}}.api.dart"
```

- [ ] **Step 5: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 6: Commit**

```bash
git add lib/src/builder/builder_config.dart test/builder/builder_config_test.dart build.yaml
git commit -m "Accept json, yaml, and yml spec inputs"
```

---

### Task 3: ApiBundleBuilder for a cross-spec barrel

**Files:**
- Create: `lib/src/builder/bundle_config.dart`
- Create: `lib/src/builder/api_bundle_builder.dart`
- Modify: `lib/swagger_generator_flutter.dart`
- Modify: `build.yaml`
- Modify: `pubspec.yaml`
- Test: `test/builder/bundle_config_test.dart`
- Test: `test/builder/api_bundle_builder_test.dart`

**Interfaces:**
- Produces: `BundleConfig(outputFolder, barrelFile)` with `fromOptions`, `folder`, `barrelPath`, `glob`; `apiBundleBuilder(BuilderOptions)` factory; `String bundleSource(Iterable<String> apiFileNames)`.

- [ ] **Step 1: Add the `glob` dependency to `pubspec.yaml`**

Under `dependencies:` add:

```yaml
  glob: ^2.1.0
```

Run: `dart pub get`
Expected: resolves.

- [ ] **Step 2: Write the failing `BundleConfig` test `test/builder/bundle_config_test.dart`**

```dart
import 'package:build/build.dart';
import 'package:swagger_generator_flutter/src/builder/bundle_config.dart';
import 'package:test/test.dart';

void main() {
  test('defaults to lib and index.dart', () {
    final config = BundleConfig.fromOptions(const BuilderOptions({}));
    expect(config.outputFolder, '');
    expect(config.barrelFile, 'index.dart');
    expect(config.barrelPath, 'lib/index.dart');
    expect(config.glob, 'lib/*.api.dart');
  });

  test('reads output_folder and barrel_file', () {
    final config = BundleConfig.fromOptions(const BuilderOptions({
      'output_folder': 'lib/generated',
      'barrel_file': 'api.dart',
    }));
    expect(config.barrelPath, 'lib/generated/api.dart');
    expect(config.glob, 'lib/generated/*.api.dart');
  });

  test('throws when output_folder is not under lib', () {
    expect(
      () => BundleConfig.fromOptions(
        const BuilderOptions({'output_folder': 'build/out'}),
      ),
      throwsArgumentError,
    );
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `dart test test/builder/bundle_config_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 4: Create `lib/src/builder/bundle_config.dart`**

```dart
import 'package:build/build.dart';

/// Configuration for the aggregate barrel builder.
class BundleConfig {
  final String outputFolder;
  final String barrelFile;

  const BundleConfig({required this.outputFolder, required this.barrelFile});

  factory BundleConfig.fromOptions(BuilderOptions options) {
    final output = _normalize(options.config['output_folder']);
    if (output.isNotEmpty && output != 'lib' && !output.startsWith('lib/')) {
      throw ArgumentError.value(
        output,
        'output_folder',
        'output_folder must be under lib/',
      );
    }
    final rawBarrel = options.config['barrel_file'];
    final barrelFile = rawBarrel is String && rawBarrel.trim().isNotEmpty
        ? rawBarrel.trim()
        : 'index.dart';
    return BundleConfig(outputFolder: output, barrelFile: barrelFile);
  }

  String get folder => outputFolder.isEmpty ? 'lib' : outputFolder;

  String get barrelPath => '$folder/$barrelFile';

  String get glob => '$folder/*.api.dart';

  static String _normalize(Object? value) {
    if (value is! String) return '';
    return value
        .trim()
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/+$'), '');
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `dart test test/builder/bundle_config_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Write the failing `bundleSource` test `test/builder/api_bundle_builder_test.dart`**

```dart
import 'package:swagger_generator_flutter/src/builder/api_bundle_builder.dart';
import 'package:test/test.dart';

void main() {
  test('emits sorted export lines with the generated banner', () {
    final out = bundleSource(['newapi.api.dart', 'demo.api.dart']);
    expect(out, startsWith('// GENERATED CODE'));
    final exportLines = out
        .split('\n')
        .where((l) => l.startsWith('export '))
        .toList();
    expect(exportLines, [
      "export 'demo.api.dart';",
      "export 'newapi.api.dart';",
    ]);
  });
}
```

- [ ] **Step 7: Run the test to verify it fails**

Run: `dart test test/builder/api_bundle_builder_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 8: Create `lib/src/builder/api_bundle_builder.dart`**

```dart
import 'package:build/build.dart';
import 'package:glob/glob.dart';

import '../emit/source_writer.dart';
import 'bundle_config.dart';

Builder apiBundleBuilder(BuilderOptions options) =>
    ApiBundleBuilder(BundleConfig.fromOptions(options));

/// Aggregates the per-spec `*.api.dart` barrels into one export file.
class ApiBundleBuilder implements Builder {
  final BundleConfig config;

  ApiBundleBuilder(this.config);

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': [config.barrelPath],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final names = <String>[];
    await for (final asset in buildStep.findAssets(Glob(config.glob))) {
      names.add(asset.pathSegments.last);
    }
    if (names.isEmpty) return;
    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, config.barrelPath),
      bundleSource(names),
    );
  }
}

/// Builds the barrel file content from the discovered `.api.dart` file names.
String bundleSource(Iterable<String> apiFileNames) {
  final sorted = apiFileNames.toList()..sort();
  final buffer = StringBuffer()..write(SourceWriter.header());
  for (final name in sorted) {
    buffer.writeln("export '$name';");
  }
  return buffer.toString();
}
```

- [ ] **Step 9: Run the test to verify it passes**

Run: `dart test test/builder/api_bundle_builder_test.dart`
Expected: PASS.

- [ ] **Step 10: Export the bundle builder from `lib/swagger_generator_flutter.dart`**

```dart
/// Generates Dart code from OpenAPI (Swagger) specifications.
library;

export 'src/builder/api_bundle_builder.dart';
export 'src/builder/swagger_builder.dart';
```

- [ ] **Step 11: Declare the bundle builder in `build.yaml`**

Add a second builder under `builders:`:

```yaml
  swagger_api_bundle:
    import: "package:swagger_generator_flutter/swagger_generator_flutter.dart"
    builder_factories: ["apiBundleBuilder"]
    build_extensions:
      $lib$:
        - "lib/index.dart"
    auto_apply: dependents
    build_to: source
    required_inputs: [".api.dart"]
```

- [ ] **Step 12: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

- [ ] **Step 13: Commit**

```bash
git add lib/src/builder/bundle_config.dart lib/src/builder/api_bundle_builder.dart lib/swagger_generator_flutter.dart build.yaml pubspec.yaml pubspec.lock test/builder/bundle_config_test.dart test/builder/api_bundle_builder_test.dart
git commit -m "Add ApiBundleBuilder for a cross-spec barrel file"
```

---

### Task 4: Document build options in the README

**Files:**
- Modify: `README.md`

**Interfaces:**
- Produces: a "Build options" section listing `input_folder`, `output_folder`, `barrel_file`, and the accepted input extensions.

- [ ] **Step 1: Replace the existing "Configuring input and output folders" section in `README.md`**

Replace that section with:

```markdown
## Build options

Configure the generator in the consuming project's `build.yaml`:

```yaml
targets:
  $default:
    builders:
      swagger_generator_flutter|swagger_generator:
        options:
          input_folder: lib/specs
          output_folder: lib/generated
      swagger_generator_flutter|swagger_api_bundle:
        options:
          output_folder: lib/generated
          barrel_file: index.dart
```

| Option | Builder | Default | Description |
| --- | --- | --- | --- |
| `input_folder` | swagger_generator | package sources | Folder holding the spec files (`.json`, `.yaml`, or `.yml`). |
| `output_folder` | both | same as `input_folder` (co-located) | Folder the generated Dart is written to. Must be under `lib/`. |
| `barrel_file` | swagger_api_bundle | `index.dart` | Name of the aggregate export file written into the output folder. |

The aggregate barrel re-exports every generated `*.api.dart`, so an app imports
a single file. When `output_folder` is omitted, output is co-located with each
spec and the barrel is written to `lib/`.
```

- [ ] **Step 2: Verify the analyzer (no code change) and that the README has no placeholders**

Run: `dart analyze`
Expected: "No issues found!".

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "Document build options in the README"
```

---

### Task 5: Migrate the example and verify end to end

Rename the example specs to `.json`, wire the bundle builder, regenerate, and
round-trip a named-parameter call.

**Files:**
- Rename: `example/lib/specs/resource_scheduler.openapi.json` -> `resource_scheduler.json`; `newapi.openapi.json` -> `newapi.json`
- Modify: `example/build.yaml`, `test/e2e/generation_test.dart`
- Commit: regenerated `example/lib/generated/` including `index.dart`

**Interfaces:**
- Consumes: Tasks 1-3.

- [ ] **Step 1: Rename the example specs and update the e2e fixture path**

```bash
git mv example/lib/specs/resource_scheduler.openapi.json example/lib/specs/resource_scheduler.json
git mv example/lib/specs/newapi.openapi.json example/lib/specs/newapi.json
```

In `test/e2e/generation_test.dart`, change the path to
`example/lib/specs/resource_scheduler.json`.

Run: `dart test test/e2e/generation_test.dart`
Expected: PASS.

- [ ] **Step 2: Configure the bundle builder in `example/build.yaml`**

```yaml
targets:
  $default:
    builders:
      swagger_generator_flutter|swagger_generator:
        options:
          input_folder: lib/specs
          output_folder: lib/generated
      swagger_generator_flutter|swagger_api_bundle:
        options:
          output_folder: lib/generated
```

- [ ] **Step 3: Regenerate and confirm clean output, named params, and the barrel**

From the repo root:
```bash
cd example && dart run build_runner build && flutter analyze 2>&1 | tail -1
cd ..
grep -E "required String vaultUuid|required String itemUuid" example/lib/generated/newapi.service.dart
cat example/lib/generated/index.dart
```
Expected: `flutter analyze` clean; the service methods use `required String ...`
named params; `example/lib/generated/index.dart` exports `newapi.api.dart` and
`resource_scheduler.api.dart`. If `index.dart` is missing, check the bundle
builder ran (it requires the `.api.dart` inputs).

- [ ] **Step 4: Round-trip a named-parameter call**

Write `example/bin/named_check.dart` (confirm the method name from
`example/lib/generated/newapi.service.dart` first):
```dart
import 'package:chopper/chopper.dart';
import 'package:example/generated/index.dart';

Future<void> main() async {
  final client = createClient(baseUrl: Uri.parse('http://localhost:8000'));
  final service = NewapiService.create(client);

  final res = await service.getVaultById(vaultUuid: 'v1');
  print('getVaultById(vaultUuid: ...) -> ${res.statusCode}, '
      'is Vault: ${res.body is Vault}');
  if (res.body is! Vault) {
    throw StateError('vault did not deserialize: ${res.body.runtimeType}');
  }

  client.dispose();
  print('RUNTIME OK');
}
```
Create `example/tool/mock_vault.py`:
```python
import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = json.dumps({"id": "v1", "name": "Personal", "type": "PERSONAL"}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
```
Start the mock in the background, then run from `example/`:
```bash
dart run bin/named_check.dart
```
Expected: prints `is Vault: true` and `RUNTIME OK`. (The import is the single
`package:example/generated/index.dart` barrel.) The call uses the named argument
`vaultUuid: 'v1'`, proving named parameters compile and work.

- [ ] **Step 5: Tear down the temporary files**

From the repo root:
```bash
pkill -f mock_vault.py
rm -f example/bin/named_check.dart example/tool/mock_vault.py
rmdir example/bin example/tool 2>/dev/null
cd example && dart run build_runner build >/dev/null 2>&1 && cd ..
```

- [ ] **Step 6: Commit the example migration and regenerated output**

```bash
git add example/lib/specs example/build.yaml example/lib/generated test/e2e/generation_test.dart
git commit -m "Migrate example specs to .json with a generated index barrel"
```

---

## Notes for the implementer

- The bundle builder is keyed on `$lib$`, so it runs once per package; `required_inputs: ['.api.dart']` makes it run after the per-spec generation.
- `BundleConfig` and `BuilderConfig` both validate `output_folder` under `lib/`; they are separate because they are configured on separate builders.
- Chopper named `@Path`/`@Body` support is the one runtime unknown - Task 5's round-trip confirms it. If chopper rejects a named `@Path`, fall back to keeping path params positional and only making query/body named, and note it.
