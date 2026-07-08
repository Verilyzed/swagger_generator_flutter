import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the Chopper client assembly and the barrel export file.
class ClientEmitter {
  String emitClient(
    ServiceDef service, {
    required String serviceImport,
    required String modelsImport,
    required String enumsImport,
    required List<ModelDef> models,
    required Set<String> enumNames,
    Set<String> overrideTypes = const {},
    String? overridesImport,
  }) {
    final usesMultipart = service.operations.any(
      (op) => op.parameters.any((p) =>
          p.location == ParamLocation.partFile &&
          p.type.name == 'MultipartFile'),
    );
    final httpShow = usesMultipart ? 'Client, MultipartFile' : 'Client';

    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln("import 'package:http/http.dart' show $httpShow;")
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln(SourceWriter.importLine(modelsImport));
    if (_usesEnum(service, enumNames)) {
      buffer.writeln(SourceWriter.importLine(enumsImport));
    }
    if (overridesImport != null && overrideTypes.isNotEmpty) {
      buffer.writeln(SourceWriter.importLine(overridesImport));
    }
    buffer
      ..writeln()
      ..writeln('typedef JsonFactory = dynamic Function(Map<String, dynamic> json);')
      ..writeln()
      ..writeln('class JsonSerializableConverter extends JsonConverter {')
      ..writeln('  const JsonSerializableConverter(this.factories);')
      ..writeln()
      ..writeln('  final Map<Type, JsonFactory> factories;')
      ..writeln()
      ..writeln('  T? _decodeMap<T>(Map<String, dynamic> values) {')
      ..writeln('    final factory = factories[T];')
      ..writeln('    return factory == null ? null : factory(values) as T;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  List<T> _decodeList<T>(Iterable values) => values')
      ..writeln('      .whereType<Map<String, dynamic>>()')
      ..writeln('      .map<T?>(_decodeMap<T>)')
      ..writeln('      .whereType<T>()')
      ..writeln('      .toList();')
      ..writeln()
      ..writeln('  dynamic _decode<T>(dynamic entity) {')
      ..writeln('    if (entity is Iterable) return _decodeList<T>(entity);')
      ..writeln(
        '    if (entity is Map<String, dynamic>) return _decodeMap<T>(entity);',
      )
      ..writeln('    return entity;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Future<Response<ResultType>> convertResponse<ResultType, Inner>(')
      ..writeln('    Response response,')
      ..writeln('  ) async {')
      ..writeln(
        '    final decoded = await super.convertResponse<dynamic, dynamic>(response);',
      )
      ..writeln('    return decoded.copyWith<ResultType>(')
      ..writeln('      body: _decode<Inner>(decoded.body),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln()
      ..writeln('ChopperClient createClient({')
      ..writeln('  required Uri baseUrl,')
      ..writeln('  Client? httpClient,')
      ..writeln('  List<Interceptor>? interceptors,')
      ..writeln('  Authenticator? authenticator,')
      ..writeln('}) {')
      ..writeln('  return ChopperClient(')
      ..writeln('    baseUrl: baseUrl,')
      ..writeln('    client: httpClient,')
      ..writeln('    converter: const JsonSerializableConverter({');
    for (final model in models) {
      buffer.writeln('      ${model.name}: ${model.name}.fromJson,');
    }
    for (final type in overrideTypes) {
      buffer.writeln('      $type: $type.fromJson,');
    }
    buffer
      ..writeln('    }),')
      ..writeln('    interceptors: interceptors ?? const [],')
      ..writeln('    authenticator: authenticator,')
      ..writeln('    services: [${service.name}.create()],')
      ..writeln('  );')
      ..writeln('}')
      ..writeln();

    _emitFacade(buffer, service);

    return buffer.toString();
  }

  void _emitFacade(StringBuffer buffer, ServiceDef service) {
    final apiName = service.name.endsWith('Service')
        ? '${service.name.substring(0, service.name.length - 'Service'.length)}Api'
        : '${service.name}Api';

    buffer
      ..writeln('class $apiName {')
      ..writeln('  final ${service.name} _service;')
      ..writeln()
      ..writeln('  $apiName({')
      ..writeln('    required Uri baseUrl,')
      ..writeln('    Client? httpClient,')
      ..writeln('    List<Interceptor>? interceptors,')
      ..writeln('    Authenticator? authenticator,')
      ..writeln('  }) : this.fromClient(createClient(')
      ..writeln('          baseUrl: baseUrl,')
      ..writeln('          httpClient: httpClient,')
      ..writeln('          interceptors: interceptors,')
      ..writeln('          authenticator: authenticator,')
      ..writeln('        ));')
      ..writeln()
      ..writeln('  $apiName.fromClient(ChopperClient client)')
      ..writeln('      : _service = ${service.name}.create(client);')
      ..writeln();

    for (final op in service.operations) {
      _emitFacadeMethod(buffer, op);
    }

    buffer
      ..writeln('}')
      ..writeln();
  }

  void _emitFacadeMethod(StringBuffer buffer, OperationDef op) {
    buffer.write(
      '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
    );

    if (op.parameters.isEmpty) {
      buffer
        ..writeln(') =>')
        ..writeln('      _service.${op.methodName}();')
        ..writeln();
      return;
    }

    buffer.writeln('{');
    for (final p in op.parameters) {
      buffer.writeln('    ${_facadeParam(p)},');
    }
    buffer
      ..writeln('  }) =>')
      ..writeln('      _service.${op.methodName}(');
    for (final p in op.parameters) {
      buffer.writeln('        ${_facadeArg(p)},');
    }
    buffer
      ..writeln('      );')
      ..writeln();
  }

  String _facadeParam(ParamDef p) {
    if (p.isRequired) return 'required ${p.type.display} ${p.dartName}';
    final nullable = p.type.isNullable ? p.type.display : '${p.type.name}?';
    return '$nullable ${p.dartName}';
  }

  String _facadeArg(ParamDef p) {
    if (!p.isRequired && p.defaultValue != null) {
      return '${p.dartName}: ${p.dartName} ?? ${p.defaultValue}';
    }
    return '${p.dartName}: ${p.dartName}';
  }

  bool _usesEnum(ServiceDef service, Set<String> enumNames) {
    if (enumNames.isEmpty) return false;
    for (final op in service.operations) {
      if (_identifiers(op.responseType.name).any(enumNames.contains)) {
        return true;
      }
      for (final p in op.parameters) {
        if (_identifiers(p.type.name).any(enumNames.contains)) return true;
      }
    }
    return false;
  }

  Iterable<String> _identifiers(String type) =>
      RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(type).map((m) => m[0]!);

  String emitBarrel({
    required String enumsImport,
    required String modelsImport,
    required String serviceImport,
    required String clientImport,
  }) {
    final buffer = StringBuffer()..write(SourceWriter.header());
    for (final uri in [enumsImport, modelsImport, serviceImport, clientImport]) {
      buffer.writeln("export '$uri';");
    }
    return buffer.toString();
  }
}
