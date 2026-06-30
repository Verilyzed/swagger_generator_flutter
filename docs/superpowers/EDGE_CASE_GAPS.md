# Edge-Case Gaps

Gaps surfaced by the edge-case test specs (`example/lib/specs/edge_cases_v3*.json`).
Each entry is a candidate follow-up brainstorm -> TDD cycle. Not fixed here.

| # | Construct | Spec | Current behavior | Desired behavior | Priority |
|---|-----------|------|------------------|------------------|----------|
| 1 | Spec with no `@JsonSerializable` models | both | `models.dart` still emits `part '*.g.dart'`; json_serializable generates no `.g.dart`, so it fails to compile, plus unused imports | Omit the `part`/imports when there are no models, or skip emitting empty files | low |
| 2 | `type` array, multiple non-null (`["string","integer"]`, with or without `null`) | 3.1 | resolves to `dynamic` (the non-null form is `required`, the `+null` form optional) | a union type / `Object?` / override hook | medium |
| 3 | `prefixItems` (tuple) | 3.1 | ignored; no `items` so resolves to `List<dynamic>` | a typed record/tuple, or `List<Object?>` | low |
| 4 | `const` | 3.1 | ignored; `{const}` with no type -> `dynamic`, typed `const` keeps the type | constant single-value field (like a one-value enum) | low |
| 5 | empty schema `{}` | 3.1 | -> `dynamic` | `dynamic`/`Object?` (acceptable; documented) | low |
| 6 | `examples` (plural) | 3.1 | ignored | none needed (metadata) | low |
| 7 | top-level `webhooks` | 3.1 | ignored; no operations generated | generate webhook operations or skip by design | medium |
| 8 | `oneOf` (multi-member) | both | no class generated; a `$ref` to it degrades to `dynamic` | sealed/union type, or an override hook | high |
| 9 | `discriminator` + `mapping` | both | ignored | tagged union with `fromJson` dispatch on the discriminator | high |
| 10 | `allOf` inheritance (base `$ref` + own props) | both | flattened into one class with merged properties; no shared base type | a base class or mixin, or keep flattening by design | medium |
| 11 | optional property that resolves to `dynamic` | both | emitted as a `required` constructor param (nullable-coercion skips `dynamic`) | optional (omittable), since `dynamic` is nullable | low |
| 12 | `additionalProperties` + `properties` together | both | treated as a class; the `additionalProperties` map is dropped | a class plus an overflow map, or a `Map` | medium |
| 13 | `additionalProperties`-only object (no `properties`) | both | becomes an empty class | a `Map<String, V>` type alias | medium |
| 14 | integer/boolean enum | both | values emitted as string `@JsonValue('1')`, not `@JsonValue(1)` | typed `@JsonValue` matching the enum's wire type | medium |
| 15 | `format: byte` / `binary` | both | -> `String` (no base64 decode) | `Uint8List` with a converter, or document as raw String | low |
| 16 | `format: int64` | both | -> `int` (unsafe on dart2js/web) | `BigInt` or `String` option for 64-bit ints | low |
