import '../ir/dart_type.dart';
import 'name_giver.dart';

/// Maps an OpenAPI schema node to a Dart type. Version-specific nullability and
/// type-form handling live in the subclasses; the shared core mapping lives
/// here.
abstract class DartTypeResolver {
  final NameGiver _names;
  final Map<String, dynamic> _schemas;
  final Set<String> _overrides;

  DartTypeResolver(
    this._names, {
    Map<String, dynamic> schemas = const {},
    Set<String> overrides = const {},
  })  : _schemas = schemas,
        _overrides = overrides;

  DartType resolve(Map<String, dynamic> schema) {
    final core = coreSchema(schema);
    final nullable = isNullable(schema);
    final inner = _resolveCore(core);
    return nullable || inner.isNullable
        ? DartType(inner.name, isNullable: true, isDateOnly: inner.isDateOnly)
        : inner;
  }

  /// The non-null schema to resolve a type from (version-specific).
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema);

  /// Whether the schema is nullable (version-specific).
  bool isNullable(Map<String, dynamic> schema);

  /// The single non-null member of an `anyOf`, or `null` when the schema is not
  /// an `anyOf`. An `anyOf` without exactly one non-null member resolves to an
  /// empty schema (`dynamic`). Shared by both dialects because real 3.0 specs
  /// sometimes use `anyOf` with a `type: null` member.
  static Map<String, dynamic>? anyOfCore(Map<String, dynamic> schema) {
    final anyOf = schema['anyOf'];
    if (anyOf is! List) return null;
    final nonNull = anyOf
        .whereType<Map<dynamic, dynamic>>()
        .map(Map<String, dynamic>.from)
        .where((s) => s['type'] != 'null')
        .toList();
    return nonNull.length == 1 ? nonNull.single : const <String, dynamic>{};
  }

  static bool anyOfHasNull(Map<String, dynamic> schema) {
    final anyOf = schema['anyOf'];
    if (anyOf is! List) return false;
    return anyOf
        .whereType<Map<dynamic, dynamic>>()
        .any((e) => e['type'] == 'null');
  }

  DartType _resolveCore(Map<String, dynamic> schema) {
    final ref = schema[r'$ref'];
    if (ref is String) {
      final name = ref.split('/').last;
      if (_overrides.contains(name)) return DartType(_names.className(name));
      final target = _schemas[name];
      if (target is Map<String, dynamic> && _isAlias(target)) {
        return resolve(target);
      }
      return DartType(_names.className(name));
    }

    final allOf = schema['allOf'];
    if (allOf is List && allOf.length == 1) {
      final only = allOf.single;
      if (only is Map) return resolve(only.cast<String, dynamic>());
    }

    final type = schema['type'];
    switch (type) {
      case 'string':
        if (schema['format'] == 'date-time') return const DartType('DateTime');
        if (schema['format'] == 'date') {
          // A date carrying an example is treated as a custom string rather
          // than a DateTime.
          return schema['example'] != null
              ? const DartType('String')
              : const DartType('DateTime', isDateOnly: true);
        }
        return const DartType('String');
      case 'integer':
        return const DartType('int');
      case 'number':
        return const DartType('num');
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

  /// A named schema becomes a Dart class only when it is an object, an enum, or
  /// an `allOf`. Anything else (array, primitive) is a type alias resolved
  /// inline.
  bool _isAlias(Map<String, dynamic> schema) {
    if (schema['enum'] is List) return false;
    if (schema['allOf'] is List) return false;
    if (schema['type'] == 'object' || schema['properties'] is Map) return false;
    return true;
  }
}

/// OpenAPI 3.0: nullability via `nullable: true`.
class OpenApi30TypeResolver extends DartTypeResolver {
  OpenApi30TypeResolver(super.names, {super.schemas, super.overrides});

  @override
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema) =>
      DartTypeResolver.anyOfCore(schema) ?? schema;

  @override
  bool isNullable(Map<String, dynamic> schema) =>
      schema['nullable'] == true || DartTypeResolver.anyOfHasNull(schema);
}

/// OpenAPI 3.1: nullability via `anyOf` null or a `type` array containing null.
class OpenApi31TypeResolver extends DartTypeResolver {
  OpenApi31TypeResolver(super.names, {super.schemas, super.overrides});

  @override
  Map<String, dynamic> coreSchema(Map<String, dynamic> schema) {
    final anyOf = DartTypeResolver.anyOfCore(schema);
    if (anyOf != null) return anyOf;
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
    if (DartTypeResolver.anyOfHasNull(schema)) return true;
    final type = schema['type'];
    if (type is List) return type.contains('null');
    return false;
  }
}
