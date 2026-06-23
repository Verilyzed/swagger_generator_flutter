import 'dart:convert';

import '../resolve/name_giver.dart';

/// Lifts inline (anonymous) object and enum schemas into named entries under
/// `components/schemas`, replacing each in place with a `$ref`. The rest of the
/// pipeline then treats them like any other named schema.
class SchemaHoister {
  final NameGiver _names;

  SchemaHoister(this._names);

  Map<String, dynamic> hoist(Map<String, dynamic> spec) {
    final copy = (jsonDecode(jsonEncode(spec)) as Map).cast<String, dynamic>();

    final components =
        (copy['components'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    final schemas =
        (components['schemas'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
    components['schemas'] = schemas;
    copy['components'] = components;

    final used = schemas.keys.toSet();

    for (final key in schemas.keys.toList()) {
      final schema = schemas[key];
      if (schema is Map<String, dynamic>) {
        _hoistChildren(schema, key, schemas, used);
      }
    }

    final paths = (copy['paths'] as Map?)?.cast<String, dynamic>();
    if (paths != null) {
      for (final pathItem in paths.values) {
        if (pathItem is! Map) continue;
        for (final op in pathItem.values) {
          if (op is Map) {
            _hoistOperation(op.cast<String, dynamic>(), schemas, used);
          }
        }
      }
    }

    return copy;
  }

  void _hoistOperation(
    Map<String, dynamic> op,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final opId = (op['operationId'] as String?) ?? 'operation';

    final requestBody = op['requestBody'];
    if (requestBody is Map) {
      _hoistContent(
        requestBody.cast<String, dynamic>(),
        '$opId request',
        schemas,
        used,
      );
    }

    final responses = op['responses'];
    if (responses is Map) {
      for (final response in responses.values) {
        if (response is Map) {
          _hoistContent(
            response.cast<String, dynamic>(),
            '$opId response',
            schemas,
            used,
          );
        }
      }
    }
  }

  void _hoistContent(
    Map<String, dynamic> container,
    String name,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final content = container['content'];
    if (content is! Map) return;
    for (final media in content.values) {
      if (media is! Map) continue;
      final mediaMap = media.cast<String, dynamic>();
      final schema = mediaMap['schema'];
      if (schema is Map) {
        mediaMap['schema'] = _hoistType(
          schema.cast<String, dynamic>(),
          name,
          schemas,
          used,
        );
      }
    }
  }

  dynamic _hoistType(
    Map<String, dynamic> schema,
    String name,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    if (schema.containsKey(r'$ref')) return schema;

    _hoistChildren(schema, name, schemas, used);

    final isObject = schema['properties'] is Map;
    final isEnum = schema['enum'] is List;
    if (!isObject && !isEnum) return schema;

    final key = _uniqueName(name, used);
    final defaultValue = schema.remove('default');
    schemas[key] = schema;
    final ref = <String, dynamic>{r'$ref': '#/components/schemas/$key'};
    if (defaultValue != null) ref['default'] = defaultValue;
    return ref;
  }

  void _hoistChildren(
    Map<String, dynamic> schema,
    String name,
    Map<String, dynamic> schemas,
    Set<String> used,
  ) {
    final properties = schema['properties'];
    if (properties is Map) {
      final props = properties.cast<String, dynamic>();
      for (final key in props.keys.toList()) {
        final value = props[key];
        if (value is Map) {
          props[key] = _hoistType(
            value.cast<String, dynamic>(),
            '$name $key',
            schemas,
            used,
          );
        }
      }
    }

    final items = schema['items'];
    if (items is Map) {
      schema['items'] = _hoistType(
        items.cast<String, dynamic>(),
        '$name item',
        schemas,
        used,
      );
    }

    final allOf = schema['allOf'];
    if (allOf is List) {
      for (final member in allOf) {
        if (member is Map) {
          _hoistChildren(member.cast<String, dynamic>(), name, schemas, used);
        }
      }
    }
  }

  String _uniqueName(String rawName, Set<String> used) {
    final base = _names.className(rawName);
    var name = base;
    var counter = 2;
    while (used.contains(name)) {
      name = '$base$counter';
      counter++;
    }
    used.add(name);
    return name;
  }
}
