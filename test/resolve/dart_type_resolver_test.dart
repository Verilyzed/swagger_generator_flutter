import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

void main() {
  final resolver = OpenApi31TypeResolver(NameGiver());

  test('maps primitive types', () {
    expect(resolver.resolve({'type': 'string'}).display, 'String');
    expect(resolver.resolve({'type': 'integer'}).display, 'int');
    expect(resolver.resolve({'type': 'number'}).display, 'num');
    expect(resolver.resolve({'type': 'boolean'}).display, 'bool');
  });

  test('maps date-time format to DateTime', () {
    expect(
      resolver.resolve({'type': 'string', 'format': 'date-time'}).display,
      'DateTime',
    );
  });

  test('maps date format to a date-only DateTime', () {
    final t = resolver.resolve({'type': 'string', 'format': 'date'});
    expect(t.name, 'DateTime');
    expect(t.isDateOnly, isTrue);
  });

  test('keeps a date with an example as a String', () {
    final t = resolver.resolve({
      'type': 'string',
      'format': 'date',
      'example': '2025-04-20',
    });
    expect(t.name, 'String');
    expect(t.isDateOnly, isFalse);
  });

  test('keeps isDateOnly when a date field is nullable', () {
    final t = resolver.resolve({
      'type': ['string', 'null'],
      'format': 'date',
    });
    expect(t.name, 'DateTime');
    expect(t.isNullable, isTrue);
    expect(t.isDateOnly, isTrue);
  });

  test('date-time is not flagged date-only', () {
    final t = resolver.resolve({'type': 'string', 'format': 'date-time'});
    expect(t.name, 'DateTime');
    expect(t.isDateOnly, isFalse);
  });

  test('OpenApi30 treats anyOf ref+null as a nullable type', () {
    final r = OpenApi30TypeResolver(
      NameGiver(),
      schemas: {
        'Bar': {
          'type': 'object',
          'properties': {'x': {'type': 'string'}},
        },
      },
    );
    final t = r.resolve({
      'anyOf': [
        {r'$ref': '#/components/schemas/Bar'},
        {'type': 'null'},
      ],
    });
    expect(t.name, 'Bar');
    expect(t.isNullable, isTrue);
  });

  test('resolves a ref to an override to its Dart type', () {
    final r = OpenApi31TypeResolver(
      NameGiver(),
      schemas: {
        'OneOfThing': {
          'oneOf': [
            {r'$ref': '#/components/schemas/A'},
            {r'$ref': '#/components/schemas/B'},
          ],
        },
      },
      overrides: {'OneOfThing'},
    );

    expect(
      r.resolve({r'$ref': '#/components/schemas/OneOfThing'}).name,
      'OneOfThing',
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
    expect(t.display, 'num?');
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

  test('resolves a ref to an array alias as a List', () {
    final r = OpenApi31TypeResolver(
      NameGiver(),
      schemas: {
        'Patch': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
    );
    expect(
      r.resolve({r'$ref': '#/components/schemas/Patch'}).display,
      'List<String>',
    );
  });

  test('keeps a ref to an object schema as a class name', () {
    final r = OpenApi31TypeResolver(
      NameGiver(),
      schemas: {
        'Task': {'type': 'object', 'properties': <String, dynamic>{}},
      },
    );
    expect(
      r.resolve({r'$ref': '#/components/schemas/Task'}).display,
      'Task',
    );
  });
}
