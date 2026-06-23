import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

void main() {
  final resolver = OpenApi31TypeResolver(NameGiver());

  test('maps primitive types', () {
    expect(resolver.resolve({'type': 'string'}).display, 'String');
    expect(resolver.resolve({'type': 'integer'}).display, 'int');
    expect(resolver.resolve({'type': 'number'}).display, 'double');
    expect(resolver.resolve({'type': 'boolean'}).display, 'bool');
  });

  test('maps date-time format to DateTime', () {
    expect(
      resolver.resolve({'type': 'string', 'format': 'date-time'}).display,
      'DateTime',
    );
  });

  test('resolves a ref to the class name', () {
    expect(
      resolver.resolve({r'$ref': '#/components/schemas/Task'}).display,
      'Task',
    );
  });

  test('maps arrays to List of item type', () {
    expect(
      resolver.resolve({
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/Task'},
      }).display,
      'List<Task>',
    );
  });

  test('anyOf with null becomes nullable', () {
    final t = resolver.resolve({
      'anyOf': [
        {'type': 'number'},
        {'type': 'null'},
      ],
    });
    expect(t.display, 'double?');
    expect(t.isNullable, isTrue);
  });

  test('anyOf with a ref and null becomes a nullable class', () {
    final t = resolver.resolve({
      'anyOf': [
        {r'$ref': '#/components/schemas/FailureReason'},
        {'type': 'null'},
      ],
    });
    expect(t.display, 'FailureReason?');
    expect(t.isNullable, isTrue);
  });

  test('object with additionalProperties maps to a typed Map', () {
    expect(
      resolver
          .resolve({'type': 'object', 'additionalProperties': {'type': 'string'}})
          .display,
      'Map<String, String>',
    );
  });

  test('bare object maps to Map<String, dynamic>', () {
    expect(resolver.resolve({'type': 'object'}).display, 'Map<String, dynamic>');
  });

  test('3.1 resolver maps type array with null to nullable', () {
    expect(
      OpenApi31TypeResolver(NameGiver())
          .resolve({
            'type': ['string', 'null'],
          })
          .display,
      'String?',
    );
  });

  test('3.0 resolver reads nullable true', () {
    final r = OpenApi30TypeResolver(NameGiver());
    expect(r.resolve({'type': 'string', 'nullable': true}).display, 'String?');
    expect(r.resolve({'type': 'string'}).display, 'String');
  });
}
