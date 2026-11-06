# 🚀 Swagger Generator Flutter

**Point it at your OpenAPI spec, run `build_runner`, get a typed Dart client that works.**

Swagger Generator Flutter turns OpenAPI 3.0 and 3.1 specifications (`.json`,
`.yaml`, `.yml`) into models, enums, and a ready-to-use API client built on
[`chopper`](https://pub.dev/packages/chopper) and
[`json_serializable`](https://pub.dev/packages/json_serializable). It runs as a
[`build_runner`](https://pub.dev/packages/build_runner) builder in any Dart or
Flutter project.

🏆 **Early version, already more reliable.** Don't let the 0.0.x version fool
you: this generator already gets right what other Flutter generators commonly
trip over, such as required-but-nullable fields, `allOf`, success responses
other than `200`, integer enums, and responses that are not a model. Less
hand-patching, fewer surprises at runtime.

🎯 **The goal: complete, faithful support for OpenAPI 3.0 and 3.1.** We are not
there yet, but every release closes another gap. See the Roadmap section below
and join us on the way.

## 💡 Why this generator?

Most spec generators get the happy path right and break on the details. This
one is built around the details:

- 🎯 **Nullable and required mean what the spec says.** Required fields keep
  their key in the JSON output, even when you strip null values everywhere
  else.
- 🧩 **`allOf` done properly.** Flatten members into one model or keep them as
  nested typed fields, while the wire JSON stays flat either way.
- 📦 **Responses decode to their declared type.** Maps, lists of primitives,
  enums, `DateTime`, and `double` bodies come back typed, not as raw JSON.
  `201` and every other 2xx response count, not only `200`.
- 🛡️ **Enums that survive API changes.** An `$unknown` fallback member means a
  new server value never crashes decoding. Integer and boolean enums keep their
  real wire values.
- 🔒 **A stable JSON contract.** Every field carries an explicit
  `@JsonKey(name: ...)`, so renaming a Dart field can never silently change what
  goes over the wire.
- 🏗️ **Multiple specs, zero collisions.** Every spec gets its own uniquely named
  client.

## ✨ Features

### Generated code

- 🧱 Immutable models with `const` constructors, `copyWith`, and `fromJson` /
  `toJson`
- 🔢 Enums with an `$unknown` fallback and typed `@JsonValue`s
- 🌐 A Chopper service plus a client facade per spec that applies parameter
  defaults and exposes base URL, HTTP client, interceptors, and authenticator
- 📭 JSON `null`, empty bodies, `204`, `205`, and `HEAD` responses yield a null
  body instead of a failed cast
- 📎 Multipart file uploads with a configurable file type

### OpenAPI 3.0 and 3.1

- 📄 Specs as JSON or YAML
- ❓ Nullability in both dialects: `nullable: true`, `null` in `type`, and
  `anyOf` with a null member
- 🔗 `$ref`, `allOf`, `anyOf` ref-or-null, and `additionalProperties` maps with
  keys typed from a `propertyNames` enum
- 🏷️ Inline objects and enums hoisted into named types
- 🧭 Path-level parameters, header parameters, and parameter `$ref`s to
  `components/parameters`
- 🔤 Names that are not valid Dart identifiers (leading digits, `$`, quotes) are
  escaped into valid Dart

## 📦 Installation

Add the package and its runtime dependencies to `pubspec.yaml`:

```yaml
dependencies:
  swagger_generator_flutter: ^0.0.6
  json_annotation: ^4.12.0
  chopper: ^8.0.0
  http: ^1.0.0

dev_dependencies:
  build_runner: ^2.15.0
  json_serializable: ^6.8.0
  chopper_generator: ^8.0.0
```

## ⚡ Quick start

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

## 🔌 Using the generated client

Each spec generates a uniquely named `<Name>Api` facade. Construct it directly
with the connection parameters:

```dart
final api = NewapiApi(
  baseUrl: Uri.parse('https://api.example.com'),
  authenticator: myAuthenticator,
  interceptors: [HttpLoggingInterceptor()],
);
```

To reuse an existing `ChopperClient`, use `NewapiApi.fromClient(chopperClient)`.
The generated client depends on `package:http` (for the `httpClient`
parameter), so add `http` to your `dependencies`.

## ⚙️ Configuration

All options go under `options:` in `build.yaml`.

| Option | Default | Description |
| --- | --- | --- |
| `input_folder` | package sources | Folder holding the spec files. |
| `output_folder` | same as `input_folder` (co-located) | Folder the generated Dart is written to. Must be under `lib/`. |
| `method_names` | `operationId` | How service method names are derived: `operationId` (default) or `path` (from the HTTP verb and request path). |
| `overrides_import` | _(none)_ | Import URI of a single file holding override types. Required when `override_schemas` is set. |
| `override_schemas` | _(empty)_ | List of component schema keys to replace with a hand-written type named `className(key)` from `overrides_import`. |
| `include_if_null` | `true` | Whether models serialize null fields. Set to `false` to add `includeIfNull: false` to each field's `@JsonKey`, omitting null values from the JSON output. Required fields are exempt unless `include_if_null_if_required` is `false`. |
| `include_if_null_if_required` | `true` | Whether fields listed as `required` in the spec still serialize null when `include_if_null` is `false`. Set to `false` to omit null values from required fields as well. Has no effect when `include_if_null` is `true`. |
| `multipart_file_type` | `multipart_file` | Dart type generated for multipart file parts: `multipart_file` (`MultipartFile`), `list_int` (`List<int>`), or `string` (a file path `String`). |
| `allof_mode` | `flatten` | How `allOf` (and `$ref`-with-siblings) models are shaped: `flatten` or `nested`. |
| `allof_exceptions` | _(empty)_ | List of schema names or operationIds (case-insensitive, `*`/`?` glob wildcards) whose `allOf` models use the opposite of `allof_mode`. |

### 📂 Input and output folders

When you set `output_folder`, also set `input_folder` so the spec's directory
prefix is stripped; otherwise the generated files nest under the captured path
(for example `lib/generated/lib/...`).

### 🏷️ Method names

With `method_names: path`, `GET /vaults/{vaultUuid}/items` generates
`getVaultsVaultUuidItems`. The path form includes parameter segments so names
stay unique.

### 🚫 Null values

By default every field is serialized, including `null` values. With
`include_if_null: false`, null values are left out of the JSON, except for
fields the spec lists as `required`: OpenAPI requires their key to be present,
so they are still sent as `null`. Set `include_if_null_if_required: false` to
leave those out as well.

Required and nullable are independent: a nullable property listed in the spec's
`required` array still needs an explicit constructor argument, such as
`errorId: null`, unless it has a default value. Null-serialization options do not
change constructor requirements.

```yaml
options:
  include_if_null: false
  include_if_null_if_required: true
```

### 🧩 allOf

An `allOf` (or a `$ref` with sibling keywords, which OpenAPI 3.1 treats the same
way) merges a referenced schema with an inline object. By default the members
are flattened into a single model, so a response combining `Kunde` with two
extra fields exposes `response.vorname` alongside `response.cssLoginStatus`. Set
`allof_mode: nested` to instead keep the referenced schema as a typed field
(`response.kunde.vorname`); the wire JSON stays flat in both modes. Use
`allof_exceptions` to flip individual cases, matched by component schema name or
by the operationId of the endpoint whose inline body/response produced the
model:

```yaml
options:
  allof_mode: flatten
  allof_exceptions:
    - GetKundeResponse   # a generated or named schema
    - getKundeDetails    # every allOf model from this endpoint
    - "getKunde*"        # glob over schema names / operationIds
```

### 🛠️ Type overrides

Use overrides for schemas that cannot be generated usefully, such as a `oneOf`.
List the schema keys in `override_schemas` and provide their types in the single
`overrides_import` file. Each override type must be named `className(key)` (for
example schema `payment_method` -> class `PaymentMethod`) and expose
`factory Type.fromJson(Map<String, dynamic> json)` and
`Map<String, dynamic> toJson()`, so it nests and decodes like a generated model.
The generator emits nothing for an overridden schema and uses the type wherever
the schema is referenced.

```yaml
options:
  overrides_import: package:my_app/api_overrides.dart
  override_schemas:
    - payment_method
```

## 🗺️ Roadmap

The package is young (0.0.x) and the target is clear: every part of OpenAPI 3.0
and 3.1 that affects generated code should be supported faithfully. Still open:

- [ ] `oneOf` and `discriminator` as typed unions (until then, use type
  overrides, see Configuration)
- [ ] `readOnly` / `writeOnly` properties
- [ ] `deprecated` operations, parameters, and properties
- [ ] Cookie parameters (currently skipped)
- [ ] `securitySchemes`
- [ ] `webhooks`

Something in your spec not handled the way it should be? Please
[open an issue](https://github.com/Verilyzed/swagger_generator_flutter/issues)
with a minimal spec snippet. Every report helps close the next gap, and pull
requests are very welcome.

## 📱 Example

See the [example](example/) directory for a Flutter app that generates a client
from a spec in `lib/specs` into `lib/generated`.

## 🤝 Contributing

Contributions are welcome. Open an issue to discuss larger changes before
starting. Add tests for new behavior and keep `dart analyze` and `dart test`
clean.

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).
