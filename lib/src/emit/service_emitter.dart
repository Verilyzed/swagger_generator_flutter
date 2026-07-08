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
    Set<String> overrideTypes = const {},
    String? overridesImport,
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
    if (overridesImport != null && _usesOverride(service, overrideTypes)) {
      buffer.writeln(SourceWriter.importLine(overridesImport));
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
        (op) => op.parameters.any((p) =>
            p.location == ParamLocation.partFile &&
            p.type.name == 'MultipartFile'),
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

  bool _usesOverride(ServiceDef service, Set<String> overrideTypes) {
    if (overrideTypes.isEmpty) return false;
    for (final op in service.operations) {
      for (final id in _identifiers(op.responseType.name)) {
        if (overrideTypes.contains(id)) return true;
      }
      for (final p in op.parameters) {
        for (final id in _identifiers(p.type.name)) {
          if (overrideTypes.contains(id)) return true;
        }
      }
    }
    return false;
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
