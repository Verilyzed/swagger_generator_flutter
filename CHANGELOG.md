## 0.0.2

* `format: date` now maps to a plain `String` instead of a date-only
  `DateTime`; `format: date-time` still maps to `DateTime`. A date-only value
  has no time or timezone, so a `String` preserves the wire value exactly and
  keeps date fields and query/path parameters consistent. Removes the generated
  `DateConverter`.

## 0.0.1

Initial release.

* Generate Dart/Flutter client code from OpenAPI (Swagger) 3.0 and 3.1
  specifications in JSON, YAML, or YML, run as a `build_runner` builder with
  configurable input and output folders.
* Generate immutable model classes with `json_serializable` support, `const`
  constructors, and `copyWith` methods.
* Generate enums with an unknown-value fallback member and wire-value
  serialization for query and path parameters.
* Generate a Chopper service plus a higher-level facade client that applies
  optional-parameter defaults and exposes connection options (base URL, HTTP
  client, interceptors, authenticator).
* Map OpenAPI types to Dart, including `number` to `double`, `date`/`date-time`
  formats via a date-only converter, and `additionalProperties` maps whose keys
  are typed from a `propertyNames` enum.
* Handle nullability for both dialects and treat nullable fields as optional
  constructor parameters.
* Resolve `$ref`, single-item `allOf`, and `anyOf` ref-or-null schemas, and
  hoist inline objects and enums into named types.
* Support multipart file uploads, model type overrides, and configurable method
  naming from the operation path or id.
