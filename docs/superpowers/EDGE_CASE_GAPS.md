# Edge-Case Gaps

Gaps surfaced by the edge-case test specs (`example/lib/specs/edge_cases_v3*.json`).
Each entry is a candidate follow-up brainstorm -> TDD cycle. Not fixed here.

| # | Construct | Spec | Current behavior | Desired behavior | Priority |
|---|-----------|------|------------------|------------------|----------|
| 1 | Spec with no `@JsonSerializable` models | both | `models.dart` still emits `part '*.g.dart'`; json_serializable generates no `.g.dart`, so it fails to compile, plus unused imports | Omit the `part`/imports when there are no models, or skip emitting empty files | low |
| 2 | `type` array, multiple non-null (`["string","integer"]`) | 3.1 | resolves to `dynamic` (and `required` since non-nullable) | a union type / `Object?` / override hook | medium |
| 3 | `type` array, multiple non-null + null (`["string","integer","null"]`) | 3.1 | resolves to `dynamic?` - flagged by analyzer (`unnecessary_question_mark`) | nullable union; never emit `dynamic?` | high |
