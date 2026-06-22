# Configurable Input/Output Folders Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a consuming project configure the OpenAPI spec input folder and the generated-code output folder via `build.yaml` options, generated with `build_runner build`.

**Architecture:** A `BuilderConfig` value type reads `input_folder`/`output_folder` from `BuilderOptions`, applies defaults (co-located), normalizes, and validates. The builder derives capture-group `buildExtensions` (`<input>/{{}}.openapi.json -> <output>/{{}}.<ext>`) from the config so build_runner permits writing into the output folder, and computes each output path the same way build_runner derives it.

**Tech Stack:** Dart, `package:build` (build_runner Builder), `package:test`.

## Global Constraints

- No emojis anywhere (code, comments, docs, commit messages).
- Single quotes, trailing commas; `dart analyze` clean; `dart test` green.
- TDD: no production code without a failing test first.
- Default behavior (no options) MUST stay byte-identical to today: co-located outputs, matching any `*.openapi.json` under the package's sources. The committed `example/` (spec at `example/lib/resource_scheduler.openapi.json`, co-located generated files) must still build unchanged with no options.
- `output_folder`, when set, must be under `lib/` (build_runner only writes generated source there); otherwise fail fast.
- The five output extensions are unchanged: `.enums.dart`, `.models.dart`, `.service.dart`, `.client.dart`, `.api.dart`.

---

### Task 1: BuilderConfig

**Files:**
- Create: `lib/src/builder/builder_config.dart`
- Test: `test/builder/builder_config_test.dart`

**Interfaces:**
- Consumes: `BuilderOptions`, `AssetId` from `package:build/build.dart`.
- Produces: `BuilderConfig` with:
  - `const BuilderConfig({required String inputFolder, required String outputFolder})`
  - `factory BuilderConfig.fromOptions(BuilderOptions options)` (reads `input_folder`/`output_folder`, normalizes, defaults `output` to `input`, validates output under `lib/`)
  - `Map<String, List<String>> get buildExtensions`
  - `String captureStem(String inputPath)`
  - `String baseNameFor(String inputPath)`
  - `String outputPathFor(String inputPath, String extension)`

- [ ] **Step 1: Write the failing test `test/builder/builder_config_test.dart`**

```dart
import 'package:build/build.dart';
import 'package:swagger_generator_flutter/src/builder/builder_config.dart';
import 'package:test/test.dart';

void main() {
  test('defaults to co-located when no options are given', () {
    final config = BuilderConfig.fromOptions(BuilderOptions({}));
    expect(config.inputFolder, '');
    expect(config.outputFolder, '');
  });

  test('output_folder defaults to input_folder when only input is set', () {
    final config = BuilderConfig.fromOptions(
      BuilderOptions({'input_folder': 'api_specs'}),
    );
    expect(config.inputFolder, 'api_specs');
    expect(config.outputFolder, 'api_specs');
  });

  test('reads and normalizes both folders', () {
    final config = BuilderConfig.fromOptions(
      BuilderOptions({
        'input_folder': 'api_specs/',
        'output_folder': '/lib/generated/',
      }),
    );
    expect(config.inputFolder, 'api_specs');
    expect(config.outputFolder, 'lib/generated');
  });

  test('throws when output_folder is not under lib', () {
    expect(
      () => BuilderConfig.fromOptions(
        BuilderOptions({'output_folder': 'build/out'}),
      ),
      throwsArgumentError,
    );
  });

  test('default buildExtensions match any openapi.json co-located', () {
    final config = BuilderConfig.fromOptions(BuilderOptions({}));
    expect(config.buildExtensions, {
      '{{}}.openapi.json': [
        '{{}}.enums.dart',
        '{{}}.models.dart',
        '{{}}.service.dart',
        '{{}}.client.dart',
        '{{}}.api.dart',
      ],
    });
  });

  test('configured buildExtensions carry input and output prefixes', () {
    final config = BuilderConfig.fromOptions(
      BuilderOptions({
        'input_folder': 'api_specs',
        'output_folder': 'lib/generated',
      }),
    );
    expect(config.buildExtensions, {
      'api_specs/{{}}.openapi.json': [
        'lib/generated/{{}}.enums.dart',
        'lib/generated/{{}}.models.dart',
        'lib/generated/{{}}.service.dart',
        'lib/generated/{{}}.client.dart',
        'lib/generated/{{}}.api.dart',
      ],
    });
  });

  test('default outputPathFor is co-located, replacing the full suffix', () {
    final config = BuilderConfig.fromOptions(BuilderOptions({}));
    expect(
      config.outputPathFor('lib/resource_scheduler.openapi.json', '.enums.dart'),
      'lib/resource_scheduler.enums.dart',
    );
  });

  test('configured outputPathFor strips input prefix and applies output prefix', () {
    final config = BuilderConfig.fromOptions(
      BuilderOptions({
        'input_folder': 'api_specs',
        'output_folder': 'lib/generated',
      }),
    );
    expect(
      config.outputPathFor('api_specs/demo.openapi.json', '.models.dart'),
      'lib/generated/demo.models.dart',
    );
    expect(config.baseNameFor('api_specs/demo.openapi.json'), 'demo');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/builder/builder_config_test.dart`
Expected: FAIL (uri does not exist).

- [ ] **Step 3: Create `lib/src/builder/builder_config.dart`**

```dart
import 'package:build/build.dart';

/// Resolved input/output folder configuration for the builder.
///
/// Folders are normalized to have no surrounding slashes; an empty string
/// means "the package root" (co-located with the input).
class BuilderConfig {
  final String inputFolder;
  final String outputFolder;

  const BuilderConfig({required this.inputFolder, required this.outputFolder});

  factory BuilderConfig.fromOptions(BuilderOptions options) {
    final input = _normalize(options.config['input_folder']);
    final rawOutput = _normalize(options.config['output_folder']);
    final output = rawOutput.isEmpty ? input : rawOutput;
    if (output.isNotEmpty && output != 'lib' && !output.startsWith('lib/')) {
      throw ArgumentError.value(
        output,
        'output_folder',
        'output_folder must be under lib/ '
            '(build_runner only writes generated source there)',
      );
    }
    return BuilderConfig(inputFolder: input, outputFolder: output);
  }

  static const _extensions = [
    '.enums.dart',
    '.models.dart',
    '.service.dart',
    '.client.dart',
    '.api.dart',
  ];

  String get _inputPrefix => inputFolder.isEmpty ? '' : '$inputFolder/';
  String get _outputPrefix => outputFolder.isEmpty ? '' : '$outputFolder/';

  Map<String, List<String>> get buildExtensions => {
        '$_inputPrefix{{}}.openapi.json': [
          for (final ext in _extensions) '$_outputPrefix{{}}$ext',
        ],
      };

  /// The portion of [inputPath] captured by `{{}}`: the input prefix and the
  /// `.openapi.json` suffix removed, any subdirectories preserved.
  String captureStem(String inputPath) {
    var path = inputPath;
    if (_inputPrefix.isNotEmpty && path.startsWith(_inputPrefix)) {
      path = path.substring(_inputPrefix.length);
    }
    return path.replaceFirst(RegExp(r'\.openapi\.json$'), '');
  }

  /// The bare base name (last path segment) used for cross-file imports.
  String baseNameFor(String inputPath) => captureStem(inputPath).split('/').last;

  /// The output asset path for [extension], matching what build_runner derives
  /// from [buildExtensions].
  String outputPathFor(String inputPath, String extension) =>
      '$_outputPrefix${captureStem(inputPath)}$extension';

  static String _normalize(Object? value) {
    if (value is! String) return '';
    return value
        .trim()
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/+$'), '');
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `dart test test/builder/builder_config_test.dart`
Expected: PASS (8 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/builder/builder_config.dart test/builder/builder_config_test.dart
git commit -m "Add BuilderConfig for input/output folder options"
```

---

### Task 2: Wire BuilderConfig into the builder

**Files:**
- Modify: `lib/src/builder/swagger_builder.dart`
- Modify: `test/builder/swagger_builder_test.dart`
- Modify: `build.yaml`

**Interfaces:**
- Consumes: `BuilderConfig` (Task 1).
- Produces: `swaggerBuilder(BuilderOptions)` builds a `BuilderConfig`; `SwaggerBuilder(BuilderConfig config)` whose `buildExtensions` and output paths come from the config. The pure `generateSources(content, {required path, required baseName})` is unchanged. The top-level `outputAssetPath` function is removed (its logic now lives in `BuilderConfig.outputPathFor`).

- [ ] **Step 1: Update the failing test in `test/builder/swagger_builder_test.dart`**

Replace the existing `outputAssetPath` test (the test named `'outputAssetPath replaces the full .openapi.json suffix'`) with this test that exercises the config-driven path through the builder helper. Leave the `'generateSources produces the five output files'` test unchanged.

```dart
  test('default config writes outputs co-located with the spec', () {
    final config = BuilderConfig.fromOptions(BuilderOptions({}));
    expect(
      config.outputPathFor('lib/resource_scheduler.openapi.json', '.enums.dart'),
      'lib/resource_scheduler.enums.dart',
    );
  });
```

Add these imports at the top of the test file (alongside the existing imports):

```dart
import 'package:build/build.dart';
import 'package:swagger_generator_flutter/src/builder/builder_config.dart';
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `dart test test/builder/swagger_builder_test.dart`
Expected: FAIL (the old `outputAssetPath` reference is gone / new test references `BuilderConfig` before wiring; compile error).

- [ ] **Step 3: Rewrite `lib/src/builder/swagger_builder.dart`**

Replace the top of the file (the import block, factory, class, and the old `outputAssetPath` function) with the following. Keep the `generateSources` function below it exactly as it currently is.

```dart
import 'package:build/build.dart';

import '../emit/client_emitter.dart';
import '../emit/enum_emitter.dart';
import '../emit/model_emitter.dart';
import '../emit/service_emitter.dart';
import '../parser/spec_loader.dart';
import '../parser/spec_parser.dart';
import '../resolve/dart_type_resolver.dart';
import '../resolve/name_giver.dart';
import 'builder_config.dart';

Builder swaggerBuilder(BuilderOptions options) =>
    SwaggerBuilder(BuilderConfig.fromOptions(options));

/// Generates Dart sources from a `*.openapi.json` spec asset.
class SwaggerBuilder implements Builder {
  final BuilderConfig config;

  SwaggerBuilder(this.config);

  @override
  Map<String, List<String>> get buildExtensions => config.buildExtensions;

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final content = await buildStep.readAsString(input);
    final baseName = config.baseNameFor(input.path);

    final sources = generateSources(
      content,
      path: input.path,
      baseName: baseName,
    );

    for (final entry in sources.entries) {
      await buildStep.writeAsString(
        AssetId(input.package, config.outputPathFor(input.path, entry.key)),
        entry.value,
      );
    }
  }
}
```

(Delete the old `String outputAssetPath(...)` function. Leave `generateSources` and everything after it unchanged.)

- [ ] **Step 4: Run the builder tests to verify they pass**

Run: `dart test test/builder/`
Expected: PASS (the updated `swagger_builder_test.dart` plus `builder_config_test.dart`).

- [ ] **Step 5: Remove the static `build_extensions` from `build.yaml`**

The builder's extensions are now dynamic (options-dependent), so they must not be hardcoded. Edit `build.yaml` to delete the `build_extensions:` block under the `swagger_generator` builder. The result is:

```yaml
builders:
  swagger_generator:
    import: "package:swagger_generator_flutter/swagger_generator_flutter.dart"
    builder_factories: ["swaggerBuilder"]
    auto_apply: dependents
    build_to: source
    runs_before:
      - "json_serializable:json_serializable"
      - "chopper_generator:chopper_generator"
```

- [ ] **Step 6: Run the full suite and analyzer**

Run: `dart test && dart analyze`
Expected: all tests PASS, "No issues found!".

- [ ] **Step 7: Commit**

```bash
git add lib/src/builder/swagger_builder.dart test/builder/swagger_builder_test.dart build.yaml
git commit -m "Drive builder extensions and output paths from BuilderConfig"
```

---

### Task 3: End-to-end verification of configured folders

Prove that `build.yaml` options actually relocate the generated output, using the `example/` app. This is verification only - the `example/` changes are reverted afterward so the committed example (co-located default) is untouched.

**Files:**
- None committed. Temporary, reverted: `example/build.yaml`, `example/lib/generated/`.

**Interfaces:**
- Consumes: the wired builder (Tasks 1-2).

- [ ] **Step 1: Confirm the default (no-options) build still works co-located**

From the repo root:
```bash
cd example && dart run build_runner build && flutter analyze
```
Expected: build succeeds; `flutter analyze` reports `No issues found!` (the committed co-located `resource_scheduler.*.dart` regenerate in place). Return to repo root: `cd ..`.

- [ ] **Step 2: Add a temporary `example/build.yaml` configuring an output folder**

Create `example/build.yaml`:
```yaml
targets:
  $default:
    builders:
      swagger_generator_flutter|swagger_generator:
        options:
          input_folder: lib
          output_folder: lib/generated
```

- [ ] **Step 3: Clean and rebuild so the configured mapping takes effect**

From the repo root:
```bash
cd example && dart run build_runner clean && dart run build_runner build && flutter analyze && cd ..
```
Expected: build_runner writes `example/lib/generated/resource_scheduler.enums.dart`, `.models.dart` (+ `.models.g.dart`), `.service.dart` (+ `.service.chopper.dart`), `.client.dart`, `.api.dart`, and `flutter analyze` reports `No issues found!`.

- [ ] **Step 4: Confirm the files landed in the configured folder**

Run from the repo root:
```bash
ls example/lib/generated/
```
Expected: lists the `resource_scheduler.*` generated files (enums, models, models.g, service, service.chopper, client, api). If the build instead failed with `UnexpectedOutputException` or wrote to the wrong location, that is a real defect in `BuilderConfig.outputPathFor` / `buildExtensions` - record the exact paths build_runner expected vs wrote, fix `BuilderConfig` (with a failing unit test added in `test/builder/builder_config_test.dart` first), re-run `dart test` and `dart analyze`, and repeat from Step 3.

- [ ] **Step 5: Revert all example changes**

From the repo root:
```bash
rm -rf example/lib/generated
rm -f example/build.yaml
cd example && dart run build_runner build >/dev/null && cd ..
git checkout -- example/
git status --short
```
Expected: `git status --short` shows no `example/` changes (working tree clean for `example/`). The final `build_runner build` restores the committed co-located outputs; `git checkout -- example/` discards any incidental regeneration differences.

- [ ] **Step 6: Document the option in the README**

Add a short section to `README.md` after the existing content describing the option:

```markdown
## Configuring input and output folders

By default the generator writes each `<name>.openapi.json` spec's Dart output
next to the spec. To place specs and generated code in specific folders,
configure the builder in the consuming project's `build.yaml`:

```yaml
targets:
  $default:
    builders:
      swagger_generator_flutter|swagger_generator:
        options:
          input_folder: lib
          output_folder: lib/generated
```

`output_folder` must be under `lib/`. If `output_folder` is omitted it defaults
to `input_folder` (co-located).
```

- [ ] **Step 7: Run the full Dart suite and analyzer, then commit the README**

Run from the repo root: `dart test && dart analyze`
Expected: all PASS, "No issues found!".

```bash
git add README.md
git commit -m "Document configurable input and output folders"
```

---

## Notes for the implementer

- The capture group `{{}}` in `buildExtensions` matches the spec's stem (it can include subdirectories). `BuilderConfig.outputPathFor` reproduces build_runner's substitution exactly, which is why the build does not raise `UnexpectedOutputException`.
- When `input_folder` is empty (default) the key is `{{}}.openapi.json`, which matches any spec under the package's sources and writes co-located - identical to the previous fixed mapping.
- Setting `output_folder` without `input_folder` would let the captured stem include `lib/`, nesting the output (e.g. `lib/generated/lib/...`); that is why Step 2's `build.yaml` sets `input_folder: lib`. This is expected behavior, documented in the README example.
