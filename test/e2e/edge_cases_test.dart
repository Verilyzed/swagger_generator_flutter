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
      // multi non-null type arrays degrade to dynamic (gap), never dynamic?
      expect(m, contains('final dynamic strOrInt;'));
      expect(m, contains('final dynamic strOrIntOrNull;'));
      expect(m, isNot(contains('dynamic?')));
      expect(m, contains('final String? anyOfNull;'));
    });

    test('3.1-only constructs degrade or are ignored', () {
      final m = sources['.models.dart']!;
      expect(m, contains('final List<dynamic>? tuple;')); // prefixItems ignored
      expect(m, contains('final dynamic constField;')); // const, no type
      expect(m, contains('final String? constTyped;')); // const ignored, type kept
      expect(m, contains('final dynamic emptySchema;')); // {} -> dynamic
      expect(m, contains('final String? exampledField;')); // examples ignored
    });

    test('webhooks produce no operation', () {
      expect(sources['.service.dart'], isNot(contains('@POST')));
    });
  });

  group('edge_cases_v30', () {
    final sources = _gen('edge_cases_v30.json', 'edge30');

    test('generates all files without throwing', () {
      expect(sources['.models.dart'], isNotNull);
    });
  });
}
