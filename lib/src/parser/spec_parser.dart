import '../ir/api_spec.dart';
import '../ir/dart_type.dart';
import '../resolve/dart_type_resolver.dart';
import '../resolve/name_giver.dart';
import 'operation_name.dart';

const _httpMethods = {
  'get',
  'put',
  'post',
  'delete',
  'options',
  'head',
  'patch',
  'trace',
};

/// Turns a loaded OpenAPI map into the [ApiSpec] IR.
class SpecParser {
  final NameGiver _names;
  final DartTypeResolver _resolver;
  final bool _nameFromPath;
  final Set<String> _overrideSchemas;
  final DartType _filePartType;
  final bool _allOfNested;
  final Set<String> _allOfExceptions;

  SpecParser(
    this._names,
    this._resolver, {
    bool nameFromPath = false,
    Set<String> overrideSchemas = const {},
    DartType filePartType = const DartType('MultipartFile'),
    bool allOfNested = false,
    Set<String> allOfExceptions = const {},
  }) : _nameFromPath = nameFromPath,
       _overrideSchemas = overrideSchemas,
       _filePartType = filePartType,
       _allOfNested = allOfNested,
       _allOfExceptions = allOfExceptions;

  Map<String, dynamic> _schemasCache = const {};

  ApiSpec parse(Map<String, dynamic> spec, {required String name}) {
    final schemas = _schemas(spec);
    _schemasCache = schemas;
    final enums = <EnumDef>[];
    final models = <ModelDef>[];
    final typedefs = <TypedefDef>[];

    // Collect enum Dart names first so model field defaults can reference them.
    final enumNames = <String>{};
    for (final entry in schemas.entries) {
      if (_overrideSchemas.contains(entry.key)) continue;
      final schema = entry.value;
      if (schema is Map<String, dynamic> && schema['enum'] is List) {
        enumNames.add(_names.className(entry.key));
      }
    }

    for (final entry in schemas.entries) {
      if (_overrideSchemas.contains(entry.key)) continue;
      final schema = entry.value;
      if (schema is! Map<String, dynamic>) continue;
      if (schema['enum'] is List) {
        enums.add(_enum(entry.key, schema));
      } else if (schema['allOf'] is List ||
          schema['type'] == 'object' ||
          schema['properties'] is Map) {
        models.add(_model(entry.key, schema, enumNames: enumNames));
      } else if (schema['type'] == 'array') {
        // A named array schema becomes a typedef. The alias type is the
        // non-nullable base (`List<...>`); nullability is applied where it is
        // referenced.
        typedefs.add(
          TypedefDef(
            name: _names.className(entry.key),
            aliasType: DartType(_resolver.resolve(schema).name),
          ),
        );
      }
    }

    return ApiSpec(
      name: name,
      enums: enums,
      models: models,
      service: _service(spec, name, enumNames),
      typedefs: typedefs,
    );
  }

  Map<String, dynamic> _schemas(Map<String, dynamic> spec) {
    final components = spec['components'];
    if (components is! Map) return {};
    final schemas = components['schemas'];
    return schemas is Map ? schemas.cast<String, dynamic>() : {};
  }

  EnumDef _enum(String rawName, Map<String, dynamic> schema) {
    final values = (schema['enum'] as List)
        .map(
          (v) => EnumValueDef(
            dartName: _names.enumValueName(v.toString()),
            jsonValue: v.toString(),
          ),
        )
        .toList();
    return EnumDef(name: _names.className(rawName), values: values);
  }

  ModelDef _model(
    String rawName,
    Map<String, dynamic> schema, {
    required Set<String> enumNames,
  }) {
    // A `$ref` alongside local keywords is an implicit `allOf` in OpenAPI 3.1
    // (JSON Schema 2020-12): the referenced schema and the inline object both
    // apply. Normalize it so it takes the same path as an explicit `allOf`.
    final ref = schema[r'$ref'];
    if (ref is String && schema['properties'] is Map) {
      final sibling = Map<String, dynamic>.from(schema)
        ..remove(r'$ref')
        ..remove(_sourceOperationKey);
      final normalized = <String, dynamic>{
        'allOf': [
          {r'$ref': ref},
          sibling,
        ],
      };
      final opId = schema[_sourceOperationKey];
      if (opId != null) normalized[_sourceOperationKey] = opId;
      return _model(rawName, normalized, enumNames: enumNames);
    }

    final allOf = schema['allOf'];
    if (allOf is List &&
        _allRefsAreObjects(allOf) &&
        _useNested(rawName, schema)) {
      return _allOfModel(rawName, allOf, enumNames: enumNames);
    }

    final merged = _mergedObject(schema);
    final required = merged.required;
    final properties = merged.properties;
    final fields = <FieldDef>[];
    final usedNames = <String>{};

    for (final entry in properties.entries) {
      fields.add(
        _fieldFor(
          entry.key,
          (entry.value as Map).cast<String, dynamic>(),
          isRequired: required.contains(entry.key),
          enumNames: enumNames,
          usedNames: usedNames,
        ),
      );
    }

    return ModelDef(name: _names.className(rawName), fields: fields);
  }

  /// Builds a model from an `allOf` where each `$ref` member becomes its own
  /// nested field (spread into the parent JSON) and each inline object member
  /// contributes its properties directly.
  ModelDef _allOfModel(
    String rawName,
    List<dynamic> allOf, {
    required Set<String> enumNames,
  }) {
    final fields = <FieldDef>[];
    final usedNames = <String>{};

    for (final raw in allOf) {
      if (raw is! Map) continue;
      final member = raw.cast<String, dynamic>();
      final ref = member[r'$ref'];
      if (ref is String) {
        final refName = ref.split('/').last;
        final dartName = _uniqueName(_names.memberName(refName), usedNames);
        fields.add(
          FieldDef(
            dartName: dartName,
            jsonKey: dartName,
            type: DartType(_names.className(refName)),
            isRequired: true,
            spreadFromParent: true,
          ),
        );
        continue;
      }
      final properties =
          (member['properties'] as Map?)?.cast<String, dynamic>() ?? const {};
      final required =
          (member['required'] as List?)?.cast<String>() ?? const <String>[];
      for (final entry in properties.entries) {
        fields.add(
          _fieldFor(
            entry.key,
            (entry.value as Map).cast<String, dynamic>(),
            isRequired: required.contains(entry.key),
            enumNames: enumNames,
            usedNames: usedNames,
          ),
        );
      }
    }

    return ModelDef(name: _names.className(rawName), fields: fields);
  }

  FieldDef _fieldFor(
    String jsonKey,
    Map<String, dynamic> propSchema, {
    required bool isRequired,
    required Set<String> enumNames,
    required Set<String> usedNames,
  }) {
    final type = _resolver.resolve(propSchema);
    final defaultValue = _defaultLiteral(
      propSchema['default'],
      typeName: type.name,
      enumNames: enumNames,
    );
    // An OpenAPI property that is not required may be absent from the
    // payload, so it is optional and nullable in Dart unless it has a
    // default.
    final fieldType =
        !isRequired &&
            defaultValue == null &&
            !type.isNullable &&
            type.name != 'dynamic'
        ? DartType(type.name, isNullable: true)
        : type;
    return FieldDef(
      dartName: _uniqueName(_names.memberName(jsonKey), usedNames),
      jsonKey: jsonKey,
      type: fieldType,
      isRequired: isRequired,
      defaultValue: defaultValue,
    );
  }

  /// Internal marker the hoister stamps on operation-derived schemas so
  /// [_allOfExceptions] can match by operationId.
  static const _sourceOperationKey = 'x-source-operation-id';

  /// Whether an `allOf` model keeps referenced schemas as nested fields.
  /// The global [_allOfNested] mode applies, flipped for any model whose schema
  /// name, class name, or source operationId matches an [_allOfExceptions]
  /// pattern (case-insensitive, `*`/`?` glob wildcards).
  bool _useNested(String rawName, Map<String, dynamic> schema) {
    final matched = _matchesAllOfException(rawName, schema);
    return matched ? !_allOfNested : _allOfNested;
  }

  bool _matchesAllOfException(String rawName, Map<String, dynamic> schema) {
    if (_allOfExceptions.isEmpty) return false;
    final ids = <String>{rawName, _names.className(rawName)};
    final opId = schema[_sourceOperationKey];
    if (opId is String) ids.add(opId);
    for (final pattern in _allOfExceptions) {
      final re = _globToRegExp(pattern);
      if (ids.any(re.hasMatch)) return true;
    }
    return false;
  }

  static RegExp _globToRegExp(String pattern) {
    final buffer = StringBuffer('^');
    for (final ch in pattern.split('')) {
      if (ch == '*') {
        buffer.write('.*');
      } else if (ch == '?') {
        buffer.write('.');
      } else {
        buffer.write(RegExp.escape(ch));
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString(), caseSensitive: false);
  }

  /// Whether every `$ref` member of an `allOf` targets an object-like schema
  /// (object, `allOf`, or one with `properties`). When a member points at a
  /// non-object (e.g. an enum), the nested-field form does not apply and the
  /// caller falls back to flattening.
  bool _allRefsAreObjects(List<dynamic> allOf) {
    for (final raw in allOf) {
      if (raw is! Map) continue;
      final ref = raw[r'$ref'];
      if (ref is! String) continue;
      final target = _schemasCache[ref.split('/').last];
      final isObject =
          target is Map<String, dynamic> &&
          (target['allOf'] is List ||
              target['type'] == 'object' ||
              target['properties'] is Map);
      if (!isObject) return false;
    }
    return true;
  }

  String _uniqueName(String base, Set<String> used) {
    var name = base;
    var counter = 2;
    while (used.contains(name)) {
      name = '$base$counter';
      counter++;
    }
    used.add(name);
    return name;
  }

  ({Map<String, dynamic> properties, List<String> required}) _mergedObject(
    Map<String, dynamic> schema,
  ) {
    final allOf = schema['allOf'];
    if (allOf is! List) {
      return (
        properties:
            (schema['properties'] as Map?)?.cast<String, dynamic>() ?? const {},
        required:
            (schema['required'] as List?)?.cast<String>() ?? const <String>[],
      );
    }

    final properties = <String, dynamic>{};
    final required = <String>[];
    for (final raw in allOf) {
      if (raw is! Map) continue;
      var member = raw.cast<String, dynamic>();
      final ref = member[r'$ref'];
      if (ref is String) {
        final target = _schemasCache[ref.split('/').last];
        if (target is Map<String, dynamic>) member = target;
      }
      properties.addAll(
        (member['properties'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
      required.addAll(
        (member['required'] as List?)?.cast<String>() ?? const <String>[],
      );
    }
    return (properties: properties, required: required);
  }

  // A binary file part: 3.0 uses `format: binary`; 3.1 uses `contentMediaType`
  // or `contentEncoding` on a string schema.
  bool _isFilePart(Map<String, dynamic> schema) =>
      schema['type'] == 'string' &&
      (schema['format'] == 'binary' ||
          schema.containsKey('contentMediaType') ||
          schema.containsKey('contentEncoding'));

  ({Map<String, dynamic> properties, List<String> required}) _objectFor(
    Map<String, dynamic> schema,
  ) {
    final ref = schema[r'$ref'];
    if (ref is String) {
      final target = _schemasCache[ref.split('/').last];
      if (target is Map<String, dynamic>) return _mergedObject(target);
    }
    return _mergedObject(schema);
  }

  String? _defaultLiteral(
    dynamic value, {
    String? typeName,
    Set<String> enumNames = const {},
  }) {
    if (value is String) {
      if (typeName != null && enumNames.contains(typeName)) {
        return '$typeName.${_names.enumValueName(value)}';
      }
      return "'$value'";
    }
    if (value is num || value is bool) return value.toString();
    return null;
  }

  ServiceDef _service(
    Map<String, dynamic> spec,
    String name,
    Set<String> enumNames,
  ) {
    final paths = (spec['paths'] as Map?)?.cast<String, dynamic>() ?? const {};
    final operations = <OperationDef>[];

    for (final pathEntry in paths.entries) {
      final methods = (pathEntry.value as Map).cast<String, dynamic>();
      for (final methodEntry in methods.entries) {
        if (!_httpMethods.contains(methodEntry.key.toLowerCase())) continue;
        final op = (methodEntry.value as Map).cast<String, dynamic>();
        operations.add(
          _operation(
            path: pathEntry.key,
            httpMethod: methodEntry.key.toUpperCase(),
            op: op,
            enumNames: enumNames,
          ),
        );
      }
    }

    return ServiceDef(
      name: _names.className('$name service'),
      operations: operations,
    );
  }

  OperationDef _operation({
    required String path,
    required String httpMethod,
    required Map<String, dynamic> op,
    required Set<String> enumNames,
  }) {
    final params = <ParamDef>[];
    for (final raw in (op['parameters'] as List?) ?? const []) {
      final p = (raw as Map).cast<String, dynamic>();
      final isPath = p['in'] == 'path';
      final schema = p['schema'] is Map
          ? (p['schema'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      final type = _resolver.resolve(schema);
      params.add(
        ParamDef(
          dartName: _names.memberName(p['name'] as String),
          wireName: p['name'] as String,
          type: type,
          location: isPath ? ParamLocation.path : ParamLocation.query,
          isRequired: isPath || p['required'] == true,
          defaultValue: _defaultLiteral(
            schema['default'],
            typeName: type.name,
            enumNames: enumNames,
          ),
        ),
      );
    }

    DartType? bodyType;
    final body = op['requestBody'];
    final bodyMap = body is Map ? body.cast<String, dynamic>() : null;
    final content = (bodyMap?['content'] as Map?)?.cast<String, dynamic>();
    final multipart = (content?['multipart/form-data'] as Map?)
        ?.cast<String, dynamic>();
    if (multipart != null) {
      final schema = multipart['schema'];
      if (schema is Map) {
        final object = _objectFor(schema.cast<String, dynamic>());
        for (final entry in object.properties.entries) {
          final propSchema = (entry.value as Map).cast<String, dynamic>();
          final isFile = _isFilePart(propSchema);
          params.add(
            ParamDef(
              dartName: _names.memberName(entry.key),
              wireName: entry.key,
              type: isFile ? _filePartType : _resolver.resolve(propSchema),
              location: isFile ? ParamLocation.partFile : ParamLocation.part,
              isRequired: object.required.contains(entry.key),
            ),
          );
        }
      }
    } else {
      final bodySchema = _contentSchema(bodyMap);
      if (bodySchema != null) {
        bodyType = _resolver.resolve(bodySchema);
        params.add(
          ParamDef(
            dartName: 'body',
            wireName: 'body',
            type: bodyType,
            location: ParamLocation.body,
            isRequired: bodyMap?['required'] == true,
          ),
        );
      }
    }

    final responseSchema = _responseSchema(
      (op['responses'] as Map?)?.cast<String, dynamic>(),
    );
    final responseType = responseSchema == null
        ? const DartType('dynamic')
        : _resolver.resolve(responseSchema);

    return OperationDef(
      methodName: _names.memberName(
        operationBaseName(
          httpMethod: httpMethod,
          path: path,
          operationId: op['operationId'] as String?,
          nameFromPath: _nameFromPath,
        ),
      ),
      httpMethod: httpMethod,
      path: path,
      parameters: params,
      requestBodyType: bodyType,
      responseType: responseType,
    );
  }

  /// The schema of the response the client returns: the first success (2xx)
  /// response that carries a content schema, preferring numeric codes in
  /// ascending order (so `200` wins over `201`), then a `2XX` range, then
  /// `default`.
  Map<String, dynamic>? _responseSchema(Map<String, dynamic>? responses) {
    if (responses == null) return null;
    final successCodes =
        responses.keys
            .where((k) => k.startsWith('2') && int.tryParse(k) != null)
            .toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    for (final code in [...successCodes, '2XX', '2xx', 'default']) {
      final schema = _contentSchema(
        (responses[code] as Map?)?.cast<String, dynamic>(),
      );
      if (schema != null) return schema;
    }
    return null;
  }

  Map<String, dynamic>? _contentSchema(Map<String, dynamic>? container) {
    final content = (container?['content'] as Map?)?.cast<String, dynamic>();
    if (content == null || content.isEmpty) return null;
    final media = content['application/json'] ?? content.values.first;
    final schema = (media as Map?)?['schema'];
    return schema is Map ? schema.cast<String, dynamic>() : null;
  }
}
