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
}
