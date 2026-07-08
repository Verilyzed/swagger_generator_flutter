import 'package:build/build.dart';
import 'package:swagger_generator_flutter/src/builder/builder_config.dart';
import 'package:test/test.dart';

void main() {
  test('defaults to co-located when no options are given', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(config.inputFolder, '');
    expect(config.outputFolder, '');
  });

  test('include_if_null defaults to true', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(config.includeIfNull, isTrue);
  });

  test('reads include_if_null when set to false', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({'include_if_null': false}),
    );
    expect(config.includeIfNull, isFalse);
  });

  test('output_folder defaults to input_folder when only input is set', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({'input_folder': 'api_specs'}),
    );
    expect(config.inputFolder, 'api_specs');
    expect(config.outputFolder, 'api_specs');
  });

  test('reads and normalizes both folders', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({
        'input_folder': 'api_specs/',
        'output_folder': '/lib/generated/',
      }),
    );
    expect(config.inputFolder, 'api_specs');
    expect(config.outputFolder, 'lib/generated');
  });

  test('throws when output_folder is not under lib', () {
    expect(
      () => BuilderConfig.fromOptions(
        const BuilderOptions({'output_folder': 'build/out'}),
      ),
      throwsArgumentError,
    );
  });

  test('default buildExtensions map json co-located', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(config.buildExtensions['{{}}.json'], [
      '{{}}.enums.dart',
      '{{}}.models.dart',
      '{{}}.service.dart',
      '{{}}.client.dart',
      '{{}}.api.dart',
    ]);
  });

  test('configured buildExtensions carry input and output prefixes', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({
        'input_folder': 'api_specs',
        'output_folder': 'lib/generated',
      }),
    );
    expect(config.buildExtensions['api_specs/{{}}.json'], [
      'lib/generated/{{}}.enums.dart',
      'lib/generated/{{}}.models.dart',
      'lib/generated/{{}}.service.dart',
      'lib/generated/{{}}.client.dart',
      'lib/generated/{{}}.api.dart',
    ]);
  });

  test('default outputPathFor is co-located, replacing the suffix', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(
      config.outputPathFor('lib/resource_scheduler.json', '.enums.dart'),
      'lib/resource_scheduler.enums.dart',
    );
  });

  test('configured outputPathFor strips input prefix and applies output prefix', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({
        'input_folder': 'api_specs',
        'output_folder': 'lib/generated',
      }),
    );
    expect(
      config.outputPathFor('api_specs/demo.json', '.models.dart'),
      'lib/generated/demo.models.dart',
    );
    expect(config.baseNameFor('api_specs/demo.json'), 'demo');
  });

  test('captureStem preserves subdirectories under the input folder', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({
        'input_folder': 'api_specs',
        'output_folder': 'lib/generated',
      }),
    );
    expect(config.captureStem('api_specs/v1/demo.json'), 'v1/demo');
    expect(config.baseNameFor('api_specs/v1/demo.json'), 'demo');
    expect(
      config.outputPathFor('api_specs/v1/demo.json', '.models.dart'),
      'lib/generated/v1/demo.models.dart',
    );
  });

  test('nameFromPath is true when method_names is path', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({'method_names': 'path'}),
    );
    expect(config.nameFromPath, isTrue);
  });

  test('nameFromPath defaults to false', () {
    expect(
      BuilderConfig.fromOptions(const BuilderOptions({})).nameFromPath,
      isFalse,
    );
    expect(
      BuilderConfig.fromOptions(
        const BuilderOptions({'method_names': 'operationId'}),
      ).nameFromPath,
      isFalse,
    );
  });

  test('buildExtensions cover json, yaml, and yml inputs', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(config.buildExtensions.keys, containsAll(<String>[
      '{{}}.json',
      '{{}}.yaml',
      '{{}}.yml',
    ]));
  });

  test('outputPathFor strips a yaml or json suffix', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(
      config.outputPathFor('lib/demo.yaml', '.models.dart'),
      'lib/demo.models.dart',
    );
    expect(
      config.outputPathFor('lib/demo.json', '.enums.dart'),
      'lib/demo.enums.dart',
    );
  });

  test('reads override options', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({
        'input_folder': 'lib/specs',
        'output_folder': 'lib/generated',
        'overrides_import': 'package:example/overrides.dart',
        'override_schemas': ['OneOfThing', 'payment_method'],
      }),
    );

    expect(config.overridesImport, 'package:example/overrides.dart');
    expect(config.overrideSchemas, {'OneOfThing', 'payment_method'});
  });

  test('defaults overrides to empty', () {
    final config = BuilderConfig.fromOptions(
      const BuilderOptions({'input_folder': 'lib/specs'}),
    );

    expect(config.overridesImport, isNull);
    expect(config.overrideSchemas, isEmpty);
  });

  test('throws when override_schemas is set without overrides_import', () {
    expect(
      () => BuilderConfig.fromOptions(
        const BuilderOptions({
          'input_folder': 'lib/specs',
          'override_schemas': ['OneOfThing'],
        }),
      ),
      throwsArgumentError,
    );
  });
}
