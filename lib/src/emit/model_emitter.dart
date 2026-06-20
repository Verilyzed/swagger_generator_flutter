import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the models file from the IR.
class ModelEmitter {
  String emit(
    List<ModelDef> models, {
    required String partFileName,
    required String enumsImport,
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

    for (final model in models) {
      _emitClass(buffer, model);
    }

    return buffer.toString();
  }

  void _emitClass(StringBuffer buffer, ModelDef model) {
    buffer
      ..writeln('@JsonSerializable()')
      ..writeln('class ${model.name} {');

    for (final field in model.fields) {
      if (field.jsonKey != field.dartName) {
        buffer.writeln("  @JsonKey(name: '${field.jsonKey}')");
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
}
