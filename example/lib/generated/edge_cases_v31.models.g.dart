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
