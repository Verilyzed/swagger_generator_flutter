# Method Naming Option - Design

Date: 2026-06-23

## Goal

A build option that selects how generated service method names are derived:
from the spec's `operationId` (current behavior, the default) or from the HTTP
verb and request path.

## Option

`method_names` - a string option in the consuming project's `build.yaml`:

- `operationId` (default): names come from `operationId`, falling back to the
  verb and path when an operation has no `operationId`.
- `path`: names always come from the verb and path, ignoring `operationId`.

`BuilderConfig.fromOptions` reads it into a `bool nameFromPath` (`'path'` ->
true, anything else -> false).

## Naming logic

`SpecParser._operation` currently builds the method name as:

```dart
_names.memberName(op['operationId'] as String? ?? '${httpMethod.toLowerCase()}_$path')
```

With the flag, the raw name fed to `memberName` becomes:

- `nameFromPath == false`: `op['operationId'] ?? '<verb>_<path>'` (unchanged).
- `nameFromPath == true`: `'<verb>_<path>'`.

The path form reuses the existing fallback expression, so `GET /vaults/{vaultUuid}/items`
becomes `getVaultsVaultUuidItems` (path parameters are included, which keeps the
names unique across paths that differ only by a parameter segment).

## Data flow

```
build.yaml method_names option
  -> BuilderConfig.fromOptions (nameFromPath)
  -> SwaggerBuilder.build -> generateSources(nameFromPath: ...)
  -> SpecParser(nameFromPath: ...) -> _operation
```

## Components touched

- `lib/src/builder/builder_config.dart` - add `nameFromPath` from `method_names`.
- `lib/src/builder/swagger_builder.dart` - `generateSources` gains a
  `nameFromPath` parameter (default false), passed into `SpecParser`; `build`
  passes `config.nameFromPath`.
- `lib/src/parser/spec_parser.dart` - `SpecParser` constructor gains
  `bool nameFromPath = false`, used in `_operation`.
- `README.md` - document `method_names`.

## Testing

- `SpecParser`: one operation (operationId `GetServerHealth`, path `/health`)
  yields `getServerHealth` with `nameFromPath: false` and `getHealth` with
  `nameFromPath: true`.
- `BuilderConfig.fromOptions`: `method_names: path` -> `nameFromPath` true;
  absent or `operationId` -> false.
- `generateSources` passes the flag through (a parser test covers the behavior;
  the builder wiring is covered by the existing generateSources test compiling).

## Out of scope

- A `By<Param>` naming style.
- Per-operation naming overrides.
