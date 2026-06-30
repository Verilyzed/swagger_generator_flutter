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

  test('maps date format to String', () {
    expect(
      resolver.resolve({'type': 'string', 'format': 'date'}).display,
      'String',
    );
  });

  test('maps a date with an example to String', () {
    expect(
      resolver.resolve({
        'type': 'string',
        'format': 'date',
        'example': '2025-04-20',
      }).display,
      'String',
    );
  });

  test('maps a nullable date to a nullable String', () {
    final t = resolver.resolve({
      'type': ['string', 'null'],
      'format': 'date',
    });
    expect(t.display, 'String?');
    expect(t.isNullable, isTrue);
  });

  test('resolves a single-item allOf to that item', () {
    expect(
      resolver.resolve({
        'allOf': [
          {r'$ref': '#/components/schemas/Bar'},
        ],
      }).name,
      'Bar',
    );
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

  test('uses a propertyNames enum ref as the map key type', () {
    final r = OpenApi31TypeResolver(
      NameGiver(),
      schemas: {
        'Weekday': {'type': 'string', 'enum': ['Monday', 'Tuesday']},
        'DepartureSchedule': {
          'type': 'object',
          'properties': {'targetTime': {'type': 'string'}},
        },
      },
    );
    final t = r.resolve({
      'type': 'object',
      'additionalProperties': {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/DepartureSchedule'},
      },
      'propertyNames': {r'$ref': '#/components/schemas/Weekday'},
    });
    expect(t.display, 'Map<Weekday, List<DepartureSchedule>>');
  });

  test('keeps a String map key when propertyNames is not an enum ref', () {
    final t = resolver.resolve({
      'type': 'object',
      'additionalProperties': {'type': 'string'},
      'propertyNames': {'type': 'string', 'pattern': r'^[a-z]+$'},
    });
    expect(t.display, 'Map<String, String>');
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

  test('3.0 propagates nullable through a ref to a nullable schema', () {
    final r = OpenApi30TypeResolver(
      NameGiver(),
      schemas: {
        'KundeTitel': {
          'type': 'string',
          'enum': ['Prof.', 'Dr.'],
          'nullable': true,
        },
      },
    );
    final t = r.resolve({r'$ref': '#/components/schemas/KundeTitel'});
    expect(t.name, 'KundeTitel');
    expect(t.isNullable, isTrue);
    expect(t.display, 'KundeTitel?');
  });

  test('a ref to a non-nullable schema stays non-nullable', () {
    final r = OpenApi30TypeResolver(
      NameGiver(),
      schemas: {
        'KundeAnrede': {
          'type': 'string',
          'enum': ['Herr', 'Frau'],
        },
      },
    );
    final t = r.resolve({r'$ref': '#/components/schemas/KundeAnrede'});
    expect(t.isNullable, isFalse);
    expect(t.display, 'KundeAnrede');
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
