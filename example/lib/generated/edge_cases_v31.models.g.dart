// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edge_cases_v31.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ping _$PingFromJson(Map<String, dynamic> json) => Ping(
  id: json['id'] as String,
  status: $enumDecodeNullable(
    _$StatusEnumMap,
    json['status'],
    unknownValue: Status.$unknown,
  ),
);

Map<String, dynamic> _$PingToJson(Ping instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$StatusEnumMap[instance.status],
};

const _$StatusEnumMap = {
  Status.active: 'ACTIVE',
  Status.inactive: 'INACTIVE',
  Status.$unknown: r'$unknown',
};

TypeShapes _$TypeShapesFromJson(Map<String, dynamic> json) => TypeShapes(
  strOrNull: json['strOrNull'] as String?,
  strOrInt: json['strOrInt'],
  strOrIntOrNull: json['strOrIntOrNull'],
  anyOfNull: json['anyOfNull'] as String?,
);

Map<String, dynamic> _$TypeShapesToJson(TypeShapes instance) =>
    <String, dynamic>{
      'strOrNull': instance.strOrNull,
      'strOrInt': instance.strOrInt,
      'strOrIntOrNull': instance.strOrIntOrNull,
      'anyOfNull': instance.anyOfNull,
    };

ThreeOneConstructs _$ThreeOneConstructsFromJson(Map<String, dynamic> json) =>
    ThreeOneConstructs(
      tuple: json['tuple'] as List<dynamic>?,
      constField: json['constField'],
      constTyped: json['constTyped'] as String?,
      emptySchema: json['emptySchema'],
      exampledField: json['exampledField'] as String?,
    );

Map<String, dynamic> _$ThreeOneConstructsToJson(ThreeOneConstructs instance) =>
    <String, dynamic>{
      'tuple': instance.tuple,
      'constField': instance.constField,
      'constTyped': instance.constTyped,
      'emptySchema': instance.emptySchema,
      'exampledField': instance.exampledField,
    };

Cat _$CatFromJson(Map<String, dynamic> json) =>
    Cat(meow: json['meow'] as bool?);

Map<String, dynamic> _$CatToJson(Cat instance) => <String, dynamic>{
  'meow': instance.meow,
};

Dog _$DogFromJson(Map<String, dynamic> json) =>
    Dog(bark: json['bark'] as bool?);

Map<String, dynamic> _$DogToJson(Dog instance) => <String, dynamic>{
  'bark': instance.bark,
};

Base _$BaseFromJson(Map<String, dynamic> json) =>
    Base(id: json['id'] as String);

Map<String, dynamic> _$BaseToJson(Base instance) => <String, dynamic>{
  'id': instance.id,
};

Derived _$DerivedFromJson(Map<String, dynamic> json) =>
    Derived(id: json['id'] as String, extra: json['extra'] as String?);

Map<String, dynamic> _$DerivedToJson(Derived instance) => <String, dynamic>{
  'id': instance.id,
  'extra': instance.extra,
};

Holder _$HolderFromJson(Map<String, dynamic> json) => Holder(
  pet: json['pet'],
  derived: json['derived'] == null
      ? null
      : Derived.fromJson(json['derived'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HolderToJson(Holder instance) => <String, dynamic>{
  'pet': instance.pet,
  'derived': instance.derived,
};

MapAndProps _$MapAndPropsFromJson(Map<String, dynamic> json) =>
    MapAndProps(name: json['name'] as String?);

Map<String, dynamic> _$MapAndPropsToJson(MapAndProps instance) =>
    <String, dynamic>{'name': instance.name};

FreeMapTrue _$FreeMapTrueFromJson(Map<String, dynamic> json) => FreeMapTrue();

Map<String, dynamic> _$FreeMapTrueToJson(FreeMapTrue instance) =>
    <String, dynamic>{};

FreeMapFalse _$FreeMapFalseFromJson(Map<String, dynamic> json) =>
    FreeMapFalse();

Map<String, dynamic> _$FreeMapFalseToJson(FreeMapFalse instance) =>
    <String, dynamic>{};

Nested _$NestedFromJson(Map<String, dynamic> json) => Nested(
  untypedArray: json['untypedArray'] as List<dynamic>?,
  arrayOfArrays: (json['arrayOfArrays'] as List<dynamic>?)
      ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
      .toList(),
  deep: (json['deep'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$NestedToJson(Nested instance) => <String, dynamic>{
  'untypedArray': instance.untypedArray,
  'arrayOfArrays': instance.arrayOfArrays,
  'deep': instance.deep,
};

Tree _$TreeFromJson(Map<String, dynamic> json) => Tree(
  value: json['value'] as String?,
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => Tree.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TreeToJson(Tree instance) => <String, dynamic>{
  'value': instance.value,
  'children': instance.children,
};

NodeA _$NodeAFromJson(Map<String, dynamic> json) => NodeA(
  b: json['b'] == null
      ? null
      : NodeB.fromJson(json['b'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NodeAToJson(NodeA instance) => <String, dynamic>{
  'b': instance.b,
};

NodeB _$NodeBFromJson(Map<String, dynamic> json) => NodeB(
  a: json['a'] == null
      ? null
      : NodeA.fromJson(json['a'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NodeBToJson(NodeB instance) => <String, dynamic>{
  'a': instance.a,
};

Formats _$FormatsFromJson(Map<String, dynamic> json) => Formats(
  uuid: json['uuid'] as String?,
  email: json['email'] as String?,
  uri: json['uri'] as String?,
  byte: json['byte'] as String?,
  binary: json['binary'] as String?,
  i32: (json['i32'] as num?)?.toInt(),
  i64: (json['i64'] as num?)?.toInt(),
  flt: (json['flt'] as num?)?.toDouble(),
  dec: (json['dec'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FormatsToJson(Formats instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'email': instance.email,
  'uri': instance.uri,
  'byte': instance.byte,
  'binary': instance.binary,
  'i32': instance.i32,
  'i64': instance.i64,
  'flt': instance.flt,
  'dec': instance.dec,
};

EnumHolder _$EnumHolderFromJson(Map<String, dynamic> json) => EnumHolder(
  intEnum: $enumDecodeNullable(
    _$IntEnumEnumMap,
    json['intEnum'],
    unknownValue: IntEnum.$unknown,
  ),
  weird: $enumDecodeNullable(
    _$WeirdEnumEnumMap,
    json['weird'],
    unknownValue: WeirdEnum.$unknown,
  ),
);

Map<String, dynamic> _$EnumHolderToJson(EnumHolder instance) =>
    <String, dynamic>{
      'intEnum': _$IntEnumEnumMap[instance.intEnum],
      'weird': _$WeirdEnumEnumMap[instance.weird],
    };

const _$IntEnumEnumMap = {
  IntEnum.$1: '1',
  IntEnum.$2: '2',
  IntEnum.$3: '3',
  IntEnum.$unknown: r'$unknown',
};

const _$WeirdEnumEnumMap = {
  WeirdEnum.withSpace: 'with space',
  WeirdEnum.withHyphen: 'with-hyphen',
  WeirdEnum.$1leading: '1leading',
  WeirdEnum.$class: 'class',
  WeirdEnum.dollar: r'$dollar',
  WeirdEnum.empty: '',
  WeirdEnum.$unknown: r'$unknown',
};
