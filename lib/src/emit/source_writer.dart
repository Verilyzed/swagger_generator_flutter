/// Shared helpers for emitting Dart source files.
class SourceWriter {
  static String header() =>
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n\n';

  static String importLine(String uri) => "import '$uri';";
}
