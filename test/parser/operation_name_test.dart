import 'package:swagger_generator_flutter/src/parser/operation_name.dart';
import 'package:test/test.dart';

void main() {
  test('uses operationId by default', () {
    expect(
      operationBaseName(
        httpMethod: 'GET',
        path: '/x',
        operationId: 'getX',
        nameFromPath: false,
      ),
      'getX',
    );
  });

  test('falls back to verb and path without an operationId', () {
    expect(
      operationBaseName(
        httpMethod: 'POST',
        path: '/x/{id}',
        nameFromPath: false,
      ),
      'post_/x/{id}',
    );
  });

  test('uses verb and path when nameFromPath is true', () {
    expect(
      operationBaseName(
        httpMethod: 'GET',
        path: '/x',
        operationId: 'getX',
        nameFromPath: true,
      ),
      'get_/x',
    );
  });
}
