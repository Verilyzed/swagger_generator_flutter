import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the single Chopper service file from the IR.
class ServiceEmitter {
  String emit(
    ServiceDef service, {
    required String partFileName,
    required String modelsImport,
    required String enumsImport,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln(SourceWriter.importLine(modelsImport))
      ..writeln(SourceWriter.importLine(enumsImport))
      ..writeln()
      ..writeln("part '$partFileName';")
      ..writeln()
      ..writeln("@ChopperApi(baseUrl: '')")
      ..writeln('abstract class ${service.name} extends ChopperService {');

    for (final op in service.operations) {
      _emitMethod(buffer, op);
    }

    buffer
      ..writeln(
        '  static ${service.name} create([ChopperClient? client]) =>',
      )
      ..writeln('      _\$${service.name}(client);')
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }

  void _emitMethod(StringBuffer buffer, OperationDef op) {
    final verb = _verb(op.httpMethod);
    final args = op.parameters.map(_param).join(',\n    ');
    buffer
      ..writeln("  @$verb(path: '${op.path}')")
      ..writeln(
        '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
      );
    if (args.isNotEmpty) {
      buffer.writeln('    $args,');
    }
    buffer
      ..writeln('  );')
      ..writeln();
  }

  String _param(ParamDef p) {
    switch (p.location) {
      case ParamLocation.path:
        return "@Path('${p.wireName}') ${p.type.display} ${p.dartName}";
      case ParamLocation.query:
        return "@Query('${p.wireName}') ${p.type.display} ${p.dartName}";
      case ParamLocation.body:
        return '@Body() ${p.type.display} ${p.dartName}';
    }
  }

  String _verb(String httpMethod) {
    switch (httpMethod) {
      case 'GET':
        return 'Get';
      case 'POST':
        return 'Post';
      case 'PUT':
        return 'Put';
      case 'PATCH':
        return 'Patch';
      case 'DELETE':
        return 'Delete';
      default:
        return 'Get';
    }
  }
}
