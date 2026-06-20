import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the Chopper client assembly and the barrel export file.
class ClientEmitter {
  String emitClient(
    ServiceDef service, {
    required String serviceImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln(SourceWriter.importLine(serviceImport))
      ..writeln()
      ..writeln('ChopperClient createClient({')
      ..writeln('  required Uri baseUrl,')
      ..writeln('  List<Interceptor>? interceptors,')
      ..writeln('}) {')
      ..writeln('  return ChopperClient(')
      ..writeln('    baseUrl: baseUrl,')
      ..writeln('    converter: const JsonConverter(),')
      ..writeln('    interceptors: interceptors ?? const [],')
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
