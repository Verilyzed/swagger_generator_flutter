# Config final fixes report

## Fix 1: captureStem precondition (lib/src/builder/builder_config.dart)

Added a doc comment above `captureStem` stating the precondition that
`inputPath` must be under `inputFolder` when `inputFolder` is non-empty, and
noting that build_runner guarantees this in normal use. Added an `assert` that
fires when `_inputPrefix` is non-empty but `inputPath` does not start with it.

## Fix 2: validation comment (lib/src/builder/builder_config.dart)

Added an explanatory comment above the `if (outputExplicit && ...)` validation
block in `BuilderConfig.fromOptions`, clarifying that validation only runs when
`output_folder` was explicitly provided, and that blank/whitespace values
normalize to empty and are treated as unset.

## Fix 3: subdirectory test (test/builder/builder_config_test.dart)

Added test `captureStem preserves subdirectories under the input folder`
verifying that `captureStem`, `baseNameFor`, and `outputPathFor` all handle a
nested path (`api_specs/v1/demo.openapi.json`) correctly:
- `captureStem` returns `'v1/demo'`
- `baseNameFor` returns `'demo'`
- `outputPathFor` with `.models.dart` returns `'lib/generated/v1/demo.models.dart'`

## Fix 4: build.yaml secondary outputs comment (build.yaml)

Added a three-line comment block just above `build_extensions:` explaining that
`.models.g.dart` and `.service.chopper.dart` are produced by downstream
builders (`json_serializable`, `chopper_generator`) referenced in `runs_before`,
not by this builder.

## Fix 5: README input_folder note (README.md)

Added a paragraph after the `output_folder` defaults sentence in the
"Configuring input and output folders" section, explaining that omitting
`input_folder` causes specs to be matched anywhere under package sources (output
co-located), and warning that setting `output_folder` without `input_folder`
leads to double-nested output paths.

## Verification

### dart test

Command: `dart test`
Result: 47 tests passed, 0 failures (includes the new subdirectory test at index 46).

### dart analyze

Command: `dart analyze`
Result: No issues found.
