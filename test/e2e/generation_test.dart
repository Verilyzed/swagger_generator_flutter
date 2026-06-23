import 'dart:io';

import 'package:swagger_generator_flutter/src/builder/swagger_builder.dart';
import 'package:test/test.dart';

void main() {
  test('generates all files from the bundled spec without throwing', () {
    final file = File('example/lib/specs/resource_scheduler.json');
    final content = file.readAsStringSync();

    final sources = generateSources(
      content,
      path: file.path,
      baseName: 'resource_scheduler',
    );

    expect(sources['.enums.dart'], contains('enum AggregationEnum {'));
    expect(sources['.models.dart'], contains('class Task {'));
    expect(
      sources['.service.dart'],
      contains('class ResourceSchedulerService extends ChopperService {'),
    );
    expect(sources['.api.dart'], contains("export 'resource_scheduler.enums.dart';"));

    for (final source in sources.values) {
      expect(source, startsWith('// GENERATED CODE'));
    }
  });
}
