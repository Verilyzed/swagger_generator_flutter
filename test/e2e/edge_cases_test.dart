import 'dart:io';

import 'package:swagger_generator_flutter/src/builder/swagger_builder.dart';
import 'package:test/test.dart';

Map<String, String> _gen(String file, String base) {
  final content = File('example/lib/specs/$file').readAsStringSync();
  return generateSources(
    content,
    path: 'example/lib/specs/$file',
    baseName: base,
  );
}

void main() {
  group('edge_cases_v31', () {
    final sources = _gen('edge_cases_v31.json', 'edge31');

    test('generates all files without throwing', () {
      expect(sources['.models.dart'], isNotNull);
    });
  });

  group('edge_cases_v30', () {
    final sources = _gen('edge_cases_v30.json', 'edge30');

    test('generates all files without throwing', () {
      expect(sources['.models.dart'], isNotNull);
    });
  });
}
