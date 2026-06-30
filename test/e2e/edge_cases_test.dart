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

    test('type-shape mappings', () {
      final m = sources['.models.dart']!;
      expect(m, contains('final String? strOrNull;'));
      // multi non-null type array degrades to dynamic (gap)
      expect(m, contains('final dynamic strOrInt;'));
      expect(m, contains('final String? anyOfNull;'));
    });
  });

  // Carved out of the example spec: generates analyzer-flagged code. Locked in
  // here at the source level to track the behavior. See EDGE_CASE_GAPS.md.
  group('edge_cases_v31 gaps', () {
    test('multi-type with null produces invalid dynamic?', () {
      const spec = '''
{
  "openapi": "3.1.0",
  "info": {"title": "t", "version": "1"},
  "components": {"schemas": {"X": {"type": "object", "properties": {
    "v": {"type": ["string", "integer", "null"]}
  }}}},
  "paths": {}
}
''';
      final m = generateSources(spec, path: 'x.json', baseName: 'x')['.models.dart'];
      expect(m, contains('final dynamic? v;'));
    });
  });

  group('edge_cases_v30', () {
    final sources = _gen('edge_cases_v30.json', 'edge30');

    test('generates all files without throwing', () {
      expect(sources['.models.dart'], isNotNull);
    });
  });
}
