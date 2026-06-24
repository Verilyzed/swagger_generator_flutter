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
    expect(out, contains(r'  $unknown,'));
    expect(out, contains('// Fallback for values not present in the spec.'));
    expect(out, contains("import 'package:json_annotation/json_annotation.dart';"));
    expect(out, contains('extension AggregationEnumWire on AggregationEnum {'));
    expect(out, contains('  String get wireValue => const {'));
    expect(out, contains("    AggregationEnum.month: 'month',"));
  });
}
