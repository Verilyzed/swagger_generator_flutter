# Date Fields and Optional Parameters - Design

Date: 2026-06-24

Two related ergonomics changes to the generated client.

## Feature A: `format: date` maps to `DateTime`

### Problem

A `string` schema with `format: date` (e.g. `"2026-06-24"`) currently generates a
Dart `String`. Only `format: date-time` maps to `DateTime`. Callers want a
`DateTime` for date fields too.

### Approach

The resolver maps `format: date` to `DateTime`, distinct from `date-time` so the
model emitter can give it date-only serialization. A `DateTime` serialized by
json_serializable defaults to a full ISO timestamp
(`"2026-06-24T00:00:00.000"`), which a date-typed backend rejects. A generated
`DateConverter` keeps the round-trip date-only:

```dart
class DateConverter implements JsonConverter<DateTime, String> {
  const DateConverter();
  @override
  DateTime fromJson(String json) => DateTime.parse(json);
  @override
  String toJson(DateTime object) => object.toIso8601String().split('T').first;
}

@JsonKey(name: 'occurred_at')
@DateConverter()
final DateTime? occurredAt;
```

### Mechanics

- `DartType` gains an `isDateOnly` flag (default `false`).
- `_resolveCore`: `format == 'date'` -> `DartType('DateTime', isDateOnly: true)`;
  `date-time` -> `DartType('DateTime')` (unchanged).
- `resolve` preserves `isDateOnly` when it re-wraps a nullable type.
- `ModelEmitter` emits `@DateConverter()` on any field whose type `isDateOnly`,
  and emits the `DateConverter` class once per models file, only when at least
  one date field is present.
- json_serializable null-guards a non-null converter on a nullable field, so one
  converter serves both `DateTime` and `DateTime?` fields. Confirmed at build.

### Limitation

A `date` used as a query or path parameter maps to `DateTime` but is serialized
by Chopper's default `DateTime.toString()`, not the converter (converters apply
to model fields, not Chopper parameters). No date parameters exist in the current
specs; this is left as a known limitation rather than built for.

## Feature B: optional parameters are nullable; defaults applied client-side

### Problem

Optional parameters currently bake the default into the Chopper method signature
(`SortOrderEnum order = SortOrderEnum.asc`). A caller cannot pass `null`. The
caller wants to pass `null` (or omit) and have the default applied client-side
and sent.

A Chopper service method is `abstract` - its body is generated, so a default
cannot be applied inside it. The default is therefore applied in a thin generated
facade that wraps the Chopper service.

### Approach

The Chopper method's optional parameters become nullable with no default. A
generated facade class (`<Base>Api`) exposes the same method names, takes nullable
parameters, applies `value ?? <default>` for parameters that have a spec default,
and delegates to the Chopper service:

```dart
// Chopper service (internal) - nullable, no defaults
abstract class ResourceSchedulerService extends ChopperService {
  @GET(path: '/assets/{asset_id}/tasks')
  Future<Response<List<Task>>> listTasksForAsset({
    @Path('asset_id') required String assetId,
    @Query('order') SortOrderEnum? order,
    @Query('limit') int? limit,
  });
  static ResourceSchedulerService create([ChopperClient? client]) =>
      _$ResourceSchedulerService(client);
}

// Generated facade - the public API
class ResourceSchedulerApi {
  final ResourceSchedulerService _service;
  ResourceSchedulerApi(ChopperClient client)
      : _service = ResourceSchedulerService.create(client);

  Future<Response<List<Task>>> listTasksForAsset({
    required String assetId,
    SortOrderEnum? order,
    int? limit,
  }) =>
      _service.listTasksForAsset(
        assetId: assetId,
        order: order ?? SortOrderEnum.asc,
        limit: limit ?? 5,
      );
}
```

Call site:

```dart
final api = ResourceSchedulerApi(createClient(baseUrl: ...));
await api.listTasksForAsset(assetId: 'x', order: null); // sends order=asc
await api.listTasksForAsset(assetId: 'x');              // sends order=asc
await api.listTasksForAsset(assetId: 'x', order: SortOrderEnum.desc);
```

### Mechanics

- `ServiceEmitter._namedParam`: drop the `defaultValue` branch. A non-required
  parameter is always emitted nullable (`Type? name`) with no default. Required
  and path parameters stay `required`.
- `ServiceEmitter` emits a facade class after the Chopper service. Facade name is
  the service name with the `Service` suffix replaced by `Api`
  (`ResourceSchedulerService` -> `ResourceSchedulerApi`).
- Facade method signatures mirror the Chopper method but without Chopper
  annotations. Delegation per parameter:
  - required -> `name: name`
  - optional with a default -> `name: name ?? <defaultValue>`
  - optional without a default -> `name: name`
- Multipart parameters (`part` / `partFile`) are forwarded unchanged; the
  `@multipart` annotation stays only on the Chopper method.
- The facade lives in the service file (which already imports chopper, models,
  and conditionally enums and `MultipartFile`), so the barrel needs no change.
- `ResourceSchedulerService.create` remains available for advanced use.

### Behavior change

Previously, omitting `limit` sent the client-baked default. Now both omitting and
passing `null` send the same default via the facade, so behavior is equivalent
for defaulted parameters. Optional parameters with no spec default still omit the
query parameter when `null`.

## Components touched

- `lib/src/ir/dart_type.dart` - `isDateOnly` flag.
- `lib/src/resolve/dart_type_resolver.dart` - `date` -> `DateTime`, preserve flag.
- `lib/src/emit/model_emitter.dart` - `DateConverter` class and `@DateConverter()`.
- `lib/src/emit/service_emitter.dart` - nullable optional params, facade class.

## Testing

- Resolver: `format: date` -> `DartType('DateTime', isDateOnly: true)`; nullable
  date preserves the flag; `date-time` unchanged.
- `ModelEmitter`: a date field emits `@DateConverter()` and the `DateConverter`
  class; a model with no date field emits neither.
- `ServiceEmitter`: an optional query param emits `Type? name` with no `=`; a
  facade class is emitted with `name ?? <default>` delegation and `name: name`
  for params without a default; required/path params stay `required`.
- End-to-end: regenerate the example; `flutter analyze` clean; a runtime
  round-trip through the facade where `order: null` results in the server
  receiving the default, and a date field round-trips as `"YYYY-MM-DD"`.

## Out of scope

- Date-only serialization for Chopper query/path parameters.
- Mapping `format: date` to a date-only value type other than `DateTime`.
