/// Shared helpers for emitting Dart source files.
class SourceWriter {
  static String header() =>
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n\n';

  static String importLine(String uri) => "import '$uri';";

  /// A single-quoted Dart string literal for [value], escaping the characters
  /// that would otherwise break the literal (backslash, quote, `$`, newlines).
  static String dartString(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
    return "'$escaped'";
  }
}
