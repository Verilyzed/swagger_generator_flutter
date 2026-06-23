# Real-World / OpenAPI 3.0 Support - Design

Date: 2026-06-23

## Problem

Generating from a real-world OpenAPI 3.0 spec (1Password Connect) produces code
that does not compile and is partly wrong:

1. `allOf` schemas (`FullItem`, `Patch`) are skipped entirely, so response types
   reference undefined classes (and chopper emits `InvalidType` downstream).
2. Inline enums (enum defined directly on a property, e.g. `Item.category`,
   `Vault.type`, `Field.type`) are not generated; the fields become `String`. No
   enums are produced at all.
3. OpenAPI 3.0 `nullable: true` is ignored, so optional fields become
   non-nullable (and via the non-nullable-not-required-becomes-required rule,
   required), which breaks deserialization when a response omits them.
4. A schema named `Field` collides with Chopper's exported `Field` annotation,
   making the client's converter map ambiguous and non-const.
5. Acronym-heavy names render poorly (`APIRequest` -> `Apirequest`).

## Goal

Generate compiling, correct Dart from OpenAPI 3.0 and 3.1 specs, covering the
five gaps above, and prove a model round-trip against a mock server for a few
paths.

## Versioning architecture (resolver strategy)

Version differences are confined to schema-type interpretation - chiefly how
nullability is expressed (3.0 `nullable: true` vs 3.1 `anyOf`-null and
`type: ["string","null"]`). Everything else (`allOf`, inline enums, model/enum
classification, operations, naming) is version-agnostic.

`SpecParser` already takes a `DartTypeResolver` by injection, so the parser stays
single and shared; only the resolver is specialized:

- `DartTypeResolver` (base): common mapping for `$ref`, primitives, arrays,
  object/`additionalProperties` maps. Splits a schema into a non-null "core"
  schema plus a nullability flag via two overridable hooks, then resolves the
  core and applies nullability.
- `OpenApi30TypeResolver`: nullability from `nullable: true`; core schema is the
  schema itself.
- `OpenApi31TypeResolver`: nullability from `anyOf` containing `{type: null}` or
  a `type` array containing `"null"`; core schema is the non-null member.
- A factory picks the resolver from the spec's `openapi` version (default to the
  3.1 resolver when unknown).

Array item types resolve back through the version-aware entry point, so nested
nullability is handled per version. The IR records the detected version on
`ApiSpec` for future use, but the parser does not branch on it.

## Gap 1: allOf flatten (SpecParser)

Classify a schema with `allOf` as a model. Merge every member: a `$ref` member
is resolved to its target schema's `properties` and `required`; an inline member
contributes its own `properties` and `required`. The merged property set and
required list build one `ModelDef` exactly as a plain object would. One level of
`allOf` is supported (members are object schemas or `$ref` to object schemas);
nested `allOf` inside a member is out of scope.

## Gap 2: inline enums (SpecParser)

When a model field's schema carries an `enum` list and no `$ref`, synthesize an
`EnumDef` named `NameGiver.className('<ModelName> <fieldName>')` (e.g.
`ItemCategory`, `VaultType`, `FieldType`), add it to the spec's enums, and type
the field as that enum. Identical synthesized names are de-duplicated (the same
model+field always yields the same name). A field whose inline-enum schema has a
`default` formats it as `<EnumName>.<member>`. Empty-string enum values map to a
member via the existing `NameGiver` rules with `@JsonValue('')`.

Param-level inline enums stay `String` (out of scope); the target spec's inline
enums are all on model fields.

## Gap 3: nullable

Handled by the resolver strategy above: `OpenApi30TypeResolver` reads
`nullable: true`; `OpenApi31TypeResolver` keeps the existing `anyOf`-null
behavior and adds the `type` array form.

## Gap 4: name collisions (NameGiver)

A curated set of Chopper-reserved type names that can appear as types or
annotations in generated code: `Field`, `Part`, `PartFile`, `Header`, `Body`,
`Query`, `QueryMap`, `Path`, `Response`, `Request`, `Tag`, `Method`, `Converter`,
`Interceptor`. When `NameGiver.className` computes one of these, it appends
`Model` (e.g. `Field` -> `FieldModel`). Because the model definition and every
`$ref` to it both pass through `className`, the rename propagates consistently to
field types, response types, and the converter factory map.

## Gap 5: acronym casing (NameGiver)

`NameGiver` splits runs of capitals before a capitalized word
(`([A-Z]+)([A-Z][a-z])`) in addition to the existing lower-to-upper split, so
`APIRequest` -> `ApiRequest` and `HTTPValidationError` -> `HttpValidationError`,
while `FullItem` is unaffected.

## Components touched

- `lib/src/resolve/dart_type_resolver.dart` - split into base + two subclasses.
- `lib/src/resolve/resolver_factory.dart` (new) - select resolver by version.
- `lib/src/resolve/name_giver.dart` - collision rename, acronym split.
- `lib/src/parser/spec_parser.dart` - allOf flatten, inline-enum synthesis.
- `lib/src/ir/api_spec.dart` - `ApiSpec.openApiVersion`.
- `lib/src/builder/swagger_builder.dart` - detect version, build the resolver
  via the factory, pass it to the parser.
- The emitters are unchanged; they consume whatever IR the parser produces.

## Round-trip verification

For a few 1Password paths, a small mock server (Python) accepts a JSON body,
modifies a field, and returns schema-valid JSON; a Dart consumer sends a model,
receives it back, and asserts the loop. Chosen paths:

- `GET /vaults` -> `List<Vault>` (read path; assert typed list deserializes).
- `POST /vaults/{vaultUuid}/items` -> takes a `FullItem` body, the mock bumps
  `version` and echoes it, the consumer asserts the returned `FullItem` is typed
  and carries the bumped version (model in -> json -> modified -> model out).

Verification is a plan step (live server), reverted afterward. Generator
behavior is covered by unit tests on the resolver subclasses, the factory,
`NameGiver`, and `SpecParser` (allOf, inline enums).

## Testing

- `OpenApi30TypeResolver`: `nullable: true` -> nullable; absent -> non-nullable.
- `OpenApi31TypeResolver`: `anyOf`-null and `type: [..,"null"]` -> nullable.
- `resolverForVersion`: returns the 3.0 resolver for `3.0.x`, the 3.1 resolver
  for `3.1.x` and unknown.
- `NameGiver`: `APIRequest` -> `ApiRequest`; `Field` -> `FieldModel`;
  non-colliding names unchanged.
- `SpecParser`: `allOf` merges referenced and inline properties; an inline-enum
  field yields a synthesized `EnumDef` and an enum-typed field; an inline-enum
  default becomes `<EnumName>.<member>`.
- End-to-end: regenerate from `example/lib/newapi.openapi.json` and confirm
  `flutter analyze` is clean (no undefined classes, enums present, correct
  nullability), then the mock round-trip.

## Out of scope

- Param-level inline enums (stay `String`).
- Nested `allOf` within an `allOf` member.
- `oneOf`/`discriminator` polymorphism.
- Full JSON Schema 3.1 keywords beyond nullability (`const`, `$defs`, etc.).
