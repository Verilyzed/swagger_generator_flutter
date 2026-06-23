import '../ir/dart_type.dart';
import 'name_giver.dart';

/// Maps an OpenAPI schema node to a Dart type. Version-specific nullability and
/// type-form handling live in the subclasses; the shared core mapping lives
/// here.
abstract class DartTypeResolver {
  final NameGiver _names;

  DartTypeResolver(this._names);

  DartType resolve(Map<String, dynamic> schema) {
    final core = coreSchema(schema);
    final nullable = isNullable(schema);
    final inner = _resolveCore(core);
    return nullable || inner.isNullable
        ? DartType(inner.name, isNullable: true)
        : inner;
  }

  /// The non-null schema to resolve a type from (version-specific).
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema);

  /// Whether the schema is nullable (version-specific).
  bool isNullable(Map<String, dynamic> schema);

  DartType _resolveCore(Map<String, dynamic> schema) {
    final ref = schema[r'$ref'];
    if (ref is String) {
      return DartType(_names.className(ref.split('/').last));
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

/// OpenAPI 3.0: nullability via `nullable: true`.
class OpenApi30TypeResolver extends DartTypeResolver {
  OpenApi30TypeResolver(super.names);

  @override
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema) => schema;

  @override
  bool isNullable(Map<String, dynamic> schema) => schema['nullable'] == true;
}

/// OpenAPI 3.1: nullability via `anyOf` null or a `type` array containing null.
class OpenApi31TypeResolver extends DartTypeResolver {
  OpenApi31TypeResolver(super.names);

  @override
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema) {
    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      final nonNull = anyOf
          .whereType<Map<dynamic, dynamic>>()
          .map(Map<String, dynamic>.from)
          .where((s) => s['type'] != 'null')
          .toList();
      return nonNull.length == 1 ? nonNull.single : const <String, dynamic>{};
    }
    final type = schema['type'];
    if (type is List) {
      final nonNull = type.where((t) => t != 'null').toList();
      return {
        ...schema,
        'type': nonNull.length == 1 ? nonNull.single : null,
      };
    }
    return schema;
  }

  @override
  bool isNullable(Map<String, dynamic> schema) {
    final anyOf = schema['anyOf'];
    if (anyOf is List) {
      return anyOf
          .whereType<Map<dynamic, dynamic>>()
          .any((e) => e['type'] == 'null');
    }
    final type = schema['type'];
    if (type is List) return type.contains('null');
    return false;
  }
}
