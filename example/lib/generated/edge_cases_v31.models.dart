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

@JsonSerializable()
class ThreeOneConstructs {
  final List<dynamic>? tuple;
  final dynamic constField;
  final String? constTyped;
  final dynamic emptySchema;
  final String? exampledField;

  const ThreeOneConstructs({
    this.tuple,
    required this.constField,
    this.constTyped,
    required this.emptySchema,
    this.exampledField,
  });

  ThreeOneConstructs copyWith({
    List<dynamic>? tuple,
    dynamic constField,
    String? constTyped,
    dynamic emptySchema,
    String? exampledField,
  }) {
    return ThreeOneConstructs(
      tuple: tuple ?? this.tuple,
      constField: constField ?? this.constField,
      constTyped: constTyped ?? this.constTyped,
      emptySchema: emptySchema ?? this.emptySchema,
      exampledField: exampledField ?? this.exampledField,
    );
  }

  factory ThreeOneConstructs.fromJson(Map<String, dynamic> json) =>
      _$ThreeOneConstructsFromJson(json);

  Map<String, dynamic> toJson() => _$ThreeOneConstructsToJson(this);
}

@JsonSerializable()
class Cat {
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
class Dog {
  final bool? bark;

  const Dog({
    this.bark,
  });

  Dog copyWith({
    bool? bark,
  }) {
    return Dog(
      bark: bark ?? this.bark,
    );
  }

  factory Dog.fromJson(Map<String, dynamic> json) =>
      _$DogFromJson(json);

  Map<String, dynamic> toJson() => _$DogToJson(this);
}

@JsonSerializable()
class Base {
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
  final String id;
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
class Holder {
  final dynamic pet;
  final Derived? derived;

  const Holder({
    required this.pet,
    this.derived,
  });

  Holder copyWith({
    dynamic pet,
    Derived? derived,
  }) {
    return Holder(
      pet: pet ?? this.pet,
      derived: derived ?? this.derived,
    );
  }

  factory Holder.fromJson(Map<String, dynamic> json) =>
      _$HolderFromJson(json);

  Map<String, dynamic> toJson() => _$HolderToJson(this);
}

@JsonSerializable()
class MapAndProps {
  final String? name;

  const MapAndProps({
    this.name,
  });

  MapAndProps copyWith({
    String? name,
  }) {
    return MapAndProps(
      name: name ?? this.name,
    );
  }

  factory MapAndProps.fromJson(Map<String, dynamic> json) =>
      _$MapAndPropsFromJson(json);

  Map<String, dynamic> toJson() => _$MapAndPropsToJson(this);
}

@JsonSerializable()
class FreeMapTrue {

  const FreeMapTrue();

  FreeMapTrue copyWith() => FreeMapTrue();

  factory FreeMapTrue.fromJson(Map<String, dynamic> json) =>
      _$FreeMapTrueFromJson(json);

  Map<String, dynamic> toJson() => _$FreeMapTrueToJson(this);
}

@JsonSerializable()
class FreeMapFalse {

  const FreeMapFalse();

  FreeMapFalse copyWith() => FreeMapFalse();

  factory FreeMapFalse.fromJson(Map<String, dynamic> json) =>
      _$FreeMapFalseFromJson(json);

  Map<String, dynamic> toJson() => _$FreeMapFalseToJson(this);
}

@JsonSerializable()
class Nested {
  final List<dynamic>? untypedArray;
  final List<List<String>>? arrayOfArrays;
  final Map<String, List<Map<String, String>>>? deep;

  const Nested({
    this.untypedArray,
    this.arrayOfArrays,
    this.deep,
  });

  Nested copyWith({
    List<dynamic>? untypedArray,
    List<List<String>>? arrayOfArrays,
    Map<String, List<Map<String, String>>>? deep,
  }) {
    return Nested(
      untypedArray: untypedArray ?? this.untypedArray,
      arrayOfArrays: arrayOfArrays ?? this.arrayOfArrays,
      deep: deep ?? this.deep,
    );
  }

  factory Nested.fromJson(Map<String, dynamic> json) =>
      _$NestedFromJson(json);

  Map<String, dynamic> toJson() => _$NestedToJson(this);
}

@JsonSerializable()
class Tree {
  final String? value;
  final List<Tree>? children;

  const Tree({
    this.value,
    this.children,
  });

  Tree copyWith({
    String? value,
    List<Tree>? children,
  }) {
    return Tree(
      value: value ?? this.value,
      children: children ?? this.children,
    );
  }

  factory Tree.fromJson(Map<String, dynamic> json) =>
      _$TreeFromJson(json);

  Map<String, dynamic> toJson() => _$TreeToJson(this);
}

@JsonSerializable()
class NodeA {
  final NodeB? b;

  const NodeA({
    this.b,
  });

  NodeA copyWith({
    NodeB? b,
  }) {
    return NodeA(
      b: b ?? this.b,
    );
  }

  factory NodeA.fromJson(Map<String, dynamic> json) =>
      _$NodeAFromJson(json);

  Map<String, dynamic> toJson() => _$NodeAToJson(this);
}

@JsonSerializable()
class NodeB {
  final NodeA? a;

  const NodeB({
    this.a,
  });

  NodeB copyWith({
    NodeA? a,
  }) {
    return NodeB(
      a: a ?? this.a,
    );
  }

  factory NodeB.fromJson(Map<String, dynamic> json) =>
      _$NodeBFromJson(json);

  Map<String, dynamic> toJson() => _$NodeBToJson(this);
}

