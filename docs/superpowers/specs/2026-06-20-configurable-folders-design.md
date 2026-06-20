# Configurable Input/Output Folders - Design

Date: 2026-06-20

## Goal

Let a consuming project configure, in `build.yaml`, the folder it keeps its
OpenAPI specs in (input) and the folder the generated Dart is written to
(output), and run generation with `dart run build_runner build`. This matches
the UX of generators like `swagger_dart_code_generator`.

## Background: why this is possible with a Builder

An earlier assumption held that a build_runner Builder cannot write generated
files to a folder separate from the input. That is only true for a fixed
extension mapping (which is why our first `build_runner` run hit
`UnexpectedOutputException` when outputs landed beside the input).

build_runner supports **capture groups** in `buildExtensions`. A capture group
`{{}}` matches the spec's base name, and the input and output sides may carry
*different* path prefixes. build_runner derives each expected output AssetId
from that mapping, so writing into a different folder is permitted:

```
input_folder/{{}}.openapi.json  ->  output_folder/{{}}.enums.dart
                                     output_folder/{{}}.models.dart
                                     output_folder/{{}}.service.dart
                                     output_folder/{{}}.client.dart
                                     output_folder/{{}}.api.dart
```

The capture matches a single path segment (the spec sits directly in
`input_folder`). This is the mechanism `swagger_dart_code_generator` uses.

## Configuration

Options are read from `build.yaml` in the consuming project:

```yaml
targets:
  $default:
    builders:
      swagger_generator_flutter|swagger_generator:
        options:
          input_folder: api_specs
          output_folder: lib/generated
```

- `input_folder`: directory (relative to the package root) holding the
  `*.openapi.json` specs. Default: `lib` (specs found anywhere the builder
  already scans).
- `output_folder`: directory the generated `.dart` files are written to.
  Default: equal to `input_folder` (co-located), preserving current behavior.

Both folders are normalized: leading/trailing slashes trimmed to a single
internal form so the prefixes compose cleanly.

The output folder must be under `lib/` (build_runner only writes generated
source there). If `output_folder` is not under `lib/`, the builder fails fast
with a clear error naming the offending value.

## Builder changes

`swaggerBuilder(BuilderOptions options)` becomes options-aware:

- Read `input_folder` and `output_folder` from `options.config`, applying the
  defaults above.
- Construct `buildExtensions` dynamically from those prefixes using the capture
  group, instead of the current fixed `{'.openapi.json': [...]}` map. The five
  output extensions are unchanged.
- `SwaggerBuilder` holds the resolved `inputFolder` and `outputFolder` and
  exposes them to `build()`.

`build()`:

- Derive `baseName` from the input filename (strip the full `.openapi.json`
  suffix, as today via `outputAssetPath`'s suffix logic).
- For each generated source, compute the output AssetId as
  `<outputFolder>/<baseName><extension>` and write it. This must match exactly
  what build_runner derives from the capture-group `buildExtensions`.

The pure `generateSources` helper is unchanged: it already takes `baseName` and
returns the five sources. Only path wiring changes.

`runs_before: [json_serializable, chopper_generator]` is unchanged; those
builders run on the generated `.dart` files wherever they land under `lib/`.

## Components

- `lib/src/builder/builder_config.dart` (new): a small `BuilderConfig` value
  type with `inputFolder` and `outputFolder`, plus a `BuilderConfig.fromOptions`
  factory that reads `BuilderOptions.config`, applies defaults, normalizes
  slashes, and validates `output_folder` is under `lib/`. One responsibility:
  turn raw options into a validated config.
- `lib/src/builder/swagger_builder.dart` (modified): the factory builds a
  `BuilderConfig`; `SwaggerBuilder` takes it, derives `buildExtensions` and the
  output paths from it.

Keeping config parsing in its own unit keeps `SwaggerBuilder` focused on
orchestration and makes the option/default/validation logic independently
testable.

## Data flow

```
build.yaml options
  -> BuilderConfig.fromOptions (defaults, normalize, validate)
  -> SwaggerBuilder(config)
       buildExtensions: input_folder/{{}}.openapi.json -> output_folder/{{}}.*
       build(): read spec -> generateSources(baseName) -> write to output_folder
  -> json_serializable + chopper_generator (unchanged)
```

## Error handling

- Missing options: fall back to defaults (no error).
- `output_folder` not under `lib/`: throw a clear, named error at build time.
- Empty/whitespace option values: treated as unset (use default).

## Testing

- `BuilderConfig.fromOptions`:
  - defaults when options absent (`inputFolder == 'lib'`,
    `outputFolder == inputFolder`).
  - reads provided `input_folder` / `output_folder`.
  - normalizes surrounding slashes (`'lib/generated/'` -> `'lib/generated'`).
  - throws when `output_folder` is outside `lib/`.
- `buildExtensions` derivation: given a config, the map keys/values carry the
  configured prefixes and the `{{}}` capture plus the five extensions.
- Output path: `<outputFolder>/<baseName><ext>` for a sample input path.
- End-to-end in `example/`: set `input_folder` and `output_folder` in
  `build.yaml`, place a spec in the input folder, run `build_runner build`, and
  confirm the generated files appear in the output folder and analyze clean.

## Out of scope

- Nested input directory trees (specs are expected directly in `input_folder`).
- A standalone CLI (the Builder + `build_runner build` is the entry point).
- Per-spec output overrides.
```
