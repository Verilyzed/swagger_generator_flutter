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

    test('composition: oneOf, discriminator, allOf', () {
      final m = sources['.models.dart']!;
      // a oneOf schema produces no class; a ref to it degrades to dynamic
      expect(m, isNot(contains('class PetOneOf')));
      expect(m, isNot(contains('class PetDiscriminated')));
      expect(m, contains('final dynamic pet;'));
      // allOf inheritance is flattened into one class with merged properties
      expect(m, contains('class Derived {'));
      expect(m, contains('final String id;'));
      expect(m, contains('final String? extra;'));
      expect(m, contains('final Derived? derived;'));
    });

    test('objects, maps, arrays', () {
      final m = sources['.models.dart']!;
      expect(m, contains('final List<dynamic>? untypedArray;'));
      expect(m, contains('final List<List<String>>? arrayOfArrays;'));
      expect(m, contains('final Map<String, List<Map<String, String>>>? deep;'));
      // additionalProperties + properties: kept as a class, map part dropped
      expect(m, contains('class MapAndProps {'));
      expect(m, contains('final String? name;'));
      // additionalProperties-only object becomes an empty class
      expect(m, contains('class FreeMapTrue {'));
      expect(m, contains('const FreeMapTrue();'));
      // recursion and circular refs compile
      expect(m, contains('final List<Tree>? children;'));
      expect(m, contains('final NodeB? b;'));
      expect(m, contains('final NodeA? a;'));
    });

    test('formats map to scalar types', () {
      final m = sources['.models.dart']!;
      expect(m, contains('final String? uuid;'));
      expect(m, contains('final String? byte;')); // base64 -> String (gap)
      expect(m, contains('final int? i64;')); // int64 -> int (web gap)
      expect(m, contains('final double? flt;'));
    });

    test('weird enum values are sanitized and escaped', () {
      final e = sources['.enums.dart']!;
      expect(e, contains('withSpace,'));
      expect(e, contains(r'$1leading,')); // leading digit
      expect(e, contains(r'$class,')); // reserved word
      expect(e, contains('dollar,')); // $ stripped from the identifier
      expect(e, contains('empty,')); // empty string
      expect(e, contains(r"@JsonValue('\$dollar')")); // $ escaped in the value
    });

    test('integer enum uses string JsonValues (gap)', () {
      final e = sources['.enums.dart']!;
      expect(e, contains('enum IntEnum'));
      expect(e, contains(r"@JsonValue('1')")); // string, not the integer 1
    });
  });

  group('edge_cases_v30', () {
    final sources = _gen('edge_cases_v30.json', 'edge30');

    test('generates all files without throwing', () {
      expect(sources['.models.dart'], isNotNull);
    });
  });
}
