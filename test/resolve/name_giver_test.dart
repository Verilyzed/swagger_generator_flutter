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

  test('memberName escapes reserved words with a dollar prefix', () {
    expect(names.memberName('class'), r'$class');
    expect(names.memberName('default'), r'$default');
  });

  test('memberName escapes Object member names with a dollar prefix', () {
    expect(names.memberName('hashCode'), r'$hashCode');
    expect(names.memberName('runtime_type'), r'$runtimeType');
  });

  test('memberName prefixes a leading-digit name with a dollar', () {
    expect(names.memberName('1leading'), r'$1leading');
    expect(names.memberName('123'), r'$123');
  });

  test('memberName leaves enum-only collisions untouched', () {
    expect(names.memberName('index'), 'index');
    expect(names.memberName('values'), 'values');
  });

  test('enumValueName escapes implicit enum members with a dollar prefix', () {
    expect(names.enumValueName('index'), r'$index');
    expect(names.enumValueName('values'), r'$values');
    expect(names.enumValueName('hashCode'), r'$hashCode');
    expect(names.enumValueName('runtime_type'), r'$runtimeType');
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

  test('uniqueClassName returns the same name for the same raw input', () {
    final giver = NameGiver();
    expect(giver.uniqueClassName('Verbrauchsart'), 'Verbrauchsart');
    expect(giver.uniqueClassName('Verbrauchsart'), 'Verbrauchsart');
  });

  test('uniqueClassName suffixes a colliding class name', () {
    final giver = NameGiver();
    expect(giver.uniqueClassName('Verbrauchsart'), 'Verbrauchsart');
    expect(giver.uniqueClassName('verbrauchsart'), 'Verbrauchsart2');
  });

  test('uniqueClassName keeps counting for repeated collisions', () {
    final giver = NameGiver();
    expect(giver.uniqueClassName('Status'), 'Status');
    expect(giver.uniqueClassName('status'), 'Status2');
    expect(giver.uniqueClassName('STATUS'), 'Status3');
  });

  test('uniqueClassName leaves non-colliding names untouched', () {
    final giver = NameGiver();
    expect(giver.uniqueClassName('Kunde'), 'Kunde');
    expect(giver.uniqueClassName('Adresse'), 'Adresse');
  });

  test('uniqueClassName applies the Chopper suffix before uniquifying', () {
    final giver = NameGiver();
    expect(giver.uniqueClassName('Field'), 'FieldModel');
    expect(giver.uniqueClassName('field'), 'FieldModel2');
  });
}
