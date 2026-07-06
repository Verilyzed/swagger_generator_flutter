/// A resolved Dart type with nullability.
class DartType {
  final String name;
  final bool isNullable;

  const DartType(this.name, {this.isNullable = false});

  // `dynamic` is already nullable, so it never takes a `?` suffix.
  String get display =>
      isNullable && name != 'dynamic' ? '$name?' : name;
}
