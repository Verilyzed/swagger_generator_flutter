import 'package:build/build.dart';
import 'package:swagger_generator_flutter/src/builder/builder_config.dart';
import 'package:test/test.dart';

void main() {
  test('defaults to co-located when no options are given', () {
    final config = BuilderConfig.fromOptions(const BuilderOptions({}));
    expect(config.inputFolder, '');
    expect(config.outputFolder, '');
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
}
