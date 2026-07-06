import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('display adds ? for a nullable type', () {
    expect(const DartType('String', isNullable: true).display, 'String?');
  });

  test('display never produces dynamic? for a nullable dynamic', () {
    expect(const DartType('dynamic', isNullable: true).display, 'dynamic');
  });

  test('display leaves a non-nullable type unchanged', () {
    expect(const DartType('String').display, 'String');
  });
}
