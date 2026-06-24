import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the models file from the IR.
class ModelEmitter {
  String emit(
    List<ModelDef> models, {
    required String partFileName,
    required String enumsImport,
    required Set<String> enumNames,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(
        SourceWriter.importLine(
          'package:json_annotation/json_annotation.dart',
        ),
      )
      ..writeln(SourceWriter.importLine(enumsImport))
      ..writeln()
      ..writeln("part '$partFileName';")
      ..writeln();

    if (models.any((m) => m.fields.any((f) => f.type.isDateOnly))) {
      buffer
        ..writeln(
          'class DateConverter implements JsonConverter<DateTime, String> {',
        )
        ..writeln('  const DateConverter();')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  DateTime fromJson(String json) => DateTime.parse(json);')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  String toJson(DateTime object) =>')
        ..writeln("      object.toIso8601String().split('T').first;")
        ..writeln('}')
        ..writeln();
    }

    for (final model in models) {
      _emitClass(buffer, model, enumNames);
    }

    return buffer.toString();
  }

  void _emitClass(StringBuffer buffer, ModelDef model, Set<String> enumNames) {
    buffer
      ..writeln('@JsonSerializable()')
      ..writeln('class ${model.name} {');

    for (final field in model.fields) {
      final enumName = _enumOf(field.type.name, enumNames);
      final keyArgs = <String>[];
      if (field.jsonKey != field.dartName) {
        keyArgs.add("name: '${field.jsonKey}'");
      }
      if (enumName != null) {
        keyArgs.add('unknownEnumValue: $enumName.\$unknown');
      }
      if (keyArgs.isNotEmpty) {
        buffer.writeln('  @JsonKey(${keyArgs.join(', ')})');
      }
      if (field.type.isDateOnly) {
        buffer.writeln('  @DateConverter()');
      }
      buffer.writeln('  final ${field.type.display} ${field.dartName};');
    }

    buffer
      ..writeln()
      ..writeln('  ${model.name}({');
    for (final field in model.fields) {
      final makeRequired = field.defaultValue == null &&
          (field.isRequired || !field.type.isNullable);
      final prefix = makeRequired ? 'required ' : '';
      final suffix = field.defaultValue != null ? ' = ${field.defaultValue}' : '';
      buffer.writeln('    ${prefix}this.${field.dartName}$suffix,');
    }
    buffer
      ..writeln('  });')
      ..writeln()
      ..writeln(
        '  factory ${model.name}.fromJson(Map<String, dynamic> json) =>',
      )
      ..writeln('      _\$${model.name}FromJson(json);')
      ..writeln()
      ..writeln(
        '  Map<String, dynamic> toJson() => _\$${model.name}ToJson(this);',
      )
      ..writeln('}')
      ..writeln();
  }

  String? _enumOf(String typeName, Set<String> enumNames) {
    for (final id in RegExp(r'[A-Za-z_][A-Za-z0-9_]*')
        .allMatches(typeName)
        .map((m) => m[0]!)) {
      if (enumNames.contains(id)) return id;
    }
    return null;
  }
}
