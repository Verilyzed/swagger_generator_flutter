import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the enums file from the IR.
class EnumEmitter {
  String emit(List<EnumDef> enums) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(
        SourceWriter.importLine(
          'package:json_annotation/json_annotation.dart',
        ),
      )
      ..writeln();

    for (final e in enums) {
      buffer.writeln('enum ${e.name} {');
      for (final v in e.values) {
        buffer
          ..writeln("  @JsonValue('${v.jsonValue}')")
          ..writeln('  ${v.dartName},');
      }
      buffer
        ..writeln('  // Fallback for values not present in the spec.')
        ..writeln(r'  $unknown,')
        ..writeln('}')
        ..writeln()
        ..writeln('extension ${e.name}Wire on ${e.name} {')
        ..writeln('  String get wireValue => const {');
      for (final v in e.values) {
        buffer.writeln("    ${e.name}.${v.dartName}: '${v.jsonValue}',");
      }
      buffer
        ..writeln("  }[this] ?? '';")
        ..writeln('}')
        ..writeln();
    }

    return buffer.toString();
  }
}
