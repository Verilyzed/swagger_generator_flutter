import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the Chopper client assembly and the barrel export file.
class ClientEmitter {
  String emitClient(
    ServiceDef service, {
    required String serviceImport,
    required String modelsImport,
    required List<ModelDef> models,
    Set<String> overrideTypes = const {},
    String? overridesImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln("import 'package:http/http.dart' show Client;")
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln(SourceWriter.importLine(modelsImport));
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

    return buffer.toString();
  }

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
