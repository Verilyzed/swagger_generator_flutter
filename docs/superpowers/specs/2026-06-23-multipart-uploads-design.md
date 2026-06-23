# Multipart Uploads - Design

Date: 2026-06-23

## Goal

Generate Chopper multipart methods for `multipart/form-data` request bodies, so
file uploads work. Each field of the multipart schema becomes its own part
parameter; file fields (`type: string, format: binary`) use `MultipartFile`.

## Detection and mapping

A request body whose content declares `multipart/form-data` is a multipart
endpoint. Its schema (inline object or `$ref` to a named object) has properties;
each property becomes a part instead of one `@Body()`:

- `type: string, format: binary` -> file part: `@PartFile('name') MultipartFile name`.
- any other property -> value part: `@Part('name') <resolvedType> name`.

Required vs optional follows the schema's `required` list, like other named
parameters. If both `application/json` and `multipart/form-data` are declared,
multipart wins (the endpoint is treated as an upload).

## IR

`ParamLocation` gains `part` and `partFile`.

## Parser

`SpecParser._operation`: before the existing `@Body()` path, check
`requestBody.content['multipart/form-data']`. If present, resolve its schema to
an object (following a `$ref` via the schemas cache and merging `allOf` with the
existing `_mergedObject`), then add one `ParamDef` per property:

- file property -> `ParamDef(location: partFile, type: DartType('MultipartFile'), wireName: prop)`.
- other property -> `ParamDef(location: part, type: <resolved>, wireName: prop)`.

`isRequired` from the schema's `required` list. No `body` ParamDef is added for
multipart endpoints.

## Hoister

`SchemaHoister` skips `multipart/form-data` media schemas (does not hoist them),
so no dead `<Op>Request` model is generated; the parser reads the part
properties directly. A `$ref` to a real named component schema is unaffected (it
is already a model and is resolved by the parser).

## Emitter

`ServiceEmitter`:

- A method with any `part`/`partFile` parameter emits `@multipart` on its own
  line after the `@VERB(path: ...)` annotation.
- `_annotation` adds `ParamLocation.part -> @Part('wire')` and
  `ParamLocation.partFile -> @PartFile('wire')`.
- File parts use the `MultipartFile` type (already set on the `ParamDef`).
- If `package:chopper/chopper.dart` does not re-export `MultipartFile`, the
  service file adds `import 'package:http/http.dart' show MultipartFile;`. This
  is confirmed during the runtime check; the import is only added when a
  `partFile` parameter exists.

## Backend and verification

Add a `multipart/form-data` upload endpoint to the FastAPI test backend, e.g.
`POST /gadgets/{gadget_id}/attachments` taking an `UploadFile` file plus a text
field, returning a small JSON acknowledging the filename and field. Regenerate
the backend spec.

End-to-end: regenerate, build a `MultipartFile.fromBytes(...)` with a filename,
call the generated upload method, and assert the backend received the file
(filename present) and the field value. This confirms the wire format and that
`MultipartFile` carries the filename.

## Components touched

- `lib/src/ir/api_spec.dart` - `ParamLocation` values.
- `lib/src/parser/spec_parser.dart` - multipart part parameters.
- `lib/src/parser/schema_hoister.dart` - skip multipart media.
- `lib/src/emit/service_emitter.dart` - `@multipart` and part annotations.
- `backend/` - upload endpoint and regenerated spec.

## Testing

- `SpecParser`: a `multipart/form-data` body with a binary `file` property and a
  text `label` property yields a `partFile` param (`MultipartFile`) and a `part`
  param, and no `body` param.
- `SchemaHoister`: a multipart media schema is left inline (not hoisted).
- `ServiceEmitter`: a method with part params emits `@multipart`,
  `@PartFile('file') MultipartFile file`, and `@Part('label') ...`.
- End-to-end: the upload round-trip against the backend.

## Out of scope

- `@PartMap` / dynamic part maps.
- Multipart responses.
- `format: byte` (base64) treated as a file (only `binary` is a file part).
