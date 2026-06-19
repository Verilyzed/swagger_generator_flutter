/// A resolved Dart type with nullability.
class DartType {
  final String name;
  final bool isNullable;

  const DartType(this.name, {this.isNullable = false});

  String get display => isNullable ? '$name?' : name;
}
