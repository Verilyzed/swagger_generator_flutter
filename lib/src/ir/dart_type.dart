/// A resolved Dart type with nullability.
class DartType {
  final String name;
  final bool isNullable;
  final bool isDateOnly;

  const DartType(
    this.name, {
    this.isNullable = false,
    this.isDateOnly = false,
  });

  String get display => isNullable ? '$name?' : name;
}
