# Edge-Case Gaps

Gaps surfaced by the edge-case test specs (`example/lib/specs/edge_cases_v3*.json`),
exercised by `test/e2e/edge_cases_test.dart` and by regenerating the example.
Each entry is a candidate follow-up brainstorm -> TDD cycle.

14 gaps open: 2 high, 3 medium, 9 low. The high-priority ones are #8 `oneOf` and
#9 `discriminator`. The medium ones lose or corrupt data at runtime (#12, #21) or
send a parameter in a different form than the spec asks for (#18). The rest
degrade to an imprecise type or an awkward signature. #1 does not compile.

## Bugs fixed during characterization

These were trivial output bugs (uncompilable code), fixed inline rather than
deferred:

- Nullable `dynamic` rendered as the analyzer-flagged `dynamic?`.
- An empty class emitted `const X({})` / `copyWith({})` (invalid empty braces).
- Enum/string values containing `$`, a quote, or a backslash were emitted into
  Dart string literals unescaped.
- Member names starting with a digit (e.g. `1leading`) were left as invalid
  identifiers.

## Gaps resolved

- #10 `allOf` inheritance: flattened by default; the `nested` mode keeps the
  `$ref` member as a field, with per-schema exceptions.
- #13 `additionalProperties`-only object: a named one becomes a `Map` typedef
  (`additionalProperties: false` stays an empty class).
- #14 integer/boolean enum: values are emitted as typed `@JsonValue(1)`; an
  enum-typed default of that type maps to the enum member.
- #17 header / cookie parameters: header params are emitted as `@Header`; cookie
  params are skipped.
- #19 parameter `$ref`: refs to `components/parameters` are resolved; an
  unresolvable ref is skipped instead of crashing.
- #20 responses without a `200`: the lowest `2xx` with a schema is used, then
  `2XX`, then `default`. A `204` stays `Response<dynamic>` with a `null` body.
- #22 non-model response bodies: the converter decoded only models and lists of
  models. A `Map` response came back `null`, a list of primitives as `[]`, and an
  enum, `DateTime`, or `double` response failed with a type error. Typed decoders
  are now generated per response type.
- Path-level `parameters` are applied to every operation of the path.

## Accepted behavior

| # | Construct | Spec | Behavior |
|---|-----------|------|----------|
| 5 | empty schema `{}` | 3.1 | -> `dynamic` |
| 6 | `examples` (plural) | 3.1 | ignored (metadata) |
| 7 | top-level `webhooks` | 3.1 | ignored; a client does not call webhooks |

## Gaps (deferred)

| # | Construct | Spec | Current behavior | Desired behavior | Priority |
|---|-----------|------|------------------|------------------|----------|
| 8 | `oneOf` (multi-member) | both | no class generated; a `$ref` to it degrades to `dynamic` | sealed/union type, or an override hook | high |
| 9 | `discriminator` + `mapping` | both | ignored | tagged union with `fromJson` dispatch on the discriminator | high |
| 12 | `additionalProperties` + `properties` together | both | treated as a class; the `additionalProperties` entries are dropped | a class plus an overflow map, or a `Map` | medium |
| 18 | parameter `style` / `explode` | both | ignored. Arrays use Chopper's default `ListFormat.repeat` (`a=1&a=2`), which matches the OpenAPI default `form` + `explode: true`; `explode: false` and `deepObject` are not honored | honor serialization style for array/object params | medium |
| 21 | non-JSON content (`text/plain`, `application/octet-stream`) | both | a binary response body is read as a `String`, so bytes are corrupted; a `text/plain` request body is JSON-encoded and sent as `application/json` | distinguish content types; raw String/bytes body | medium |
| 1 | Spec with no `@JsonSerializable` models | both | `models.dart` still emits `part '*.g.dart'`; json_serializable generates no `.g.dart`, so it fails to compile, plus unused imports | Omit the `part`/imports when there are no models, or skip emitting empty files | low |
| 2 | `type` array, multiple non-null (`["string","integer"]`, with or without `null`) | 3.1 | resolves to `dynamic` (the non-null form is `required`, the `+null` form optional) | a union type / `Object?` / override hook | low |
| 3 | `prefixItems` (tuple) | 3.1 | ignored; no `items` so resolves to `List<dynamic>` | a typed record/tuple, or `List<Object?>` | low |
| 4 | `const` | 3.1 | ignored; `{const}` with no type -> `dynamic`, typed `const` keeps the type | constant single-value field (like a one-value enum) | low |
| 11 | optional property that resolves to `dynamic` | both | emitted as a `required` constructor param (nullable-coercion skips `dynamic`) | optional (omittable), since `dynamic` is nullable | low |
| 15 | `format: byte` / `binary` | both | -> `String` (no base64 decode) | `Uint8List` with a converter, or document as raw String | low |
| 16 | `format: int64` | both | -> `int` (unsafe on dart2js/web) | `BigInt` or `String` option for 64-bit ints | low |
| 23 | parameters with the same name in different locations (e.g. `id` in path and header) | both | both map to the same Dart name, so the method does not compile | uniquify parameter names | low |
| 24 | nullable non-model response type (e.g. `nullable: true` on a map response) | both | no typed decoder is generated, so it falls back to the model-only decoding of #22 | key decoders by the non-null type and apply them to nullable results | low |
