import 'package:swagger_generator_flutter/src/emit/enum_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:test/test.dart';

void main() {
  test('emits an enum with JsonValue annotations', () {
    final out = EnumEmitter().emit(const [
      EnumDef(
        name: 'AggregationEnum',
        values: [
          EnumValueDef(dartName: 'month', jsonValue: 'month'),
          EnumValueDef(dartName: 'year', jsonValue: 'year'),
        ],
      ),
    ]);

    expect(out, contains('enum AggregationEnum {'));
    expect(out, contains("@JsonValue('month')"));
    expect(out, contains('month,'));
    expect(out, contains(r'  $unknown;'));
    expect(out, contains('// Fallback for values not present in the spec.'));
    expect(
      out,
      contains("import 'package:json_annotation/json_annotation.dart';"),
    );
    expect(out, contains('  @override'));
    expect(out, contains('  String toString() => const {'));
    expect(out, contains("        AggregationEnum.month: 'month',"));
  });

  test('escapes a dollar sign in an enum value', () {
    final out = EnumEmitter().emit(const [
      EnumDef(
        name: 'E',
        values: [EnumValueDef(dartName: 'dollar', jsonValue: r'$dollar')],
      ),
    ]);

    expect(out, contains(r"@JsonValue('\$dollar')"));
    expect(out, contains(r"E.dollar: '\$dollar',"));
  });

  test('emits integer and boolean values as typed JsonValues', () {
    final out = EnumEmitter().emit(const [
      EnumDef(
        name: 'IntEnum',
        values: [EnumValueDef(dartName: r'$1', jsonValue: 1)],
      ),
      EnumDef(
        name: 'BoolEnum',
        values: [EnumValueDef(dartName: r'$true', jsonValue: true)],
      ),
    ]);

    expect(out, contains('@JsonValue(1)'));
    expect(out, contains('@JsonValue(true)'));
    expect(out, contains(r"IntEnum.$1: '1',"));
    expect(out, contains(r"BoolEnum.$true: 'true',"));
  });
}
