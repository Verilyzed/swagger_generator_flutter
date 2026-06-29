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
      enumNames: const {},
    );

    expect(out, contains("part 'demo.models.g.dart';"));
    expect(out, contains('@JsonSerializable()'));
    expect(out, contains('class Task {'));
    expect(out, contains("@JsonKey(name: 'asset_id')"));
    expect(out, contains('final String assetId;'));
    expect(out, contains('final double? costs;'));
    expect(out, contains('required this.id'));
    expect(out, contains('const Task({'));
    expect(out, contains('factory Task.fromJson(Map<String, dynamic> json) =>'));
    expect(out, contains('Map<String, dynamic> toJson() => _\$TaskToJson(this);'));
  });

  test('non-nullable non-required field without default becomes required', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Thing',
          fields: [
            FieldDef(
              dartName: 'title',
              jsonKey: 'title',
              type: DartType('String'),
              isRequired: false,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(out, contains('required this.title'));
  });

  test('field with a default value stays optional with the default', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Thing',
          fields: [
            FieldDef(
              dartName: 'type',
              jsonKey: 'type',
              type: DartType('String'),
              isRequired: false,
              defaultValue: "'COST_OPTIMIZED'",
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(out, contains("this.type = 'COST_OPTIMIZED'"));
    expect(out, isNot(contains('required this.type')));
  });

  test('a required field that also has a default is not emitted as required', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Thing',
          fields: [
            FieldDef(
              dartName: 'mode',
              jsonKey: 'mode',
              type: DartType('String'),
              isRequired: true,
              defaultValue: "'auto'",
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(out, contains("this.mode = 'auto'"));
    expect(out, isNot(contains('required this.mode')));
  });

  test('adds unknownEnumValue to an enum field', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Item',
          fields: [
            FieldDef(
              dartName: 'category',
              jsonKey: 'category',
              type: DartType('ItemCategory'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {'ItemCategory'},
    );

    expect(out, contains(r'@JsonKey(unknownEnumValue: ItemCategory.$unknown)'));
  });

  test('merges name and unknownEnumValue for a renamed enum field', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Item',
          fields: [
            FieldDef(
              dartName: 'errorCode',
              jsonKey: 'error_code',
              type: DartType('ErrorCode'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {'ErrorCode'},
    );

    expect(
      out,
      contains(
        r"@JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)",
      ),
    );
  });

  test('emits DateConverter and annotates a date field', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Event',
          fields: [
            FieldDef(
              dartName: 'occurredAt',
              jsonKey: 'occurred_at',
              type: DartType('DateTime', isNullable: true, isDateOnly: true),
              isRequired: false,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(
      out,
      contains('class DateConverter implements JsonConverter<DateTime, String> {'),
    );
    expect(out, contains("object.toIso8601String().split('T').first"));
    expect(out, contains('@DateConverter()'));
    expect(out, contains('final DateTime? occurredAt;'));
  });

  test('imports the overrides file when a field uses an override type', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Foo',
          fields: [
            FieldDef(
              dartName: 'thing',
              jsonKey: 'thing',
              type: DartType('OneOfThing'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, contains("import 'package:example/overrides.dart';"));
    expect(out, contains('final OneOfThing thing;'));
  });

  test('omits the overrides import when no field uses an override', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Foo',
          fields: [
            FieldDef(
              dartName: 'id',
              jsonKey: 'id',
              type: DartType('String'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, isNot(contains('package:example/overrides.dart')));
  });

  test('omits DateConverter when no date field exists', () {
    final out = ModelEmitter().emit(
      const [
        ModelDef(
          name: 'Plain',
          fields: [
            FieldDef(
              dartName: 'id',
              jsonKey: 'id',
              type: DartType('String'),
              isRequired: true,
            ),
          ],
        ),
      ],
      partFileName: 'demo.models.g.dart',
      enumsImport: 'demo.enums.dart',
      enumNames: const {},
    );

    expect(out, isNot(contains('DateConverter')));
  });
}
