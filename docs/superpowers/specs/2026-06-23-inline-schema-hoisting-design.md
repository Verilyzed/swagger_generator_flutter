# Inline Schema Hoisting and Non-JSON Responses - Design

Date: 2026-06-23

## Problem

The 1Password spec exposes two gaps:

1. Inline (anonymous) object schemas - an object with `properties` and no
   `$ref`, e.g. the `/health` response - fall back to `Map<String, dynamic>`
   instead of a typed model.
2. Non-JSON responses are ignored. `/heartbeat` returns `text/plain` with schema
   `{type: string}`, but the parser only reads `application/json`, so the
   response type is `dynamic` instead of `String`.

## Goal

Generate typed models for inline object schemas wherever they appear (responses,
request bodies, nested properties, array items), and resolve responses/bodies
from whatever content type the spec declares. Do this without adding inline-aware
branches to the emitters or the type resolver - the existing model/enum pipeline
should handle the result unchanged.

## Approach: a schema-hoisting pre-pass

A new `SchemaHoister` normalizes the loaded spec before parsing: it walks the
spec once and hoists every inline schema into `components/schemas` under a
generated name, replacing the inline schema in place with a `$ref`. The existing
pipeline then runs unchanged - the parser already turns named schemas into
models and enums and resolves `$ref`s.

This keeps the change DRY: one focused unit handles every location uniformly,
and it absorbs the current inline-enum synthesis (which is removed from
`SpecParser`), so there is a single mechanism for "name an inline schema".

### What is hoisted

A schema in a type position that is either:
- an object with a `properties` map and no `$ref`, or
- an enum (`enum` list) and no `$ref`.

Type positions: a model property value, an array `items` value, a response
content schema, a request-body content schema. Composition members under
`allOf` are not hoisted themselves (the parser already flattens them), but the
hoister still recurses into their `properties`.

Schemas that are not hoisted (unchanged behavior): a bare `object` with no
`properties`, `additionalProperties` maps, primitives, arrays of `$ref`,
existing `$ref`s, and top-level named component schemas (they are already
named).

### Naming (via NameGiver.className, deduplicated)

- Response object: `<OperationId>Response` (`GetServerHealthResponse`).
- Request-body object: `<OperationId>Request`.
- Object nested in a model property `X.y`: `<X><y>` (`FieldRecipe`).
- Inline enum in property `X.y`: `<X><y>` (`ItemCategory`) - matches today's
  inline-enum names, so existing output is unchanged.
- Array of inline objects in context `C`: `<C>Item`.

Generated names are normalized with `NameGiver.className` and made unique: if a
name is already used by a component schema (or a previously hoisted one), a
numeric suffix is appended. A `default` sibling on a hoisted property is kept
next to the new `$ref`, so enum/field defaults still resolve.

## Components

- `lib/src/parser/schema_hoister.dart` (new): `SchemaHoister(NameGiver names)`
  with `Map<String, dynamic> hoist(Map<String, dynamic> spec)` returning a
  normalized deep copy. Single responsibility: lift inline schemas to named
  ones. Does not interpret types.
- `lib/src/parser/spec_parser.dart`: remove the inline-enum synthesis branch
  from `_model` (now handled upstream by hoisting); generalize response and
  request-body schema extraction to any content type (see below).
- `lib/src/builder/swagger_builder.dart` (`generateSources`): run
  `SchemaHoister.hoist` on the loaded map first, then derive `schemas` and parse
  from the normalized map.

## Non-JSON content (text/plain)

`SpecParser` currently reads `content['application/json']['schema']`. Generalize
it: prefer `application/json`, otherwise use the first declared content type's
schema. So `/heartbeat`'s `text/plain` `{type: string}` resolves to `String`.

Runtime caveat to verify: a `Response<String>` from a `text/plain` body must not
go through `jsonDecode`. Chopper's `JsonConverter` decodes only JSON content
types and returns other bodies as-is, so the generated converter's
`_decode<String>` receives the raw string and returns it. Confirmed by the
round-trip step.

## Data flow

```
loaded spec map
  -> SchemaHoister.hoist (inline schemas -> named schemas + $ref)
  -> resolver (sees only $ref/array/primitive)
  -> SpecParser (named schemas -> models/enums; $ref resolved)
  -> emitters (unchanged)
```

## Testing

- `SchemaHoister`:
  - hoists an inline response object to `<OperationId>Response` and replaces it
    with a `$ref`.
  - hoists an inline request-body object to `<OperationId>Request`.
  - hoists a nested property object to `<Model><Field>` and recurses into it.
  - hoists an inline enum to `<Model><Field>` keeping a `default` sibling.
  - hoists an array's inline `items` object to `<Context>Item`.
  - de-duplicates a generated name that collides with an existing schema.
  - leaves `$ref`s, `additionalProperties`, and property-less objects untouched.
- `SpecParser`: response/body resolved from `text/plain` when no
  `application/json`; the removed inline-enum branch still yields the same enum
  via hoisting (regression on an existing inline-enum case).
- End-to-end: regenerate `newapi`; confirm `flutter analyze` clean,
  `GetServerHealthResponse` is a typed model (with `name`, `version`,
  `dependencies: List<ServiceDependency>?`), and `getHeartbeat` returns
  `Response<String>`. Round-trip `/health` and `/heartbeat` against the mock.

## Out of scope

- Hoisting parameter schemas (params are primitives/`$ref` in practice).
- `oneOf`/`discriminator` polymorphism.

## Disposal

The hoister works on a deep copy; the input spec map is not mutated.
