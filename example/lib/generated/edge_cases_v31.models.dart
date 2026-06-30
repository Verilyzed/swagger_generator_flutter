// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'edge_cases_v31.enums.dart';

part 'edge_cases_v31.models.g.dart';

@JsonSerializable()
class Ping {
  final String id;
  @JsonKey(unknownEnumValue: Status.$unknown)
  final Status? status;

  const Ping({
    required this.id,
    this.status,
  });

  Ping copyWith({
    String? id,
    Status? status,
  }) {
    return Ping(
      id: id ?? this.id,
      status: status ?? this.status,
    );
  }

  factory Ping.fromJson(Map<String, dynamic> json) =>
      _$PingFromJson(json);

  Map<String, dynamic> toJson() => _$PingToJson(this);
}

@JsonSerializable()
class TypeShapes {
  final String? strOrNull;
  final dynamic strOrInt;
  final dynamic strOrIntOrNull;
  final String? anyOfNull;

  const TypeShapes({
    this.strOrNull,
    required this.strOrInt,
    this.strOrIntOrNull,
    this.anyOfNull,
  });

  TypeShapes copyWith({
    String? strOrNull,
    dynamic strOrInt,
    dynamic strOrIntOrNull,
    String? anyOfNull,
  }) {
    return TypeShapes(
      strOrNull: strOrNull ?? this.strOrNull,
      strOrInt: strOrInt ?? this.strOrInt,
      strOrIntOrNull: strOrIntOrNull ?? this.strOrIntOrNull,
      anyOfNull: anyOfNull ?? this.anyOfNull,
    );
  }

  factory TypeShapes.fromJson(Map<String, dynamic> json) =>
      _$TypeShapesFromJson(json);

  Map<String, dynamic> toJson() => _$TypeShapesToJson(this);
}

