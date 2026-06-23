import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

void main() {
  final names = NameGiver();

  test('className produces PascalCase', () {
    expect(names.className('asset_state'), 'AssetState');
    expect(names.className('AggregationEnum'), 'AggregationEnum');
    expect(names.className('HTTP validation error'), 'HttpValidationError');
  });

  test('memberName produces camelCase', () {
    expect(names.memberName('asset_id'), 'assetId');
    expect(names.memberName('id'), 'id');
    expect(names.memberName('target-date'), 'targetDate');
  });

  test('memberName escapes reserved words', () {
    expect(names.memberName('class'), 'class_');
    expect(names.memberName('default'), 'default_');
  });

  test('enumValueName handles values that start with a digit', () {
    expect(names.enumValueName('2xx'), r'$2xx');
    expect(names.enumValueName('month'), 'month');
  });

  test('className splits acronym runs', () {
    expect(names.className('APIRequest'), 'ApiRequest');
    expect(names.className('HTTPValidationError'), 'HttpValidationError');
    expect(names.className('FullItem'), 'FullItem');
  });

  test('className renames Chopper-colliding names', () {
    expect(names.className('Field'), 'FieldModel');
    expect(names.className('Response'), 'ResponseModel');
    expect(names.className('Patch'), 'PatchModel');
    expect(names.className('Vault'), 'Vault');
  });

  test('enumValueName avoids the wildcard for empty values', () {
    expect(names.enumValueName(''), 'empty');
  });
}
