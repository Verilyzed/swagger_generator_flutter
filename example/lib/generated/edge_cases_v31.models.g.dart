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
  anyOfNull: json['anyOfNull'] as String?,
);

Map<String, dynamic> _$TypeShapesToJson(TypeShapes instance) =>
    <String, dynamic>{
      'strOrNull': instance.strOrNull,
      'strOrInt': instance.strOrInt,
      'anyOfNull': instance.anyOfNull,
    };
