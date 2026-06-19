import 'package:swagger_generator_flutter/src/emit/model_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('emits a JsonSerializable class with mapped keys', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Task',
          fields: [
            FieldDef(
              dartName: 'id',
              jsonKey: 'id',
              type: DartType('String'),
              isRequired: true,
            ),
            FieldDef(
              dartName: 'assetId',
              jsonKey: 'asset_id',
              type: DartType('String'),
              isRequired: true,
            ),
            FieldDef(
              dartName: 'costs',
              jsonKey: 'costs',
              type: DartType('double', isNullable: true),
              isRequired: false,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
    );

    expect(out, contains("part 'demo.models.g.dart';"));
    expect(out, contains('@JsonSerializable()'));
    expect(out, contains('class Task {'));
    expect(out, contains("@JsonKey(name: 'asset_id')"));
    expect(out, contains('final String assetId;'));
    expect(out, contains('final double? costs;'));
    expect(out, contains('required this.id'));
    expect(out, contains('factory Task.fromJson(Map<String, dynamic> json) =>'));
    expect(out, contains('Map<String, dynamic> toJson() => _\$TaskToJson(this);'));
  });
}
