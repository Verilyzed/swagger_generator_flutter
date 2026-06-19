import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('DartType renders nullable display', () {
    expect(const DartType('Task').display, 'Task');
    expect(const DartType('Task', isNullable: true).display, 'Task?');
  });

  test('ApiSpec holds enums, models and a service', () {
    const spec = ApiSpec(
      name: 'demo',
      enums: [
        EnumDef(
          name: 'AggregationEnum',
          values: [EnumValueDef(dartName: 'month', jsonValue: 'month')],
        ),
      ],
      models: [
        ModelDef(
          name: 'Task',
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
      service: ServiceDef(name: 'DemoService', operations: []),
    );

    expect(spec.enums.single.name, 'AggregationEnum');
    expect(spec.models.single.fields.single.dartName, 'id');
    expect(spec.service.name, 'DemoService');
  });
}
