import '../ir/dart_type.dart';

/// Emits typed decoders for response types the generic converter cannot build
/// from decoded JSON on its own (maps, lists of non-models, enums, `DateTime`,
/// `double`). The converter looks them up by the response's runtime type.
class ResponseDecoderEmitter {
  final Set<String> _models;
  final Set<String> _enums;
  final Map<String, String> _typedefs;

  ResponseDecoderEmitter({
    required Set<String> models,
    required Set<String> enums,
    Map<String, String> typedefs = const {},
  }) : _models = models,
       _enums = enums,
       _typedefs = typedefs;

  static const _passThrough = {'dynamic', 'Object', 'String', 'int', 'bool'};

  /// Top-level decoder functions plus a `_responseDecoders` map, or an empty
  /// string when no response type needs one.
  String emit(List<DartType> responseTypes) {
    final keys = <String, String>{};
    for (final type in responseTypes) {
      if (type.isNullable || !_needsDecoder(type.name)) continue;
      keys.putIfAbsent(_expand(type.name), () => type.name);
    }
    if (keys.isEmpty) return '';

    final buffer = StringBuffer();
    final names = <String, String>{};
    var index = 0;
    for (final entry in keys.entries) {
      final fn = '_decodeResponse${index++}';
      names[entry.value] = fn;
      buffer
        ..writeln('Object? $fn(Object? json) =>')
        ..writeln('    ${_expression(entry.key, 'json', 0)};')
        ..writeln();
    }
    buffer.writeln(
      'const _responseDecoders = <Type, Object? Function(Object?)>{',
    );
    for (final entry in names.entries) {
      buffer.writeln('  ${entry.key}: ${entry.value},');
    }
    buffer
      ..writeln('};')
      ..writeln();
    return buffer.toString();
  }

  bool _needsDecoder(String type) {
    final expanded = _alias(type);
    if (_passThrough.contains(expanded) || _models.contains(expanded)) {
      return false;
    }
    final (name, args) = _parse(expanded);
    return !(name == 'List' && _models.contains(_alias(args.single)));
  }

  String _expression(String type, String value, int depth) {
    if (type.endsWith('?')) {
      final inner = type.substring(0, type.length - 1);
      return '$value == null ? null : ${_expression(inner, value, depth)}';
    }
    final aliased = _typedefs[type];
    if (aliased != null) return _expression(aliased, value, depth);

    final (name, args) = _parse(type);
    if (name == 'List') {
      final e = 'e$depth';
      return '($value as List).map(($e) => '
          '${_expression(args.single, e, depth + 1)}).toList()';
    }
    if (name == 'Map') {
      final k = 'k$depth';
      final e = 'e$depth';
      // JSON object keys are already strings; only an enum key is converted.
      final key = args.first == 'String'
          ? k
          : _expression(args.first, k, depth + 1);
      return '($value as Map<String, dynamic>).map(($k, $e) => MapEntry('
          '$key, '
          '${_expression(args.last, e, depth + 1)}))';
    }
    if (name == 'dynamic' || name == 'Object') return value;
    if (name == 'double') return '($value as num).toDouble()';
    if (name == 'DateTime') return 'DateTime.parse($value as String)';
    if (_enums.contains(name)) {
      return "$name.values.firstWhere((v) => v.toString() == '\$$value', "
          'orElse: () => $name.\$unknown)';
    }
    if (_models.contains(name)) {
      return '$name.fromJson($value as Map<String, dynamic>)';
    }
    return '$value as $name';
  }

  String _alias(String type) => _typedefs[type] ?? type;

  /// Fully expands typedefs, so aliases of the same runtime type share a key.
  String _expand(String type) {
    final nullable = type.endsWith('?');
    final base = nullable ? type.substring(0, type.length - 1) : type;
    final (name, args) = _parse(_alias(base));
    final expanded = args.isEmpty
        ? name
        : '$name<${args.map(_expand).join(', ')}>';
    return nullable ? '$expanded?' : expanded;
  }

  /// Splits `Name<A, B<C>>` into `Name` and its top-level type arguments.
  (String, List<String>) _parse(String type) {
    final open = type.indexOf('<');
    if (open < 0) return (type, const []);
    final args = <String>[];
    var depth = 0;
    var start = open + 1;
    for (var i = start; i < type.length - 1; i++) {
      final c = type[i];
      if (c == '<') depth++;
      if (c == '>') depth--;
      if (c == ',' && depth == 0) {
        args.add(type.substring(start, i).trim());
        start = i + 1;
      }
    }
    args.add(type.substring(start, type.length - 1).trim());
    return (type.substring(0, open), args);
  }
}
