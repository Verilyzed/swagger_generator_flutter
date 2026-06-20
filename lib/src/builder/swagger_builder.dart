import 'package:build/build.dart';

import '../emit/client_emitter.dart';
import '../emit/enum_emitter.dart';
import '../emit/model_emitter.dart';
import '../emit/service_emitter.dart';
import '../parser/spec_loader.dart';
import '../parser/spec_parser.dart';
import '../resolve/dart_type_resolver.dart';
import '../resolve/name_giver.dart';

Builder swaggerBuilder(BuilderOptions options) => SwaggerBuilder();

/// Generates Dart sources from a `*.openapi.json` spec asset.
class SwaggerBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const {
        '.openapi.json': [
          '.enums.dart',
          '.models.dart',
          '.service.dart',
          '.client.dart',
          '.api.dart',
        ],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final input = buildStep.inputId;
    final content = await buildStep.readAsString(input);
    final baseName =
        input.pathSegments.last.replaceAll(RegExp(r'\.openapi\.json$'), '');

    final sources = generateSources(
      content,
      path: input.path,
      baseName: baseName,
    );

    for (final entry in sources.entries) {
      await buildStep.writeAsString(
        AssetId(input.package, outputAssetPath(input.path, entry.key)),
        entry.value,
      );
    }
  }
}

/// Maps a `*.openapi.json` input path to an output path for the given
/// extension. The full `.openapi.json` suffix is replaced so that multi-dot
/// inputs (e.g. `foo.openapi.json`) yield `foo.enums.dart`, matching what
/// build_runner derives from [SwaggerBuilder.buildExtensions]. Using
/// `AssetId.changeExtension` here would only strip the trailing `.json`.
String outputAssetPath(String inputPath, String outputExtension) =>
    inputPath.replaceFirst('.openapi.json', outputExtension);

/// Runs the full pipeline and returns output extension -> file content.
Map<String, String> generateSources(
  String content, {
  required String path,
  required String baseName,
}) {
  final names = NameGiver();
  final resolver = DartTypeResolver(names);
  final spec = SpecParser(names, resolver)
      .parse(SpecLoader().load(content, path: path), name: baseName);

  final enumsFile = '$baseName.enums.dart';
  final modelsFile = '$baseName.models.dart';
  final serviceFile = '$baseName.service.dart';
  final clientFile = '$baseName.client.dart';

  final emitter = ClientEmitter();

  return {
    '.enums.dart': EnumEmitter().emit(spec.enums),
    '.models.dart': ModelEmitter().emit(
      spec.models,
      partFileName: '$baseName.models.g.dart',
      enumsImport: enumsFile,
    ),
    '.service.dart': ServiceEmitter().emit(
      spec.service,
      partFileName: '$baseName.service.chopper.dart',
      modelsImport: modelsFile,
      enumsImport: enumsFile,
    ),
    '.client.dart': emitter.emitClient(
      spec.service,
      serviceImport: serviceFile,
    ),
    '.api.dart': emitter.emitBarrel(
      enumsImport: enumsFile,
      modelsImport: modelsFile,
      serviceImport: serviceFile,
      clientImport: clientFile,
    ),
  };
}
