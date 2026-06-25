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

## Build options

Spec files may be `.json`, `.yaml`, or `.yml`. Configure the generator in the
consuming project's `build.yaml`:

```yaml
targets:
  $default:
    builders:
      swagger_generator_flutter|swagger_generator:
        options:
          input_folder: lib/specs
          output_folder: lib/generated
```

| Option | Default | Description |
| --- | --- | --- |
| `input_folder` | package sources | Folder holding the spec files. |
| `output_folder` | same as `input_folder` (co-located) | Folder the generated Dart is written to. Must be under `lib/`. |
| `method_names` | `operationId` | How service method names are derived: `operationId` (default) or `path` (from the HTTP verb and request path). |
| `overrides_import` | _(none)_ | Import URI of a single file holding override types. Required when `override_schemas` is set. |
| `override_schemas` | _(empty)_ | List of component schema keys to replace with a hand-written type named `className(key)` from `overrides_import`. |

Each spec generates a `<name>.api.dart` barrel that exports its enums, models,
service, and client.

Use overrides for schemas that cannot be generated usefully, such as a `oneOf`.
List the schema keys in `override_schemas` and provide their types in the single
`overrides_import` file. Each override type must be named `className(key)` (for
example schema `payment_method` -> class `PaymentMethod`) and expose
`factory Type.fromJson(Map<String, dynamic> json)` and
`Map<String, dynamic> toJson()`, so it nests and decodes like a generated model.
The generator emits nothing for an overridden schema and uses the type wherever
the schema is referenced.

With `method_names: path`, `GET /vaults/{vaultUuid}/items` generates
`getVaultsVaultUuidItems`. The path form includes parameter segments so names
stay unique.

When you set `output_folder`, also set `input_folder` so the spec's directory
prefix is stripped; otherwise the generated files nest under the captured path
(for example `lib/generated/lib/...`).

## Using the generated client

Each spec generates a uniquely named `<Name>Api` facade. Construct it directly
with the connection parameters:

```dart
final api = NewapiApi(
  baseUrl: Uri.parse('https://api.example.com'),
  authenticator: myAuthenticator,
  interceptors: [HttpLoggingInterceptor()],
);
```

The facade names are unique per spec, so multiple specs do not collide. To reuse
an existing `ChopperClient`, use `NewapiApi.fromClient(chopperClient)`. The
generated client depends on `package:http` (for the `httpClient` parameter), so
add `http` to your `dependencies`.

## Contributing

Contributions are welcome. Open an issue to discuss larger changes before
starting. Add tests for new behavior and keep `dart analyze` and `dart test`
clean.

## License

Open source. A LICENSE file will be added.
