import 'package:build/build.dart';

import '../emit/client_emitter.dart';
import '../emit/enum_emitter.dart';
import '../emit/model_emitter.dart';
import '../emit/service_emitter.dart';
import '../parser/schema_hoister.dart';
import '../parser/spec_loader.dart';
import '../parser/spec_parser.dart';
import '../resolve/name_giver.dart';
import '../resolve/resolver_factory.dart';
import 'builder_config.dart';

Builder swaggerBuilder(BuilderOptions options) =>
    SwaggerBuilder(BuilderConfig.fromOptions(options));

/// Generates Dart sources from a `*.openapi.json` spec asset.
class SwaggerBuilder implements Builder {
  final BuilderConfig config;

  SwaggerBuilder(this.config);

  @override
  Map<String, List<String>> get buildExtensions => config.buildExtensions;

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final content = await buildStep.readAsString(input);
    final baseName = config.baseNameFor(input.path);

    final sources = generateSources(
      content,
      path: input.path,
      baseName: baseName,
      nameFromPath: config.nameFromPath,
      overridesImport: config.overridesImport,
      overrideSchemas: config.overrideSchemas,
    );

    for (final entry in sources.entries) {
      await buildStep.writeAsString(
        AssetId(input.package, config.outputPathFor(input.path, entry.key)),
        entry.value,
      );
    }
  }
}

/// Runs the full pipeline and returns output extension -> file content.
Map<String, String> generateSources(
  String content, {
  required String path,
  required String baseName,
  bool nameFromPath = false,
  String? overridesImport,
  Set<String> overrideSchemas = const {},
}) {
  final names = NameGiver();
  final loaded = SpecLoader().load(content, path: path);
  final normalized =
      SchemaHoister(names, nameFromPath: nameFromPath).hoist(loaded);
  final schemas =
      ((normalized['components'] as Map?)?['schemas'] as Map?)
          ?.cast<String, dynamic>() ??
      const {};
  final resolver = resolverForVersion(
    normalized['openapi'] as String?,
    names,
    schemas: schemas,
    overrides: overrideSchemas,
  );
  final spec = SpecParser(
    names,
    resolver,
    nameFromPath: nameFromPath,
    overrideSchemas: overrideSchemas,
  ).parse(normalized, name: baseName);

  final enumsFile = '$baseName.enums.dart';
  final modelsFile = '$baseName.models.dart';
  final serviceFile = '$baseName.service.dart';
  final clientFile = '$baseName.client.dart';

  final overrideTypes = overrideSchemas.map(names.className).toSet();
  final referenced = <String>{};
  final idRe = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');
  for (final model in spec.models) {
    for (final field in model.fields) {
      referenced.addAll(idRe.allMatches(field.type.name).map((m) => m[0]!));
    }
  }
  for (final op in spec.service.operations) {
    referenced.addAll(idRe.allMatches(op.responseType.name).map((m) => m[0]!));
    for (final p in op.parameters) {
      referenced.addAll(idRe.allMatches(p.type.name).map((m) => m[0]!));
    }
  }
  final usedOverrides = overrideTypes.where(referenced.contains).toSet();

  final emitter = ClientEmitter();

  return {
    '.enums.dart': EnumEmitter().emit(spec.enums),
    '.models.dart': ModelEmitter().emit(
      spec.models,
      partFileName: '$baseName.models.g.dart',
      enumsImport: enumsFile,
      enumNames: spec.enums.map((e) => e.name).toSet(),
      overrideTypes: overrideTypes,
      overridesImport: overridesImport,
      typedefs: spec.typedefs,
    ),
    '.service.dart': ServiceEmitter().emit(
      spec.service,
      partFileName: '$baseName.service.chopper.dart',
      modelsImport: modelsFile,
      enumsImport: enumsFile,
      enumNames: spec.enums.map((e) => e.name).toSet(),
      overrideTypes: overrideTypes,
      overridesImport: overridesImport,
    ),
    '.client.dart': emitter.emitClient(
      spec.service,
      serviceImport: serviceFile,
      modelsImport: modelsFile,
      enumsImport: enumsFile,
      models: spec.models,
      enumNames: spec.enums.map((e) => e.name).toSet(),
      overrideTypes: usedOverrides,
      overridesImport: overridesImport,
    ),
    '.api.dart': emitter.emitBarrel(
      enumsImport: enumsFile,
      modelsImport: modelsFile,
      serviceImport: serviceFile,
      clientImport: clientFile,
    ),
  };
}
