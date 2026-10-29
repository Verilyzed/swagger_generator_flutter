## 0.0.5

### Fixed

* Header parameters are generated as `@Header` instead of `@Query`.
* Cookie parameters are no longer generated. Previously they were sent as query
  parameters.
* Parameter `$ref`s to `components/parameters` are resolved instead of crashing
  generation. An unresolvable ref is skipped.
* Path-level `parameters` are applied to every operation of the path. An
  operation parameter with the same `name` and `in` takes precedence.
* Integer and boolean enums are emitted with typed `@JsonValue`s (`@JsonValue(1)`
  instead of `@JsonValue('1')`), so their values decode instead of falling back
  to `$unknown`. An integer default on an enum-typed field maps to the enum
  member.
* A named schema with only `additionalProperties` is generated as a `Map`
  typedef instead of an empty class that dropped its contents.

## 0.0.4

### Fixed

* Generated response converters now return a null body for JSON `null` and empty
  JSON responses instead of retaining the raw string and potentially failing a cast.
  JSON string literals, response metadata, and error handling are unchanged.
* Response converters preserve bodies with explicit non-JSON content types,
  including empty strings and whitespace. JSON media types with parameters or a
  `+json` suffix are supported. HTTP 204, 205, and HEAD responses, and empty
  responses without a content type, are handled separately as having no content.

## 0.0.3+1

### Changed

* Rewrote the README for pub.dev: installation instructions, quick start, and
  removal of the outdated "no code generation implemented yet" status.
* The example app now uses a generated client: `main.dart` constructs the
  `ResourceSchedulerApi` facade and renders its `listAssets` response.

## 0.0.3

### Added

* Continuous integration workflow that runs `dart analyze` and `dart test`
  on pull requests.
* Publishing workflow that releases to pub.dev when a `v*` version tag is
  pushed.
* `include_if_null` build option (default `true`). Set it to `false` to add
  `includeIfNull: false` to every generated model field's `@JsonKey`, so null
  values are omitted from the serialized JSON instead of sent as `null`.
* `multipart_file_type` build option (default `multipart_file`). Controls the
  Dart type generated for multipart file parts: `multipart_file` for
  `MultipartFile`, `list_int` for `List<int>`, or `string` for a file path
  `String`. The `package:http` import is only emitted when `MultipartFile` is
  used.

### Changed

* Every generated model field now carries an explicit `@JsonKey(name: ...)`
  with its wire name, so renaming a Dart field cannot silently change the JSON
  contract. Previously the annotation was omitted when a field name already
  matched its JSON key.

### Fixed

* Response types are now resolved from any 2xx success response (for example
  `201`), not only `200`. An operation whose only success response was `201`
  previously resolved to `dynamic` regardless of its schema.

## 0.0.2

### Changed

* `format: date` now maps to a plain `String` instead of a date-only
  `DateTime`; `format: date-time` still maps to `DateTime`. A date-only value
  has no time or timezone, so a `String` preserves the wire value exactly and
  keeps date fields and query/path parameters consistent. Removes the generated
  `DateConverter`.
* A named schema that is a plain array (`type: array` with `items`) is now
  emitted as a Dart `typedef` (for example `typedef Patch = List<String>;`) and
  referenced by name, instead of inlining `List<...>` at each use site. Inline
  arrays are unchanged.

### Fixed

* Member names that begin with a digit (fields, parameters, and enum values)
  are prefixed with `$` to form a valid Dart identifier. Previously a name like
  `1leading` was emitted unchanged, producing code that would not compile.
* Enum values containing `$`, quotes, or backslashes are escaped in the
  generated string literals. Previously a value such as `$dollar` was treated as
  string interpolation and broke the generated enum file.
* A model with no fields now emits `const Name();` and `copyWith() => Name();`.
  Previously the empty parameter braces (`{}`) were invalid Dart.
* A nullable `dynamic` is rendered as `dynamic` rather than `dynamic?`, which the
  analyzer flags. This affected multi-type schemas that include `null` (for
  example `["string", "integer", "null"]`).

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
