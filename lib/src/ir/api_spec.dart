import 'dart_type.dart';

class EnumValueDef {
  final String dartName;
  final String jsonValue;

  const EnumValueDef({required this.dartName, required this.jsonValue});
}

class EnumDef {
  final String name;
  final List<EnumValueDef> values;

  const EnumDef({required this.name, required this.values});
}

class FieldDef {
  final String dartName;
  final String jsonKey;
  final DartType type;
  final bool isRequired;
  final String? defaultValue;

  const FieldDef({
    required this.dartName,
    required this.jsonKey,
    required this.type,
    required this.isRequired,
    this.defaultValue,
  });
}

class ModelDef {
  final String name;
  final List<FieldDef> fields;

  const ModelDef({required this.name, required this.fields});
}

enum ParamLocation { path, query, body }

class ParamDef {
  final String dartName;
  final String wireName;
  final DartType type;
  final ParamLocation location;

  const ParamDef({
    required this.dartName,
    required this.wireName,
    required this.type,
    required this.location,
  });
}

class OperationDef {
  final String methodName;
  final String httpMethod;
  final String path;
  final List<ParamDef> parameters;
  final DartType? requestBodyType;
  final DartType responseType;

  const OperationDef({
    required this.methodName,
    required this.httpMethod,
    required this.path,
    required this.parameters,
    required this.responseType,
    this.requestBodyType,
  });
}

class ServiceDef {
  final String name;
  final List<OperationDef> operations;

  const ServiceDef({required this.name, required this.operations});
}

class ApiSpec {
  final String name;
  final List<EnumDef> enums;
  final List<ModelDef> models;
  final ServiceDef service;

  const ApiSpec({
    required this.name,
    required this.enums,
    required this.models,
    required this.service,
  });
}
