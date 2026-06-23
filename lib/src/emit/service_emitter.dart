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
      ..writeln(SourceWriter.importLine('package:chopper/chopper.dart'))
      ..writeln(SourceWriter.importLine(modelsImport));
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

    return buffer.toString();
  }

  void _emitMethod(StringBuffer buffer, OperationDef op) {
    final verb = _verb(op.httpMethod);
    final positional = op.parameters
        .where((p) => p.isRequired)
        .map((p) => '    ${_annotation(p)} ${p.type.display} ${p.dartName},')
        .toList();
    final named = op.parameters
        .where((p) => !p.isRequired)
        .map((p) => '    ${_namedParam(p)},')
        .toList();

    buffer
      ..writeln("  @$verb(path: '${op.path}')")
      ..write(
        '  Future<Response<${op.responseType.display}>> ${op.methodName}(',
      );

    if (positional.isEmpty && named.isEmpty) {
      buffer.writeln(');');
    } else if (named.isEmpty) {
      buffer.writeln();
      for (final line in positional) {
        buffer.writeln(line);
      }
      buffer.writeln('  );');
    } else if (positional.isEmpty) {
      buffer.writeln('{');
      for (final line in named) {
        buffer.writeln(line);
      }
      buffer.writeln('  });');
    } else {
      buffer.writeln();
      for (final line in positional) {
        buffer.writeln(line);
      }
      buffer.writeln('    {');
      for (final line in named) {
        buffer.writeln(line);
      }
      buffer.writeln('  });');
    }

    buffer.writeln();
  }

  String _namedParam(ParamDef p) {
    final annotation = _annotation(p);
    if (p.defaultValue != null) {
      return '$annotation ${p.type.display} ${p.dartName} = ${p.defaultValue}';
    }
    final nullable = p.type.isNullable ? p.type.display : '${p.type.name}?';
    return '$annotation $nullable ${p.dartName}';
  }

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
