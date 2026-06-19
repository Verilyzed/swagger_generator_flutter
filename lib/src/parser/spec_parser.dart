import '../ir/api_spec.dart';
import '../ir/dart_type.dart';
import '../resolve/dart_type_resolver.dart';
import '../resolve/name_giver.dart';

/// Turns a loaded OpenAPI map into the [ApiSpec] IR.
class SpecParser {
  final NameGiver _names;
  final DartTypeResolver _resolver;

  SpecParser(this._names, this._resolver);

  ApiSpec parse(Map<String, dynamic> spec, {required String name}) {
    final schemas = _schemas(spec);
    final enums = <EnumDef>[];
    final models = <ModelDef>[];

    for (final entry in schemas.entries) {
      final schema = entry.value;
      if (schema is! Map<String, dynamic>) continue;
      if (schema['enum'] is List) {
        enums.add(_enum(entry.key, schema));
      } else if (schema['type'] == 'object' || schema['properties'] is Map) {
        models.add(_model(entry.key, schema));
      }
    }

    return ApiSpec(
      name: name,
      enums: enums,
      models: models,
      service: _service(spec, name),
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

  ModelDef _model(String rawName, Map<String, dynamic> schema) {
    final required = (schema['required'] as List?)?.cast<String>() ?? const [];
    final properties =
        (schema['properties'] as Map?)?.cast<String, dynamic>() ?? const {};
    final fields = <FieldDef>[];

    for (final entry in properties.entries) {
      final propSchema = (entry.value as Map).cast<String, dynamic>();
      final type = _resolver.resolve(propSchema);
      fields.add(FieldDef(
        dartName: _names.memberName(entry.key),
        jsonKey: entry.key,
        type: type,
        isRequired: required.contains(entry.key),
        defaultValue: _defaultLiteral(propSchema['default']),
      ));
    }

    return ModelDef(name: _names.className(rawName), fields: fields);
  }

  String? _defaultLiteral(dynamic value) {
    if (value is String) return "'$value'";
    if (value is num || value is bool) return value.toString();
    return null;
  }

  ServiceDef _service(Map<String, dynamic> spec, String name) {
    final paths = (spec['paths'] as Map?)?.cast<String, dynamic>() ?? const {};
    final operations = <OperationDef>[];

    for (final pathEntry in paths.entries) {
      final methods = (pathEntry.value as Map).cast<String, dynamic>();
      for (final methodEntry in methods.entries) {
        final op = (methodEntry.value as Map).cast<String, dynamic>();
        operations.add(_operation(
          path: pathEntry.key,
          httpMethod: methodEntry.key.toUpperCase(),
          op: op,
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
  }) {
    final params = <ParamDef>[];
    for (final raw in (op['parameters'] as List?) ?? const []) {
      final p = (raw as Map).cast<String, dynamic>();
      final location =
          p['in'] == 'path' ? ParamLocation.path : ParamLocation.query;
      params.add(ParamDef(
        dartName: _names.memberName(p['name'] as String),
        wireName: p['name'] as String,
        type: _resolver.resolve((p['schema'] as Map).cast<String, dynamic>()),
        location: location,
      ));
    }

    DartType? bodyType;
    final body = op['requestBody'];
    final bodySchema =
        _jsonSchema(body is Map ? body.cast<String, dynamic>() : null);
    if (bodySchema != null) {
      bodyType = _resolver.resolve(bodySchema);
      params.add(ParamDef(
        dartName: 'body',
        wireName: 'body',
        type: bodyType,
        location: ParamLocation.body,
      ));
    }

    final responses = (op['responses'] as Map?)?.cast<String, dynamic>();
    final okSchema = _jsonSchema(
      (responses?['200'] as Map?)?.cast<String, dynamic>(),
    );
    final responseType =
        okSchema == null ? const DartType('dynamic') : _resolver.resolve(okSchema);

    return OperationDef(
      methodName: _names.memberName(
        op['operationId'] as String? ?? '${httpMethod.toLowerCase()}_$path',
      ),
      httpMethod: httpMethod,
      path: path,
      parameters: params,
      requestBodyType: bodyType,
      responseType: responseType,
    );
  }

  Map<String, dynamic>? _jsonSchema(Map<String, dynamic>? container) {
    final content = (container?['content'] as Map?)?.cast<String, dynamic>();
    final json = (content?['application/json'] as Map?)?.cast<String, dynamic>();
    final schema = json?['schema'];
    return schema is Map ? schema.cast<String, dynamic>() : null;
  }
}
