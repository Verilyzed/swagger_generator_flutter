import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

void main() {
  final resolver = DartTypeResolver(NameGiver());

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
}
