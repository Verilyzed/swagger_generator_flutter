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
