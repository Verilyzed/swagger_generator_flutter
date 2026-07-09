# Swagger Generator Flutter

Generates type-safe Dart code from OpenAPI (Swagger) specifications
(`.json`, `.yaml`, `.yml`): models with JSON serialization, enums, and API
clients built on [`chopper`](https://pub.dev/packages/chopper). Runs as a
[`build_runner`](https://pub.dev/packages/build_runner) builder and works in
any Dart or Flutter project.

## Features

- Models with `fromJson` / `toJson` via
  [`json_serializable`](https://pub.dev/packages/json_serializable)
- Dart enums for OpenAPI enum schemas
- A Chopper service and a ready-to-use client facade per spec
- Multiple specs in one project without name collisions
- Configurable method naming, output location, null serialization,
  multipart file types, and hand-written type overrides

## Installation

Add the package and its runtime dependencies to `pubspec.yaml`:

```yaml
dependencies:
  swagger_generator_flutter: ^0.0.3
  json_annotation: ^4.12.0
  chopper: ^8.0.0
  http: ^1.0.0

dev_dependencies:
  build_runner: ^2.15.0
  json_serializable: ^6.8.0
  chopper_generator: ^8.0.0
```

## Quick start

1. Put an OpenAPI spec under `lib/`, for example `lib/specs/petstore.yaml`.

2. Configure the generator in your project's `build.yaml`:

   ```yaml
   targets:
     $default:
       builders:
         swagger_generator_flutter|swagger_generator:
           options:
             input_folder: lib/specs
             output_folder: lib/generated
   ```

3. Run the build:

   ```bash
   dart run build_runner build
   ```

4. Import the generated barrel file and use the client:

   ```dart
   import 'package:my_app/generated/petstore.api.dart';
   ```

Each spec generates a `<name>.api.dart` barrel that exports its enums, models,
service, and client.

## Build options

Spec files may be `.json`, `.yaml`, or `.yml`.

| Option | Default | Description |
| --- | --- | --- |
| `input_folder` | package sources | Folder holding the spec files. |
| `output_folder` | same as `input_folder` (co-located) | Folder the generated Dart is written to. Must be under `lib/`. |
| `method_names` | `operationId` | How service method names are derived: `operationId` (default) or `path` (from the HTTP verb and request path). |
| `overrides_import` | _(none)_ | Import URI of a single file holding override types. Required when `override_schemas` is set. |
| `override_schemas` | _(empty)_ | List of component schema keys to replace with a hand-written type named `className(key)` from `overrides_import`. |
| `include_if_null` | `true` | Whether models serialize null fields. Set to `false` to add `includeIfNull: false` to every field's `@JsonKey`, omitting null values from the JSON output. |
| `multipart_file_type` | `multipart_file` | Dart type generated for multipart file parts: `multipart_file` (`MultipartFile`), `list_int` (`List<int>`), or `string` (a file path `String`). |

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

## Example

See the [example](example/) directory for a Flutter app that generates a client
from a spec in `lib/specs` into `lib/generated`.

## Contributing

Contributions are welcome. Open an issue to discuss larger changes before
starting. Add tests for new behavior and keep `dart analyze` and `dart test`
clean.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).
