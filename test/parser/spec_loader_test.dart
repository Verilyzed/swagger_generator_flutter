import 'package:swagger_generator_flutter/src/parser/spec_loader.dart';
import 'package:test/test.dart';

void main() {
  final loader = SpecLoader();

  test('loads JSON content', () {
    final map = loader.load('{"openapi": "3.1.0"}', path: 'spec.json');
    expect(map['openapi'], '3.1.0');
  });

  test('loads YAML content into plain maps', () {
    final map = loader.load('openapi: 3.1.0\ninfo:\n  title: Demo\n',
        path: 'spec.yaml');
    expect(map['openapi'], '3.1.0');
    expect((map['info'] as Map)['title'], 'Demo');
  });

  test('loads a .yml extension as YAML', () {
    final map = loader.load('openapi: 3.1.0\n', path: 'spec.yml');
    expect(map['openapi'], '3.1.0');
  });

  test('throws FormatException when the root is not an object', () {
    expect(
      () => loader.load('[1, 2, 3]', path: 'spec.json'),
      throwsA(isA<FormatException>()),
    );
  });
}
