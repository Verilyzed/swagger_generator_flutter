import '../ir/dart_type.dart';
import 'name_giver.dart';

/// Maps an OpenAPI schema node to a Dart type.
class DartTypeResolver {
  final NameGiver _names;

  DartTypeResolver(this._names);

  DartType resolve(Map<String, dynamic> schema) {
    final ref = schema[r'$ref'];
    if (ref is String) {
      return DartType(_names.className(ref.split('/').last));
    }

    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      final nonNull = anyOf
          .cast<Map<String, dynamic>>()
          .where((s) => s['type'] != 'null')
          .toList();
      final hasNull = anyOf.any((s) => (s as Map)['type'] == 'null');
      if (nonNull.length == 1) {
        final inner = resolve(nonNull.single);
        return DartType(inner.name, isNullable: hasNull || inner.isNullable);
      }
      return DartType('dynamic', isNullable: hasNull);
    }

    final type = schema['type'];
    switch (type) {
      case 'string':
        return schema['format'] == 'date-time'
            ? const DartType('DateTime')
            : const DartType('String');
      case 'integer':
        return const DartType('int');
      case 'number':
        return const DartType('double');
      case 'boolean':
        return const DartType('bool');
      case 'array':
        final items = schema['items'];
        final inner = items is Map<String, dynamic>
            ? resolve(items)
            : const DartType('dynamic');
        return DartType('List<${inner.display}>');
      default:
        return const DartType('dynamic');
    }
  }
}
