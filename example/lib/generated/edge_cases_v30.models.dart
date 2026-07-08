// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'edge_cases_v30.enums.dart';

part 'edge_cases_v30.models.g.dart';

@JsonSerializable()
class Ping {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'status', unknownEnumValue: Status.$unknown)
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
class Cat {
  @JsonKey(name: 'meow')
  final bool? meow;

  const Cat({
    this.meow,
  });

  Cat copyWith({
    bool? meow,
  }) {
    return Cat(
      meow: meow ?? this.meow,
    );
  }

  factory Cat.fromJson(Map<String, dynamic> json) =>
      _$CatFromJson(json);

  Map<String, dynamic> toJson() => _$CatToJson(this);
}

@JsonSerializable()
class Nullable30 {
  @JsonKey(name: 'plain')
  final String? plain;
  @JsonKey(name: 'refSibling')
  final Cat? refSibling;
  @JsonKey(name: 'wrapped')
  final Cat? wrapped;
  @JsonKey(name: 'anyOfNull')
  final Cat? anyOfNull;

  const Nullable30({
    this.plain,
    this.refSibling,
    this.wrapped,
    this.anyOfNull,
  });

  Nullable30 copyWith({
    String? plain,
    Cat? refSibling,
    Cat? wrapped,
    Cat? anyOfNull,
  }) {
    return Nullable30(
      plain: plain ?? this.plain,
      refSibling: refSibling ?? this.refSibling,
      wrapped: wrapped ?? this.wrapped,
      anyOfNull: anyOfNull ?? this.anyOfNull,
    );
  }

  factory Nullable30.fromJson(Map<String, dynamic> json) =>
      _$Nullable30FromJson(json);

  Map<String, dynamic> toJson() => _$Nullable30ToJson(this);
}

@JsonSerializable()
class Base {
  @JsonKey(name: 'id')
  final String id;

  const Base({
    required this.id,
  });

  Base copyWith({
    String? id,
  }) {
    return Base(
      id: id ?? this.id,
    );
  }

  factory Base.fromJson(Map<String, dynamic> json) =>
      _$BaseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseToJson(this);
}

@JsonSerializable()
class Derived {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'extra')
  final String? extra;

  const Derived({
    required this.id,
    this.extra,
  });

  Derived copyWith({
    String? id,
    String? extra,
  }) {
    return Derived(
      id: id ?? this.id,
      extra: extra ?? this.extra,
    );
  }

  factory Derived.fromJson(Map<String, dynamic> json) =>
      _$DerivedFromJson(json);

  Map<String, dynamic> toJson() => _$DerivedToJson(this);
}

@JsonSerializable()
class Tree {
  @JsonKey(name: 'children')
  final List<Tree>? children;

  const Tree({
    this.children,
  });

  Tree copyWith({
    List<Tree>? children,
  }) {
    return Tree(
      children: children ?? this.children,
    );
  }

  factory Tree.fromJson(Map<String, dynamic> json) =>
      _$TreeFromJson(json);

  Map<String, dynamic> toJson() => _$TreeToJson(this);
}

