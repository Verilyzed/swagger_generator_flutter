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

  SpecParser(
    this._names,
    this._resolver, {
    bool nameFromPath = false,
    Set<String> overrideSchemas = const {},
    DartType filePartType = const DartType('MultipartFile'),
  })  : _nameFromPath = nameFromPath,
        _overrideSchemas = overrideSchemas,
        _filePartType = filePartType;

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
        models.add(_model(
          entry.key,
          schema,
          enumNames: enumNames,
        ));
      } else if (schema['type'] == 'array') {
        // A named array schema becomes a typedef. The alias type is the
        // non-nullable base (`List<...>`); nullability is applied where it is
        // referenced.
        typedefs.add(TypedefDef(
          name: _names.className(entry.key),
          aliasType: DartType(_resolver.resolve(schema).name),
        ));
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
    final merged = _mergedObject(schema);
    final required = merged.required;
    final properties = merged.properties;
    final fields = <FieldDef>[];

    for (final entry in properties.entries) {
      final propSchema = (entry.value as Map).cast<String, dynamic>();
      final type = _resolver.resolve(propSchema);
      final isRequired = required.contains(entry.key);
      final defaultValue = _defaultLiteral(
        propSchema['default'],
        typeName: type.name,
        enumNames: enumNames,
      );
      // An OpenAPI property that is not required may be absent from the
      // payload, so it is optional and nullable in Dart unless it has a
      // default.
      final fieldType = !isRequired &&
              defaultValue == null &&
              !type.isNullable &&
              type.name != 'dynamic'
          ? DartType(type.name, isNullable: true)
          : type;
      fields.add(FieldDef(
        dartName: _names.memberName(entry.key),
        jsonKey: entry.key,
        type: fieldType,
        isRequired: isRequired,
        defaultValue: defaultValue,
      ));
    }

    return ModelDef(name: _names.className(rawName), fields: fields);
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
        operations.add(_operation(
          path: pathEntry.key,
          httpMethod: methodEntry.key.toUpperCase(),
          op: op,
          enumNames: enumNames,
        ));
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
      params.add(ParamDef(
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
      ));
    }

    DartType? bodyType;
    final body = op['requestBody'];
    final bodyMap = body is Map ? body.cast<String, dynamic>() : null;
    final content = (bodyMap?['content'] as Map?)?.cast<String, dynamic>();
    final multipart =
        (content?['multipart/form-data'] as Map?)?.cast<String, dynamic>();
    if (multipart != null) {
      final schema = multipart['schema'];
      if (schema is Map) {
        final object = _objectFor(schema.cast<String, dynamic>());
        for (final entry in object.properties.entries) {
          final propSchema = (entry.value as Map).cast<String, dynamic>();
          final isFile = _isFilePart(propSchema);
          params.add(ParamDef(
            dartName: _names.memberName(entry.key),
            wireName: entry.key,
            type: isFile ? _filePartType : _resolver.resolve(propSchema),
            location: isFile ? ParamLocation.partFile : ParamLocation.part,
            isRequired: object.required.contains(entry.key),
          ));
        }
      }
    } else {
      final bodySchema = _contentSchema(bodyMap);
      if (bodySchema != null) {
        bodyType = _resolver.resolve(bodySchema);
        params.add(ParamDef(
          dartName: 'body',
          wireName: 'body',
          type: bodyType,
          location: ParamLocation.body,
          isRequired: bodyMap?['required'] == true,
        ));
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
    final successCodes = responses.keys
        .where((k) => k.startsWith('2') && int.tryParse(k) != null)
        .toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    for (final code in [...successCodes, '2XX', '2xx', 'default']) {
      final schema =
          _contentSchema((responses[code] as Map?)?.cast<String, dynamic>());
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
