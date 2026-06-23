# Generator Ergonomics - Design

Date: 2026-06-23

## Goal

Four ergonomics improvements to the generator:

1. Named service-method parameters, so call sites read `getContract(contractId: id)`.
2. A single cross-spec barrel file in the output folder, so an app imports one file.
3. Looser input extensions: accept `.json`, `.yaml`, `.yml` (not only `.openapi.json`).
4. README documents every `build.yaml` option.

## A. All-named parameters (ServiceEmitter)

Every parameter moves into the trailing named group. `_emitMethod` drops the
positional/named split and emits one `{}` group:

- Required parameter (path, required query, required body):
  `required <annotation> <type> <name>`.
- Optional with a default: `<annotation> <type> <name> = <default>`.
- Optional without a default: `<annotation> <nullableType> <name>`.

A method with no parameters stays `method()`; otherwise `method({ ... })`.

```dart
@GET(path: '/contracts/{contractId}')
Future<Response<Contract>> getContract({
  @Path('contractId') required String contractId,
  @Query('expand') String? expand,
});
```

Runtime check (verified in the round-trip): Chopper accepts named `@Path` and
`@Body` parameters.

## B. Cross-spec barrel (ApiBundleBuilder)

The per-spec `<spec>.api.dart` barrel covers one spec. A new builder aggregates
across specs.

- `lib/src/builder/bundle_config.dart` (new): `BundleConfig` with `outputFolder`
  and `barrelFile`, plus `fromOptions(BuilderOptions)`. `barrel_file` defaults to
  `index.dart`; `output_folder` is read the same way `BuilderConfig` reads it
  (must be under `lib/`).
- `lib/src/builder/api_bundle_builder.dart` (new): `apiBundleBuilder(BuilderOptions)`
  factory and `ApiBundleBuilder implements Builder`. It is keyed on the `$lib$`
  synthetic input (runs once per package). `build` globs
  `<outputFolder>/*.api.dart` (or `lib/**.api.dart` when no `output_folder` is
  set), and writes `<outputFolder>/<barrelFile>` re-exporting each found file by
  its bare filename. Sorted for deterministic output.
- `build.yaml`: declare the bundle builder with `required_inputs: ['.api.dart']`
  so it runs after the per-spec generation, `auto_apply: dependents`,
  `build_to: source`.

Output example (`lib/generated/index.dart`):

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
export 'newapi.api.dart';
export 'resource_scheduler.api.dart';
```

## C. Looser input extensions (BuilderConfig)

`BuilderConfig.buildExtensions` gains three input keys - `.json`, `.yaml`,
`.yml` - each mapping to the five existing outputs:

```
<inputPrefix>{{}}.json -> <outputPrefix>{{}}.enums.dart, ... (5)
<inputPrefix>{{}}.yaml -> ...
<inputPrefix>{{}}.yml  -> ...
```

`captureStem` strips whichever of `.json`/`.yaml`/`.yml` matched (regex
`\.(json|ya?ml)$`). `baseNameFor` and `outputPathFor` are unchanged otherwise.
`SpecLoader` already chooses JSON vs YAML by extension, so it needs no change.

The example specs are renamed `resource_scheduler.json` and `newapi.json`, and
`test/e2e/generation_test.dart` reads the `.json` path.

Note: with an input folder configured, only files in that folder are matched, so
treating any `.json`/`.yaml`/`.yml` there as a spec is safe.

## D. README build options

Add a "Build options" section to `README.md` documenting every option under the
`swagger_generator_flutter|swagger_generator` (and bundle) builder:

- `input_folder` - folder holding the spec files. Default: package sources
  (specs matched anywhere). Specs may be `.json`, `.yaml`, or `.yml`.
- `output_folder` - folder the generated Dart is written to. Must be under
  `lib/`. Default: same as `input_folder` (co-located).
- `barrel_file` - name of the aggregate export file written into the output
  folder. Default: `index.dart`.

With a complete `build.yaml` example and the note that `output_folder` must be
under `lib/`.

## Components touched

- `lib/src/emit/service_emitter.dart` (A)
- `lib/src/builder/builder_config.dart` (C)
- `lib/src/builder/bundle_config.dart`, `lib/src/builder/api_bundle_builder.dart` (B, new)
- `build.yaml` (B)
- `README.md` (D)
- `example/lib/specs/*.json` (renamed), `example/build.yaml`, `test/e2e/generation_test.dart` (C)

## Testing

- `ServiceEmitter`: a required path param emits `required @Path(...)` inside the
  named group; an optional query param keeps its default; a no-param method
  emits `()`.
- `BundleConfig.fromOptions`: defaults (`index.dart`); reads `barrel_file` and
  `output_folder`; validates output under `lib/`.
- `ApiBundleBuilder`: given globbed `.api.dart` assets, the helper that builds
  the barrel content emits sorted `export` lines.
- `BuilderConfig`: `buildExtensions` includes `.json`/`.yaml`/`.yml` keys;
  `captureStem` strips each; `outputPathFor` works for a `.yaml` input.
- End-to-end: rename example specs to `.json`, run `build_runner`, confirm
  `flutter analyze` clean, the methods take named params, `lib/generated/index.dart`
  exports both specs, and a round-trip call uses `name: value` arguments.

## Out of scope

- Per-spec barrel customization beyond the single aggregate file.
- Input formats other than JSON/YAML.
