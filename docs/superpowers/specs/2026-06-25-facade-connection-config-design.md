# Facade Connection Configuration - Design

Date: 2026-06-25

## Problem

Each generated spec produces its own top-level `createClient`, `JsonSerializableConverter`,
and `JsonFactory`. With multiple specs these names collide when referenced
together, and the only way to configure a connection
(`baseUrl`/`interceptors`/...) is through the per-spec `createClient`. The current
facade also only accepts a pre-built `ChopperClient`. Users want to configure the
connection directly on the per-spec facade (which is already uniquely named) and
never touch `createClient`. They also want the same knobs an older generator
exposed: `baseUrl`, `httpClient`, `interceptors`, and `authenticator`.

## Design

### `createClient` gains the missing knobs

```dart
import 'package:http/http.dart' show Client;

ChopperClient createClient({
  required Uri baseUrl,
  Client? httpClient,
  List<Interceptor>? interceptors,
  Authenticator? authenticator,
}) {
  return ChopperClient(
    baseUrl: baseUrl,
    client: httpClient,
    converter: const JsonSerializableConverter({ ... }),
    interceptors: interceptors ?? const [],
    authenticator: authenticator,
    services: [NewapiService.create()],
  );
}
```

`Authenticator` is exported by `package:chopper/chopper.dart`; `Client` comes from
`package:http/http.dart`, so the generated client imports `package:http` and
consumers need it as a direct dependency.

### The facade takes connection parameters directly

The facade moves into the client file (where the converter and `createClient`
live, avoiding a circular import) and gains two constructors:

```dart
class NewapiApi {
  final NewapiService _service;

  NewapiApi({
    required Uri baseUrl,
    Client? httpClient,
    List<Interceptor>? interceptors,
    Authenticator? authenticator,
  }) : this.fromClient(createClient(
          baseUrl: baseUrl,
          httpClient: httpClient,
          interceptors: interceptors,
          authenticator: authenticator,
        ));

  /// Reuse an existing ChopperClient.
  NewapiApi.fromClient(ChopperClient client)
      : _service = NewapiService.create(client);

  // ... the same delegating methods as today ...
}
```

Usage with multiple specs, no `createClient` call, no name collisions:

```dart
final newapi = NewapiApi(baseUrl: a, authenticator: auth);
final scheduler = ResourceSchedulerApi(baseUrl: b, interceptors: [log]);
```

`createClient` stays public as the internal builder, but is demoted - it is only
called by the facade. It can still collide across specs, but only if referenced
directly, which is no longer necessary.

## Structural changes

- The facade emission moves from `ServiceEmitter` to `ClientEmitter`. The chopper
  abstract service stays in the service file; only the facade relocates.
- The client file's imports become conditional on what the facade uses:
  - `package:http/http.dart` - always `show Client` (for `createClient`), also
    `MultipartFile` when the facade forwards a file part.
  - the `enums` import - when a facade signature references an enum.
  - the `overrides` import - when an override type is referenced (already imported
    for the factory map; unchanged condition).
- `ClientEmitter.emitClient` gains an `enumNames` parameter so it can decide the
  enums import and reuse the existing enum-usage scan.
- The barrel is unchanged; the facade is still exported because the client file is
  exported.

## Components touched

- `lib/src/emit/client_emitter.dart` - `createClient` params; facade emission with
  the two constructors; conditional `http`/`enums`/`overrides` imports;
  `enumNames` parameter.
- `lib/src/emit/service_emitter.dart` - remove facade emission and its helpers;
  keep the chopper service and its enum/override import logic.
- `lib/src/builder/swagger_builder.dart` - pass `enumNames` to `emitClient`.
- `example/pubspec.yaml` - add `http` as a direct dependency.
- `README.md` - document the facade constructor and the `http` requirement.

## Testing

- `ClientEmitter`: `createClient` exposes `httpClient` and `authenticator` and
  passes `client:`/`authenticator:`; the client imports `package:http` `show Client`;
  the facade class is emitted with the direct-parameter constructor and the
  `fromClient` constructor; a facade method delegates as before; the enums import
  appears when a facade signature uses an enum.
- `ServiceEmitter`: the service file no longer contains the facade class.
- End-to-end: the generated `.client.dart` contains the facade and the
  `.service.dart` does not; `flutter analyze` of the regenerated example is clean.

## Out of scope

- Renaming or making `createClient`/`JsonSerializableConverter` private or
  per-spec unique.
- Sharing one `ChopperClient` across multiple specs (each has its own converter).
- A cross-spec barrel.
