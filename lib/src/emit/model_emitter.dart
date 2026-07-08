import '../ir/api_spec.dart';
import 'source_writer.dart';

/// Emits the models file from the IR.
class ModelEmitter {
  String emit(
    List<ModelDef> models, {
    required String partFileName,
    required String enumsImport,
    required Set<String> enumNames,
    Set<String> overrideTypes = const {},
    String? overridesImport,
    List<TypedefDef> typedefs = const [],
    bool includeIfNull = true,
  }) {
    final buffer = StringBuffer()
      ..write(SourceWriter.header())
      ..writeln(
        SourceWriter.importLine(
          'package:json_annotation/json_annotation.dart',
        ),
      )
      ..writeln(SourceWriter.importLine(enumsImport));
    if (overridesImport != null && _usesOverride(models, overrideTypes)) {
      buffer.writeln(SourceWriter.importLine(overridesImport));
    }
    buffer
      ..writeln()
      ..writeln("part '$partFileName';")
      ..writeln();

    if (typedefs.isNotEmpty) {
      for (final t in typedefs) {
        buffer.writeln('typedef ${t.name} = ${t.aliasType.display};');
      }
      buffer.writeln();
    }

    for (final model in models) {
      _emitClass(buffer, model, enumNames, includeIfNull);
    }

    return buffer.toString();
  }

  void _emitClass(
    StringBuffer buffer,
    ModelDef model,
    Set<String> enumNames,
    bool includeIfNull,
  ) {
    buffer
      ..writeln('@JsonSerializable()')
      ..writeln('class ${model.name} {');

    for (final field in model.fields) {
      final enumName = _enumOf(field.type.name, enumNames);
      // Always pin the wire name so renaming a Dart field cannot silently
      // change the JSON contract.
      final keyArgs = <String>["name: '${field.jsonKey}'"];
      if (enumName != null) {
        keyArgs.add('unknownEnumValue: $enumName.\$unknown');
      }
      if (!includeIfNull) {
        keyArgs.add('includeIfNull: false');
      }
      if (keyArgs.isNotEmpty) {
        buffer.writeln('  @JsonKey(${keyArgs.join(', ')})');
      }
      buffer.writeln('  final ${field.type.display} ${field.dartName};');
    }

    buffer.writeln();
    if (model.fields.isEmpty) {
      buffer
        ..writeln('  const ${model.name}();')
        ..writeln();
    } else {
      buffer.writeln('  const ${model.name}({');
      for (final field in model.fields) {
        // A constructor parameter is required only when it cannot be null and
        // has no default. A nullable field is always optional (it defaults to
        // null), even if the schema lists it as required.
        final makeRequired =
            field.defaultValue == null && !field.type.isNullable;
        final prefix = makeRequired ? 'required ' : '';
        final suffix =
            field.defaultValue != null ? ' = ${field.defaultValue}' : '';
        buffer.writeln('    ${prefix}this.${field.dartName}$suffix,');
      }
      buffer
        ..writeln('  });')
        ..writeln();
    }
    _emitCopyWith(buffer, model);
    buffer
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

  // json_serializable accepts unknownEnumValue only on an enum field or a
  // List/Set/Iterable of an enum, not on an enum used as a map key or value.
  static final _enumCollection =
      RegExp(r'^(?:List|Set|Iterable)<([A-Za-z_][A-Za-z0-9_]*)>$');

  // Each parameter is the field's type made nullable so an omitted argument
  // keeps the current value (`dynamic` is already nullable). Passing null to a
  // nullable field keeps it; rebuild via the constructor to clear one.
  void _emitCopyWith(StringBuffer buffer, ModelDef model) {
    if (model.fields.isEmpty) {
      buffer
        ..writeln('  ${model.name} copyWith() => ${model.name}();')
        ..writeln();
      return;
    }
    buffer.writeln('  ${model.name} copyWith({');
    for (final field in model.fields) {
      final paramType =
          field.type.name == 'dynamic' ? 'dynamic' : '${field.type.name}?';
      buffer.writeln('    $paramType ${field.dartName},');
    }
    buffer
      ..writeln('  }) {')
      ..writeln('    return ${model.name}(');
    for (final field in model.fields) {
      final name = field.dartName;
      buffer.writeln('      $name: $name ?? this.$name,');
    }
    buffer
      ..writeln('    );')
      ..writeln('  }')
      ..writeln();
  }

  String? _enumOf(String typeName, Set<String> enumNames) {
    if (enumNames.contains(typeName)) return typeName;
    final inner = _enumCollection.firstMatch(typeName)?.group(1);
    if (inner != null && enumNames.contains(inner)) return inner;
    return null;
  }

  bool _usesOverride(List<ModelDef> models, Set<String> overrideTypes) {
    if (overrideTypes.isEmpty) return false;
    for (final model in models) {
      for (final field in model.fields) {
        for (final id in _identifiers(field.type.name)) {
          if (overrideTypes.contains(id)) return true;
        }
      }
    }
    return false;
  }

  Iterable<String> _identifiers(String type) =>
      RegExp(r'[A-Za-z_][A-Za-z0-9_]*').allMatches(type).map((m) => m[0]!);
}
