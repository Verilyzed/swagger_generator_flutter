import 'package:swagger_generator_flutter/src/emit/service_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('emits required path positional and optional query named', () {
    final out = ServiceEmitter().emit(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'listGadgets',
            httpMethod: 'GET',
            path: '/gadgets',
            parameters: [
              ParamDef(
                dartName: 'limit',
                wireName: 'limit',
                type: DartType('int'),
                location: ParamLocation.query,
                defaultValue: '50',
              ),
              ParamDef(
                dartName: 'status',
                wireName: 'status',
                type: DartType('StatusEnum', isNullable: true),
                location: ParamLocation.query,
              ),
            ],
            responseType: DartType('List<Gadget>'),
          ),
          OperationDef(
            methodName: 'getGadget',
            httpMethod: 'GET',
            path: '/gadgets/{gadget_id}',
            parameters: [
              ParamDef(
                dartName: 'gadgetId',
                wireName: 'gadget_id',
                type: DartType('String'),
                location: ParamLocation.path,
                isRequired: true,
              ),
            ],
            responseType: DartType('Gadget'),
          ),
        ],
      ),
      partFileName: 'demo.service.chopper.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
    );

    expect(out, contains('Future<Response<List<Gadget>>> listGadgets({'));
    expect(out, contains("@Query('limit') int limit = 50,"));
    expect(out, contains("@Query('status') StatusEnum? status,"));
    expect(out, contains("@Path('gadget_id') String gadgetId,"));
    expect(out, isNot(contains('listGadgets(@Query')));
  });
}
