# Edge-Case Gaps

Gaps surfaced by the edge-case test specs (`example/lib/specs/edge_cases_v3*.json`).
Each entry is a candidate follow-up brainstorm -> TDD cycle. Not fixed here.

| # | Construct | Spec | Current behavior | Desired behavior | Priority |
|---|-----------|------|------------------|------------------|----------|
| 1 | Spec with no `@JsonSerializable` models | both | `models.dart` still emits `part '*.g.dart'`; json_serializable generates no `.g.dart`, so it fails to compile, plus unused imports | Omit the `part`/imports when there are no models, or skip emitting empty files | low |
