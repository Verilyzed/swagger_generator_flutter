import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the single Chopper service file from the IR.
class ServiceEmitter {
  String emit(
    ServiceDef service, {
    required String partFileName,
    required String modelsImport,
    required String enumsImport,
    required Set<String> enumNames,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'));
    if (_usesMultipartFile(service)) {
      buffer.writeln("import 'package:http/http.dart' show MultipartFile;");
    }
    buffer.writeln(SourceWriter.importLine(modelsImport));
    if (_usesEnum(service, enumNames)) {
      buffer.writeln(SourceWriter.importLine(enumsImport));
    }
    buffer
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
      ..writeln(
        '  $apiName(ChopperClient client) : _service = ${service.name}.create(client);',
      )
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

  void _emitMethod(StringBuffer buffer, OperationDef op) {
    final verb = _verb(op.httpMethod);
    final named =
        op.parameters.map((p) => '    ${_namedParam(p)},').toList();

    buffer.writeln("  @$verb(path: '${op.path}')");
    if (op.parameters.any((p) =>
        p.location == ParamLocation.part ||
        p.location == ParamLocation.partFile)) {
      buffer.writeln('  @multipart');
    }
    buffer.write(
      '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
    );

    if (named.isEmpty) {
      buffer.writeln(');');
    } else {
      buffer.writeln('{');
      for (final line in named) {
        buffer.writeln(line);
      }
      buffer.writeln('  });');
    }

    buffer.writeln();
  }

  String _namedParam(ParamDef p) {
    final annotation = _annotation(p);
    if (p.isRequired) {
      return '$annotation required ${p.type.display} ${p.dartName}';
    }
    final nullable = p.type.isNullable ? p.type.display : '${p.type.name}?';
    return '$annotation $nullable ${p.dartName}';
  }

  bool _usesMultipartFile(ServiceDef service) => service.operations.any(
        (op) => op.parameters.any((p) => p.location == ParamLocation.partFile),
      );

  bool _usesEnum(ServiceDef service, Set<String> enumNames) {
    if (enumNames.isEmpty) return false;
    final used = <String>{};
    for (final op in service.operations) {
      used.addAll(_identifiers(op.responseType.name));
      for (final p in op.parameters) {
        used.addAll(_identifiers(p.type.name));
      }
    }
    return used.any(enumNames.contains);
  }

  Iterable<String> _identifiers(String type) =>
      RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(type).map((m) => m[0]!);

  String _annotation(ParamDef p) {
    switch (p.location) {
      case ParamLocation.path:
        return "@Path('${p.wireName}')";
      case ParamLocation.query:
        return "@Query('${p.wireName}')";
      case ParamLocation.body:
        return '@Body()';
      case ParamLocation.part:
        return "@Part('${p.wireName}')";
      case ParamLocation.partFile:
        return "@PartFile('${p.wireName}')";
    }
  }

  String _verb(String httpMethod) {
    switch (httpMethod) {
      case 'GET':
        return 'GET';
      case 'POST':
        return 'POST';
      case 'PUT':
        return 'PUT';
      case 'PATCH':
        return 'PATCH';
      case 'DELETE':
        return 'DELETE';
      case 'HEAD':
        return 'HEAD';
      case 'OPTIONS':
        return 'OPTIONS';
      default:
        return 'GET';
    }
  }
}
