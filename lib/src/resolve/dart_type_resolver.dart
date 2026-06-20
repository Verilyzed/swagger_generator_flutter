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
      var hasNull = false;
      final nonNull = <Map<String, dynamic>>[];
      for (final entry in anyOf) {
        if (entry is Map) {
          final schema = Map<String, dynamic>.from(entry);
          if (schema['type'] == 'null') {
            hasNull = true;
          } else {
            nonNull.add(schema);
          }
        }
      }
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
      case 'object':
        final additional = schema['additionalProperties'];
        if (additional is Map) {
          final value = resolve(Map<String, dynamic>.from(additional));
          return DartType('Map<String, ${value.display}>');
        }
        return const DartType('Map<String, dynamic>');
      default:
        return const DartType('dynamic');
    }
  }
}
