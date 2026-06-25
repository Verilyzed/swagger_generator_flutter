# Model Overrides - Design

Date: 2026-06-25

## Problem

Some schemas cannot be generated usefully. A schema whose body is only `oneOf`
generates nothing today, and every `$ref` to it resolves to `dynamic`. Users need
an escape hatch: supply a hand-written Dart type for specific schemas and have the
generator use it everywhere that schema is referenced.

## Configuration

Two build options, set in `build.yaml`:

```yaml
options:
  input_folder: lib/specs
  output_folder: lib/generated
  overrides_import: package:example/overrides.dart   # one global file
  override_schemas:                                   # component schema keys
    - OneOfThing
    - payment_method
```

- `overrides_import` (String) - the single import URI of the file holding every
  override type. One global file, not one per model.
- `override_schemas` (List<String>) - the raw component schema keys to override.
  The generator applies `className` to each to get the Dart type name
  (`payment_method` -> `PaymentMethod`, `OneOfThing` -> `OneOfThing`).

Validation: if `override_schemas` is non-empty, `overrides_import` is required;
otherwise the build fails with a clear message.

## Behavior

For each overridden schema key:

- The generator emits **no** model or enum for it.
- Every `$ref` to it (model fields, parameters, responses, array items, nested)
  resolves to its Dart class name instead of being generated or falling back to
  `dynamic`.
- A generated file imports `overrides_import` only when it actually references an
  override type, so no unused-import warnings.
- The client converter factory map registers each referenced override type as
  `Type: Type.fromJson`, so nested decoding and response decoding work.

## Contract for an override type

Because the config only lists names, the generator infers the Dart type as
`className(schemaKey)`. The user's class in the global file must be named exactly
that, and be JSON-compatible like a generated model:

```dart
class OneOfThing {
  factory OneOfThing.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```

For a `oneOf`, the discriminator and dispatch live inside `fromJson`/`toJson`. The
generator treats the type as a black box otherwise.

## Components touched

- `lib/src/builder/builder_config.dart` - read and validate the two options;
  expose `overridesImport` (String?) and `overrideSchemas` (Set<String>).
- `lib/src/builder/swagger_builder.dart` - thread overrides into `generateSources`;
  build the override type set (`className` of each key) and pass it down.
- `lib/src/resolve/dart_type_resolver.dart` - a `$ref` whose target name is an
  override resolves to `DartType(className(name))`, short-circuiting the alias and
  primitive logic.
- `lib/src/resolve/resolver_factory.dart` - pass the override set to the resolver.
- `lib/src/parser/spec_parser.dart` - skip generating a model or enum for an
  overridden schema key.
- `lib/src/emit/model_emitter.dart` - import `overrides_import` when a field
  references an override type.
- `lib/src/emit/service_emitter.dart` - import `overrides_import` when a parameter
  or response references an override type.
- `lib/src/emit/client_emitter.dart` - register referenced override types in the
  factory map and import `overrides_import` when any are registered.

## Resolution and "used" detection

- The resolver holds the override key set. In `_resolveCore`, the `$ref` branch
  checks the override set before the alias/`className` logic and returns the
  override Dart type.
- "References an override type" is decided per file by scanning the Dart type
  strings of the file's fields/params/responses for an override type name (the
  same identifier-scan approach already used for enum imports), so collection
  element types (`List<OneOfThing>`) are covered.
- `generateSources` computes the set of override types referenced anywhere
  (models + service) and passes it to the client emitter for the factory map.

## Testing

- BuilderConfig: parses both options; errors when `override_schemas` is set
  without `overrides_import`.
- Resolver: a `$ref` to an override key resolves to the override Dart type, even
  when the target schema is a bare `oneOf`.
- Parser: an overridden schema key produces no model and no enum.
- ModelEmitter / ServiceEmitter: import `overrides_import` when an override type
  is referenced, and not otherwise.
- ClientEmitter: factory map contains `Type: Type.fromJson` for a referenced
  override and imports `overrides_import`.
- End-to-end: a spec with a `oneOf` schema referenced by a model field, overridden
  via config, yields no model for it, the field typed as the override, the models
  and client importing `overrides_import`, and the factory map entry present.

## Out of scope

- Reading or validating the override file's contents (it is a black box import).
- Per-schema custom import URIs (one global file only).
- Generating any `oneOf`/`anyOf` union types automatically.
