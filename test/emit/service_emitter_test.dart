import 'package:swagger_generator_flutter/src/emit/service_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  test('emits a Chopper service with annotated methods', () {
    final out = ServiceEmitter().emit(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'getScheduleForAsset',
            httpMethod: 'GET',
            path: '/assets/{asset_id}/schedule',
            parameters: [
              ParamDef(
                dartName: 'assetId',
                wireName: 'asset_id',
                type: DartType('String'),
                location: ParamLocation.path,
              ),
            ],
            responseType: DartType('Schedule'),
          ),
        ],
      ),
      partFileName: 'demo.service.chopper.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
    );

    expect(out, contains("import 'package:chopper/chopper.dart';"));
    expect(out, contains("part 'demo.service.chopper.dart';"));
    expect(out, contains("@ChopperApi(baseUrl: '')"));
    expect(out, contains('abstract class DemoService extends ChopperService {'));
    expect(out, contains("@GET(path: '/assets/{asset_id}/schedule')"));
    expect(out, contains('Future<Response<Schedule>> getScheduleForAsset('));
    expect(out, contains("@Path('asset_id') String assetId"));
    expect(out, contains('static DemoService create([ChopperClient? client]) =>'));
  });
}
