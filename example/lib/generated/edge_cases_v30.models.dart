// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'edge_cases_v30.enums.dart';

part 'edge_cases_v30.models.g.dart';

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

