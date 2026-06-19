# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

Swagger Generator Flutter — an open-source tool that generates Dart / Flutter
code from OpenAPI (Swagger) specifications (`.json`, `.yaml`, `.yml`).

## Style and conventions

- Keep it simple. Prefer the smallest, clearest solution over a clever one.
- No emojis. Not in code, comments, documentation, commit messages, or READMEs.
- Write plain, direct descriptions. Avoid marketing language and filler.
- Match the existing style of surrounding code (naming, formatting, structure).
- Don't add badges, decorative separators, or hype to documentation.
- Comments only when necessary. Write self-explanatory code; add a comment only to
  explain *why* something is done when it isn't obvious. Don't narrate what the code
  already says, and don't leave redundant or commented-out code.

## Documentation

- Be concise and factual. Document only what exists.
- Don't invent commands, flags, or config keys. Use placeholders if a detail is unknown.
- Avoid filler sections that contain no real information.

## SOLID principles

Design code to follow SOLID:

- **Single Responsibility** — each class or function has one reason to change. Keep
  parsing, generation, and output writing in separate units.
- **Open/Closed** — open for extension, closed for modification. Add new behavior
  (e.g. a new output format) without rewriting existing code.
- **Liskov Substitution** — subtypes must be usable anywhere their base type is
  expected, without breaking behavior.
- **Interface Segregation** — prefer small, focused interfaces over large ones.
  Don't force implementers to depend on methods they don't use.
- **Dependency Inversion** — depend on abstractions, not concretions. Inject
  dependencies (file readers, generators) rather than hard-coding them.

## Test-Driven Development (TDD)

Follow the red-green-refactor cycle for all features and bug fixes:

1. **Red** — write a failing test that describes the desired behavior.
2. **Green** — write the minimum code needed to make the test pass.
3. **Refactor** — clean up while keeping tests green.

- Write the test before the implementation. No production code without a failing test first.
- One behavior per test. Keep tests small, readable, and independent.
- For bug fixes, first write a test that reproduces the bug, then fix it.
- Run `dart test` and keep the suite green before considering work done.

## Dart / Flutter

- Follow standard Dart conventions and `dart format`.
- Run `dart analyze` and fix warnings before considering work done.
- Add tests for new behavior; run `dart test`.

## Working agreements

- Don't add dependencies without a clear need.
- Don't commit or push unless asked.
- When unsure about project specifics, ask rather than guess.
