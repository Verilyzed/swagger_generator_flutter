import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:swagger_generator_flutter/src/resolve/resolver_factory.dart';
import 'package:test/test.dart';

void main() {
  final names = NameGiver();

  test('selects the 3.0 resolver for 3.0.x', () {
    expect(resolverForVersion('3.0.2', names), isA<OpenApi30TypeResolver>());
  });

  test('selects the 3.1 resolver for 3.1.x and unknown', () {
    expect(resolverForVersion('3.1.0', names), isA<OpenApi31TypeResolver>());
    expect(resolverForVersion(null, names), isA<OpenApi31TypeResolver>());
  });
}
