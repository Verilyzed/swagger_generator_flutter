// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edge_cases_v30.models.dart';

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

Cat _$CatFromJson(Map<String, dynamic> json) =>
    Cat(meow: json['meow'] as bool?);

Map<String, dynamic> _$CatToJson(Cat instance) => <String, dynamic>{
  'meow': instance.meow,
};

Nullable30 _$Nullable30FromJson(Map<String, dynamic> json) => Nullable30(
  plain: json['plain'] as String?,
  refSibling: json['refSibling'] == null
      ? null
      : Cat.fromJson(json['refSibling'] as Map<String, dynamic>),
  wrapped: json['wrapped'] == null
      ? null
      : Cat.fromJson(json['wrapped'] as Map<String, dynamic>),
  anyOfNull: json['anyOfNull'] == null
      ? null
      : Cat.fromJson(json['anyOfNull'] as Map<String, dynamic>),
);

Map<String, dynamic> _$Nullable30ToJson(Nullable30 instance) =>
    <String, dynamic>{
      'plain': instance.plain,
      'refSibling': instance.refSibling,
      'wrapped': instance.wrapped,
      'anyOfNull': instance.anyOfNull,
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

Tree _$TreeFromJson(Map<String, dynamic> json) => Tree(
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => Tree.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TreeToJson(Tree instance) => <String, dynamic>{
  'children': instance.children,
};
