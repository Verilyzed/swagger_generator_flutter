# Shared Operation Naming - Design

Date: 2026-06-23

## Problem

Hoisted request/response models are named `<operationId>Request` /
`<operationId>Response`, falling back to the literal `operation` when an
operation has no `operationId` - producing `OperationRequest` /
`OperationResponse` (and de-duplicated `...2`). Method names, by contrast, fall
back to the verb and path, and honor the `method_names: path` option. The two
naming paths diverge.

## Goal

Name hoisted request/response models with the same rule the parser uses for
method names: `operationId` by default (falling back to the verb and path when
absent), or the verb and path directly when `method_names: path` is set.
`Operation...` never appears. The decision lives in one shared function.

## Shared helper

`lib/src/parser/operation_name.dart` (new):

```dart
String operationBaseName({
  required String httpMethod,
  required String path,
  String? operationId,
  required bool nameFromPath,
}) =>
    nameFromPath
        ? '${httpMethod.toLowerCase()}_$path'
        : operationId ?? '${httpMethod.toLowerCase()}_$path';
```

This is the single source of truth for "what an operation is named from".

- `SpecParser._operation`: method name becomes
  `_names.memberName(operationBaseName(...))`.
- `SchemaHoister._hoistOperation`: request/response model base becomes
  `operationBaseName(...)`, and the content names become `'<base> request'` /
  `'<base> response'`, which `NameGiver.className` turns into e.g.
  `PostVaultsVaultUuidItemsRequest`.

## Hoister changes

- `SchemaHoister(NameGiver names, {bool nameFromPath = false})` gains the flag.
- `hoist` iterates `paths.entries` and each path item's method entries, passing
  the path and the verb (the method key) into `_hoistOperation`, so it can call
  `operationBaseName`.
- `SwaggerBuilder.generateSources` passes `nameFromPath` into the hoister (it
  already threads the flag for the parser).

## Components touched

- `lib/src/parser/operation_name.dart` (new) - shared `operationBaseName`.
- `lib/src/parser/spec_parser.dart` - use it for the method name.
- `lib/src/parser/schema_hoister.dart` - `nameFromPath`, path/verb, use it for
  model names.
- `lib/src/builder/swagger_builder.dart` - pass `nameFromPath` to the hoister.

## Testing

- `operationBaseName`: `operationId` set + `nameFromPath` false -> the
  operationId; absent -> `<verb>_<path>`; `nameFromPath` true -> `<verb>_<path>`
  even with an operationId.
- `SchemaHoister`: an operation with no `operationId` and an inline response
  object yields a model named from the path (no `Operation...`); with
  `nameFromPath: true` the model is named from the path despite an operationId.
- `SpecParser`: the existing method-name tests still pass (operationId default
  and `nameFromPath` path form), now via the shared helper.

## Out of scope

- Changing the path-name segment scheme (still raw segments).
- The unknown-enum handling (separate effort).
