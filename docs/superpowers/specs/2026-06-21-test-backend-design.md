# Edge-Case Test Backend - Design

Date: 2026-06-21

## Goal

Provide a small, disposable FastAPI backend whose auto-generated OpenAPI 3.1
spec exercises a broad range of the constructs the generator supports, so the
generator can be tested against realistic edge cases. The backend lives in the
repo for convenience and is deletable with `rm -rf backend/` with no impact on
the package.

## Why FastAPI

FastAPI auto-generates OpenAPI 3.1 - the exact dialect the generator targets
(the original sample spec was FastAPI-produced). It naturally emits the
constructs we handle: `anyOf` null for optionals, `$ref` enums, defaults,
`additionalProperties` maps, and `date-time` formats. Writing Pydantic models
is the least-effort way to produce a rich, valid spec.

## Layout

```
backend/
  README.md              # setup, how to export the spec, and "delete me" note
  requirements.txt       # fastapi, uvicorn
  export_openapi.py      # writes app.openapi() -> test_api.openapi.json
  app/
    schemas.py           # enums + Pydantic models (the edge cases)
    main.py              # FastAPI app + routes (all five HTTP verbs)
  test_api.openapi.json  # the generated swagger file
```

The split keeps schemas (data shapes) separate from routes (endpoints), each
independently readable.

## Producing the swagger file

`export_openapi.py` imports the app and writes `app.openapi()` to
`backend/test_api.openapi.json`, pretty-printed. This is deterministic and needs
no running server (preferred over curling a live `uvicorn`). The server can
still be run manually (`uvicorn app.main:app --reload`) for poking at it, but the
export does not depend on it. If FastAPI is not installed, the script exits with
a clear message pointing at `requirements.txt`.

## Edge cases covered (all generator-supported features)

Enums and defaults:
- `StatusEnum`, `PriorityEnum` (string enums).
- A field typed as an enum with a default value (exercises the enum-member
  default path, e.g. `priority: PriorityEnum = PriorityEnum.low`).
- `ErrorCodeEnum` with a default on an error model.

Field types:
- Nullable/optional (`Optional[str] = None` -> `anyOf` null -> `String?`).
- Optional non-nullable with a default (`count: int = 0`).
- `List[str]`, `List[Widget]` (arrays of primitives and refs).
- `Dict[str, str]`, `Dict[str, Any]`, `Dict[str, Widget]`
  (`additionalProperties` -> `Map<String, String>` / `Map<String, dynamic>` /
  `Map<String, Widget>`).
- Primitives: `int`, `float`, `bool`, `str`, `datetime` (-> `DateTime`).
- Nested `$ref` models (a container referencing `Widget`).

Naming stress for NameGiver:
- `snake_case` keys (`asset_id` -> `assetId`).
- An acronym key (`html_url`).
- A reserved-word JSON key via alias (`default` -> `default_`).

Endpoints (one service after generation; tags used for grouping in the spec):
- `GET /widgets` - optional enum query param with default, plus `limit`/`offset`.
- `GET /widgets/{widget_id}` - path param; 404/422 error responses.
- `POST /widgets` - request body (`WidgetCreate`).
- `PUT /widgets/{widget_id}` - path param + body.
- `PATCH /widgets/{widget_id}` - path param + partial body.
- `DELETE /widgets/{widget_id}` - path param.
- `GET /containers/{container_id}` - returns a container with nested ref, list,
  and map fields.

Route handlers return simple constructed/placeholder data; the spec, not the
runtime behavior, is the product.

## Data flow

```
Pydantic schemas + routes (FastAPI app)
  -> export_openapi.py
  -> backend/test_api.openapi.json
  -> (manual) generator: copy into example/lib, run build_runner
  -> generated Dart
```

## Error handling

- `export_openapi.py`: clear message if FastAPI import fails.
- Route handlers: a couple of endpoints declare 404/422 responses so the spec
  carries error schemas, mirroring the real sample spec.

## Verification

1. Build the app and run `export_openapi.py`; confirm `test_api.openapi.json` is
   produced and is valid OpenAPI 3.1 (has `openapi: 3.1.x`, `components.schemas`,
   `paths`).
2. End-to-end: copy `test_api.openapi.json` into `example/lib/` as a
   `*.openapi.json` input, run `build_runner build`, and confirm the generated
   Dart analyzes clean. This is the actual edge-case test of the generator.

## Out of scope

- A database or real persistence (handlers return placeholder data).
- Authentication and middleware.
- Constructs the generator does not yet support (allOf/oneOf composition,
  anonymous inline objects, recursive models) - deliberately excluded per the
  chosen "broad coverage of handled cases" scope.

## Disposal

`backend/` is self-contained. Deleting the folder removes the backend entirely;
nothing in the Dart package imports from it.
