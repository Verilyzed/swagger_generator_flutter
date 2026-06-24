# Unknown Enum Values - Design

Date: 2026-06-24

## Problem

Generated enums use json_serializable's `@JsonValue` map with no fallback, so a
value returned by the API that is not one of the enum's values throws a
`CheckedFromJsonException` during deserialization - the whole model `fromJson`
fails and the response is unusable.

## Goal

Map any unrecognized enum string to a sentinel value instead of throwing, so a
response with an unknown enum still deserializes.

## Sentinel member

Each generated enum gains one fallback member named `$unknown`. A plain
`unknown` would collide with real values (e.g. 1Password's `ErrorCode` already
has `unknown` from `UNKNOWN`). `NameGiver` never produces a `$`-prefixed name
from a spec value, so `$unknown` is collision-safe by construction. It has no
`@JsonValue`, so no real string maps to it:

```dart
enum ErrorCode {
  @JsonValue('UNKNOWN')
  unknown,
  @JsonValue('NOT_FOUND')
  notFound,
  // Fallback for values not present in the spec.
  $unknown,
}
```

## Routing unknown values

The `ModelEmitter` adds `unknownEnumValue: <Enum>.$unknown` to each enum-typed
field's `@JsonKey`, merged with any existing `name:`:

```dart
@JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
final ErrorCode errorCode;
```

To know which fields are enums, `ModelEmitter.emit` gains an `enumNames` set
(the `ServiceEmitter` already takes one); `generateSources` passes
`spec.enums.map((e) => e.name).toSet()`. A field is an enum field when any
identifier in its type name is an enum name (covers a scalar `StatusEnum`; see
the caveat for `List<StatusEnum>`).

## Caveats

- Round-trip loss: a value that arrived unknown serializes back as `"$unknown"`;
  the original string is not preserved. This is inherent to the sentinel
  approach. The alternative (unknown -> null) would force every enum field
  nullable, which is out of scope.
- `List<Enum>` fields: whether json_serializable applies `unknownEnumValue` to
  enum elements inside a list is confirmed at build time. If it rejects it, the
  emitter narrows to scalar enum fields (type name exactly equal to an enum
  name) and leaves list-of-enum fields without the fallback.

## Components touched

- `lib/src/emit/enum_emitter.dart` - append the `$unknown` member.
- `lib/src/emit/model_emitter.dart` - `enumNames` parameter and
  `unknownEnumValue` on enum fields.
- `lib/src/builder/swagger_builder.dart` - pass `enumNames` to `ModelEmitter`.

## Testing

- `EnumEmitter`: each enum ends with a `$unknown` member with no `@JsonValue`.
- `ModelEmitter`: an enum-typed field gets
  `@JsonKey(... unknownEnumValue: <Enum>.$unknown)`; a non-enum field does not;
  the `name:` and `unknownEnumValue:` merge into one `@JsonKey`.
- End-to-end: regenerate, then a runtime round-trip where the mock returns an
  enum value not in the spec, asserting the field deserializes to the sentinel
  instead of throwing.

## Out of scope

- Mapping unknown enum values to `null`.
- Preserving the original unknown string.
