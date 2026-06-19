# Swagger Generator Flutter - Design

Date: 2026-06-20

## Goal

Generate Dart/Flutter code from an OpenAPI (Swagger) specification
(`.json`, `.yaml`, `.yml`). Output is type-safe Dart: enums, model classes with
JSON serialization, a single Chopper service exposing every endpoint, and a
Chopper client that wires them together.

The generated code is compatible with:

- `json_serializable` for model serialization (`fromJson`/`toJson`).
- `chopper` for the HTTP client (services and converter).

## Scope

In scope:

- Parse OpenAPI 3.x specs (target sample is OpenAPI 3.1.0, FastAPI style).
- Emit enums, model classes, one Chopper service, a Chopper client, and a barrel.
- Run as a `build_runner` Builder that chains into `json_serializable` and
  `chopper_generator`.

Out of scope (for now):

- Per-tag service splitting (one service class for the whole spec).
- A standalone CLI (the Builder is the only entry point).
- `freezed` / hand-written serialization (json_serializable only).

## Architecture: Parse -> IR -> Emit

Three stages with a single shared type resolver and a single shared name unit.
Parsing never produces Dart syntax; emitting never reads raw spec maps.

1. **Parse** - read the spec (JSON or YAML) into a normalized in-memory
   Intermediate Representation (IR): `ApiSpec { enums, models, service }`, with
   `$ref`, `anyOf`-null, defaults, and formats already resolved.
2. **Resolve** - a single `DartTypeResolver` maps any OpenAPI schema node to a
   Dart type (`String`, `DateTime`, `List<Task>`, `TaskStateEnum`, nullable
   `?`). This is the unit every emitter reuses.
3. **Emit** - small emitters turn IR into Dart source strings. They share
   helpers for naming (`NameGiver`), file headers, indentation, and imports.

## Components

```
lib/
  swagger_generator_flutter.dart      # public exports + Builder factory
  src/
    parser/
      spec_loader.dart                # bytes -> Map (JSON or YAML)
      spec_parser.dart                # Map -> ApiSpec (IR); resolves $ref, anyOf-null, defaults
    ir/
      api_spec.dart                   # ApiSpec, EnumDef, ModelDef, FieldDef, ServiceDef, OperationDef
      dart_type.dart                  # DartType { name, isNullable, imports }
    resolve/
      dart_type_resolver.dart         # schema node -> DartType  (shared unit)
      name_giver.dart                 # valid Dart names for classes/enums/services/fields; keyword + collision handling
    emit/
      source_writer.dart              # shared: file header, import block, indentation
      enum_emitter.dart               # EnumDef[]  -> enums.dart
      model_emitter.dart              # ModelDef[] -> models.dart (@JsonSerializable)
      service_emitter.dart            # ServiceDef -> one ChopperService
      client_emitter.dart             # client.dart (ChopperClient assembly)
    builder/
      swagger_builder.dart            # build_runner Builder entry point
```

Reuse rule: every stage depends only on the IR plus `dart_type_resolver` and
`name_giver`. No name logic or type-mapping logic is duplicated in emitters.

### NameGiver

A single shared unit that turns any OpenAPI title/key into a valid Dart
identifier:

- PascalCase for classes, enums, services.
- camelCase for fields; original JSON key preserved via `@JsonKey(name: ...)`
  when it differs.
- Escapes Dart reserved words and illegal characters.
- Deduplicates on name collisions.

### DartTypeResolver

Maps a schema node to a `DartType`. Handles, in one place:

- `string` + `format: date-time` -> `DateTime`.
- `anyOf: [X, {type: null}]` -> `X?` (nullable).
- `$ref` -> referenced enum/model type.
- arrays -> `List<T>`.
- primitives -> `String`, `int`, `double`, `bool`, `num`.

## Generated output

A fixed set of files per input spec, under `lib/generated/`:

```
lib/generated/
  <spec>.enums.dart      # all enums
  <spec>.models.dart     # all classes (+ .g.dart)
  <spec>.service.dart    # one ChopperService, all endpoints (+ .chopper.dart)
  <spec>.client.dart     # ChopperClient assembly
  <spec>.api.dart        # barrel export
```

### Enums

One enum per OpenAPI enum schema, all in `enums.dart`. JSON values mapped with
`@JsonValue`:

```dart
enum AggregationEnum {
  @JsonValue('month') month,
  @JsonValue('year') year,
}
```

### Models

One class per object schema, all in `models.dart`, sharing a single
`part '<spec>.models.g.dart';`. Each class is `@JsonSerializable` with
`fromJson`/`toJson`. The resolver and NameGiver handle:

- `asset_id` -> field `assetId` plus `@JsonKey(name: 'asset_id')`.
- `format: date-time` -> `DateTime`.
- `anyOf: [X, null]` -> `X?`.
- `$ref` -> referenced type.
- `required` list -> which fields are non-null / `required` in the constructor.
- `default` -> default parameter value.

### Service

One `ChopperService` for the whole spec. Because paths have different prefixes,
`@ChopperApi(baseUrl: '')` is used and each method carries the full path:

```dart
@ChopperApi(baseUrl: '')
abstract class <Spec>Service extends ChopperService {
  @Get(path: '/assets/{asset_id}/schedule')
  Future<Response<Schedule>> getScheduleForAsset(
    @Path('asset_id') String assetId,
    @Query('deadline_filter') DeadlineFilterEnum? deadlineFilter,
  );
  static <Spec>Service create([ChopperClient? c]) => _$<Spec>Service(c);
}
```

### Client

`client.dart` assembles a `ChopperClient` with the json_serializable-based
converter and the generated service. `api.dart` is a barrel that exports enums,
models, service, and client.

## build_runner wiring

Build phases:

1. **SwaggerBuilder** runs on the spec file and emits annotated `.dart`
   (enums, models, service, client, barrel).
2. **json_serializable** sees `models.dart` and emits `models.g.dart`.
3. **chopper_generator** sees `service.dart` and emits `service.chopper.dart`.

Ordering is declared in `build.yaml` with our builder running before
`json_serializable` and `chopper_generator`, which consume its generated
`.dart` output.

Constraint that shaped the design: a build_runner `Builder` must declare its
output file names up front via `buildExtensions`, derived from the input file
name. Output names are therefore a fixed set per spec. Choosing one service
class for the whole spec (rather than one per tag) keeps every output name fixed
and removes any need for a post-process step or CLI.

## Testing (TDD)

Bottom-up, red-green-refactor, one behavior per test:

- **NameGiver** - table-driven: `asset_id` -> `assetId`, keyword escaping,
  illegal-character stripping, collision dedup.
- **SpecParser** - literal spec `Map`s in, assert IR out: `$ref` resolves,
  `anyOf:[X,null]` -> nullable, `required` honored, `default` captured, enum vs
  object classified.
- **DartTypeResolver** - table-driven: schema node -> expected `DartType`
  (name + nullable + import).
- **Emitters** - hand-built IR in, assert emitted source contains the right
  declarations (snapshot / substring assertions). One test per emitter.
- **End-to-end** - full pipeline on a trimmed fixture spec; assert generated
  files. Smoke test against the real `resource-scheduler-openapi.json` that it
  parses and emits without throwing.

`dart analyze` clean and `dart test` green before any work is considered done.

## Dependencies

New dependencies (justified by need):

- `build` / `source_gen` - build_runner Builder API.
- `yaml` - parse `.yaml` / `.yml` specs.
- `json_serializable`, `json_annotation` - model serialization (dev + runtime).
- `chopper`, `chopper_generator` - HTTP client (runtime + dev).

## Open items

None. Service layout, file layout, serialization approach, and invocation are
all decided above.
