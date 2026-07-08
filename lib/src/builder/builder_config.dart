import 'package:build/build.dart';

/// Resolved input/output folder configuration for the builder.
///
/// Folders are normalized to have no surrounding slashes; an empty string
/// means "the package root" (co-located with the input).
class BuilderConfig {
  final String inputFolder;
  final String outputFolder;
  final bool nameFromPath;
  final String? overridesImport;
  final Set<String> overrideSchemas;

  /// Whether generated models serialize null fields. When false, every field's
  /// `@JsonKey` carries `includeIfNull: false` so null values are omitted from
  /// the JSON output. Defaults to true, matching json_serializable.
  final bool includeIfNull;

  const BuilderConfig({
    required this.inputFolder,
    required this.outputFolder,
    this.nameFromPath = false,
    this.overridesImport,
    this.overrideSchemas = const {},
    this.includeIfNull = true,
  });

  factory BuilderConfig.fromOptions(BuilderOptions options) {
    final input = _normalize(options.config['input_folder']);
    final rawOutput = _normalize(options.config['output_folder']);
    final outputExplicit = rawOutput.isNotEmpty;
    final output = outputExplicit ? rawOutput : input;
    // Only validate when output_folder was explicitly provided; a blank or
    // whitespace value normalizes to empty and is treated as unset (defaults
    // to input_folder).
    if (outputExplicit && output != 'lib' && !output.startsWith('lib/')) {
      throw ArgumentError.value(
        output,
        'output_folder',
        'output_folder must be under lib/ '
            '(build_runner only writes generated source there)',
      );
    }
    final nameFromPath = options.config['method_names'] == 'path';
    final rawImport = options.config['overrides_import'];
    final overridesImport = rawImport is String && rawImport.trim().isNotEmpty
        ? rawImport.trim()
        : null;
    final rawSchemas = options.config['override_schemas'];
    final overrideSchemas = rawSchemas is List
        ? rawSchemas.map((e) => e.toString()).toSet()
        : <String>{};
    final rawIncludeIfNull = options.config['include_if_null'];
    final includeIfNull = rawIncludeIfNull is bool ? rawIncludeIfNull : true;
    if (overrideSchemas.isNotEmpty && overridesImport == null) {
      throw ArgumentError.value(
        rawSchemas,
        'override_schemas',
        'override_schemas requires overrides_import to be set',
      );
    }
    return BuilderConfig(
      inputFolder: input,
      outputFolder: output,
      nameFromPath: nameFromPath,
      overridesImport: overridesImport,
      overrideSchemas: overrideSchemas,
      includeIfNull: includeIfNull,
    );
  }

  static const _extensions = [
    '.enums.dart',
    '.models.dart',
    '.service.dart',
    '.client.dart',
    '.api.dart',
  ];

  static const _inputExtensions = ['.json', '.yaml', '.yml'];

  String get _inputPrefix => inputFolder.isEmpty ? '' : '$inputFolder/';
  String get _outputPrefix => outputFolder.isEmpty ? '' : '$outputFolder/';

  Map<String, List<String>> get buildExtensions => {
        for (final inExt in _inputExtensions)
          '$_inputPrefix{{}}$inExt': [
            for (final ext in _extensions) '$_outputPrefix{{}}$ext',
          ],
      };

  /// The portion of [inputPath] captured by `{{}}`: the input prefix and the
  /// `.json`/`.yaml`/`.yml` suffix removed, any subdirectories preserved.
  ///
  /// Precondition: [inputPath] must be under [inputFolder] when [inputFolder]
  /// is non-empty. build_runner only invokes the builder for inputs that match
  /// the pattern in [buildExtensions], so this is always satisfied in normal
  /// use.
  String captureStem(String inputPath) {
    assert(
      _inputPrefix.isEmpty || inputPath.startsWith(_inputPrefix),
      'inputPath "$inputPath" is not under input_folder "$inputFolder"',
    );
    var path = inputPath;
    if (_inputPrefix.isNotEmpty && path.startsWith(_inputPrefix)) {
      path = path.substring(_inputPrefix.length);
    }
    return path.replaceFirst(RegExp(r'\.(json|ya?ml)$'), '');
  }

  /// The bare base name (last path segment) used for cross-file imports.
  String baseNameFor(String inputPath) => captureStem(inputPath).split('/').last;

  /// The output asset path for [extension], matching what build_runner derives
  /// from [buildExtensions].
  String outputPathFor(String inputPath, String extension) =>
      '$_outputPrefix${captureStem(inputPath)}$extension';

  static String _normalize(Object? value) {
    if (value is! String) return '';
    return value
        .trim()
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/+$'), '');
  }
}
