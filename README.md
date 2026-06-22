# Swagger Generator Flutter

Generate Dart / Flutter code from OpenAPI (Swagger) specifications
(`.json`, `.yaml`, `.yml`).

## Status

Early development. No code generation is implemented yet — the goal is a tool
that turns OpenAPI definitions into Dart models and API clients. This README
will document the actual commands, configuration, and output as they are built.

## Goal

Read an OpenAPI / Swagger specification and emit type-safe Dart code (models
with JSON serialization, and API clients) usable in any Dart or Flutter project.
Generation is intended to run through
[`build_runner`](https://pub.dev/packages/build_runner).

## Requirements

- [Dart SDK](https://dart.dev/get-dart) `^3.8.0`
- [Flutter](https://docs.flutter.dev/get-started/install) (only if generating
  into a Flutter app)

## Development

Fetch dependencies:

```bash
flutter pub get
```

Run the analyzer and tests:

```bash
dart analyze
dart test
```

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

If `input_folder` is omitted, specs are matched anywhere under the package
sources and output is co-located. When you set `output_folder`, also set
`input_folder` so the spec's directory prefix is stripped; otherwise the
generated files nest under the captured path (for example
`lib/generated/lib/...`).

## Contributing

Contributions are welcome. Open an issue to discuss larger changes before
starting. Add tests for new behavior and keep `dart analyze` and `dart test`
clean.

## License

Open source. A LICENSE file will be added.
