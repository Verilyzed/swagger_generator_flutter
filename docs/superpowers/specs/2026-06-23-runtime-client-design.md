# Runtime-Working Generated Client - Design

Date: 2026-06-23

## Problem

The generated Chopper client compiles and `flutter analyze` is clean, but it
fails at runtime. A live request through the generated client throws:

```
type '_Map<String, dynamic>' is not a subtype of type 'Gadget?'
```

Two defects, found only by running the client against a live server:

1. **Responses do not deserialize.** `createClient` wires Chopper's built-in
   `JsonConverter`, which decodes a body to `Map`/`List` but cannot build typed
   models. Every typed endpoint (`Response<Gadget>`, `Response<List<Gadget>>`,
   `Response<GadgetContainer>`) throws.
2. **Optional/defaulted query parameters are generated as required.** A method
   like `listGadgets(StatusEnum? status, int limit, int offset)` forces callers
   to pass every query parameter even though the spec marks them optional with
   defaults.

## Goal

Make the generated client work at runtime: typed responses deserialize into the
generated model classes, and optional parameters can be omitted. Verified by a
real request/response round-trip against the test backend.

## Decisions

- Service methods keep returning `Future<Response<T>>` (`.body` is the typed
  model; status/headers/error handling preserved).
- The optional-parameter fix is included in this effort.
- The test backend's `Widget` entity is renamed to `Gadget` to avoid colliding
  with Flutter's `Widget`.

## Part 1: Typed converter

`ClientEmitter` emits a converter into `client.dart`:

```dart
typedef _FromJson = dynamic Function(Map<String, dynamic> json);

class JsonSerializableConverter extends JsonConverter {
  const JsonSerializableConverter(this.factories);
  final Map<Type, _FromJson> factories;

  T? _decodeMap<T>(Map<String, dynamic> values) {
    final factory = factories[T];
    return factory == null ? null : factory(values) as T;
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.whereType<Map<String, dynamic>>().map(_decodeMap<T>).whereType<T>().toList();

  dynamic _decode<T>(dynamic entity) {
    if (entity is Iterable) return _decodeList<T>(entity);
    if (entity is Map<String, dynamic>) return _decodeMap<T>(entity);
    return entity;
  }

  @override
  Response<ResultType> convertResponse<ResultType, Item>(Response response) {
    final decoded = super.convertResponse(response);
    return decoded.copyWith<ResultType>(body: _decode<Item>(decoded.body));
  }
}
```

`createClient` builds the factory map from every model and uses the converter:

```dart
ChopperClient createClient({required Uri baseUrl, List<Interceptor>? interceptors}) {
  return ChopperClient(
    baseUrl: baseUrl,
    converter: const JsonSerializableConverter({
      Gadget: Gadget.fromJson,
      GadgetContainer: GadgetContainer.fromJson,
      // ... one entry per model
    }),
    interceptors: interceptors ?? const [],
    services: [<Spec>Service.create()],
  );
}
```

Request bodies already serialize correctly: Dart's `jsonEncode` calls
`toJson()` on the model, which the generated models implement, so the request
path is unchanged.

To build the factory map, `ClientEmitter.emitClient` gains the model list and
the models import. `client.dart` imports `models.dart`.

Constraint detail: the factory map is emitted as a `const` map of `Type` keys to
`fromJson` constructor tear-offs (both are constant expressions). If the
analyzer rejects a `const` map here, fall back to a non-const map built inside
`createClient`.

Limitation: a top-level response that is a bare enum is not decoded by the
converter (enums have no `fromJson(Map)`); such responses are out of scope and
not produced by the test backend. Enum fields inside models still decode
correctly via json_serializable.

## Part 2: Optional and defaulted parameters

- **IR** (`lib/src/ir/api_spec.dart`): `ParamDef` gains `bool isRequired` and
  `String? defaultValue`.
- **SpecParser**: when building a `ParamDef`, read the parameter's `required`
  flag (default false) and its schema `default`, formatted with the existing
  enum-aware default logic (an enum default becomes `StatusEnum.active`, a
  string becomes `'all'`, numbers/bools bare, lists/maps omitted). This default
  formatting is shared with the model-field path, not duplicated.
- **ServiceEmitter**: `@Path` parameters stay required positional. Query and
  body parameters become named: required-named when the parameter is required,
  otherwise optional-named carrying the default (or just nullable when there is
  no default). Example:

```dart
@Get(path: '/gadgets')
Future<Response<List<Gadget>>> listGadgets({
  @Query('status') StatusEnum? status,
  @Query('limit') int limit = 50,
  @Query('offset') int offset = 0,
});
```

Path and query/body can mix (required positional path params, named query/body
params), which is valid Dart and supported by Chopper.

## Part 3: Backend rename

Rename `Widget` to `Gadget` across `backend/app/schemas.py`,
`backend/app/main.py`, and the backend tests, keeping every field and route the
same otherwise. Regenerate `backend/test_api.openapi.json`.

## Part 4: Runtime verification

The defining test is a real round-trip:

1. Start the backend: `uvicorn app.main:app --port 8000` from `backend/`.
2. Generate the client from `backend/test_api.openapi.json` (copied into
   `example/lib/` as a `*.openapi.json` input) via `build_runner build`.
3. Run a small consumer that creates the client with
   `baseUrl: http://localhost:8000`, calls `getGadget('w1')`,
   `listGadgets()` (no arguments, exercising the defaults), and
   `createGadget(...)`, and asserts the response bodies are real `Gadget` /
   `List<Gadget>` instances (not `Map`).
4. Tear down: stop the server, remove the temporary generated files, restore
   `example/` to its committed state.

This verification is a plan step (not a committed test), because it needs a live
Python server. Generator-side behavior is covered by emitter unit tests:

- `ClientEmitter` emits `JsonSerializableConverter`, a factory entry per model,
  and `createClient` using the converter.
- `ServiceEmitter` emits `@Path` required positional params and optional-named
  query params with defaults; a required query param stays required.
- `SpecParser` sets `ParamDef.isRequired` and `defaultValue` (including the
  enum-member default form).

## Components touched

- `lib/src/ir/api_spec.dart` - `ParamDef` fields.
- `lib/src/parser/spec_parser.dart` - param required/default; shared default formatting.
- `lib/src/emit/service_emitter.dart` - named optional params.
- `lib/src/emit/client_emitter.dart` - converter + factory map.
- `lib/src/builder/swagger_builder.dart` - pass models/import into `emitClient`.
- `backend/` - rename and regenerate.

## Out of scope

- Bare-enum top-level responses.
- Bare `Future<T>` return style (kept as `Future<Response<T>>`).
- A committed automated integration test that boots a live server.
