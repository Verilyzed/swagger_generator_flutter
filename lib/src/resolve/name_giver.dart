const _reserved = {
  'abstract', 'else', 'import', 'super', 'as', 'enum', 'in', 'switch',
  'assert', 'export', 'interface', 'sync', 'async', 'extends', 'is', 'this',
  'await', 'extension', 'late', 'throw', 'break', 'external', 'library',
  'true', 'case', 'factory', 'mixin', 'try', 'catch', 'false', 'new',
  'typedef', 'class', 'final', 'null', 'var', 'const', 'finally', 'on',
  'void', 'continue', 'for', 'operator', 'while', 'covariant', 'function',
  'part', 'with', 'default', 'get', 'required', 'yield', 'deferred', 'hide',
  'rethrow', 'do', 'if', 'return', 'dynamic', 'implements', 'set', 'show',
  'static',
};

const _chopperTypeNames = {
  'Field', 'Part', 'PartFile', 'Header', 'Body', 'Query', 'QueryMap',
  'Path', 'Response', 'Request', 'Tag', 'Method', 'Converter', 'Interceptor',
};

/// Produces valid Dart identifiers from arbitrary OpenAPI names.
class NameGiver {
  String className(String raw) {
    final name = _words(raw).map(_capitalize).join();
    return _chopperTypeNames.contains(name) ? '${name}Model' : name;
  }

  String memberName(String raw) {
    final parts = _words(raw);
    if (parts.isEmpty) return '_';
    final head = parts.first.toLowerCase();
    final tail = parts.skip(1).map(_capitalize).join();
    final name = '$head$tail';
    return _reserved.contains(name) ? '${name}_' : name;
  }

  String enumValueName(String raw) {
    final name = memberName(raw);
    return RegExp(r'^[0-9]').hasMatch(name) ? '\$$name' : name;
  }

  List<String> _words(String raw) {
    final spaced = raw
        .replaceAllMapped(
          RegExp('([A-Z]+)([A-Z][a-z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAllMapped(
          RegExp('([a-z0-9])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAll(RegExp('[^a-zA-Z0-9]+'), ' ');
    return spaced
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  String _capitalize(String w) =>
      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
}
