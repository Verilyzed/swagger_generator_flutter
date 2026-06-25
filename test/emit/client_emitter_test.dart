import 'package:swagger_generator_flutter/src/emit/client_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  final emitter = ClientEmitter();

  test('emits a deserializing converter and registers model factories', () {
    final out = emitter.emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      models: const [
        ModelDef(name: 'Gadget', fields: []),
        ModelDef(name: 'GadgetContainer', fields: []),
      ],
      enumNames: const {},
    );

    expect(out, contains("import 'demo.models.dart';"));
    expect(
      out,
      contains('class JsonSerializableConverter extends JsonConverter {'),
    );
    expect(
      out,
      contains('Future<Response<ResultType>> convertResponse<ResultType, Inner>('),
    );
    expect(out, contains('converter: const JsonSerializableConverter({'));
    expect(out, contains('Gadget: Gadget.fromJson,'));
    expect(out, contains('GadgetContainer: GadgetContainer.fromJson,'));
    expect(out, contains('services: [DemoService.create()],'));
    expect(out, contains("import 'package:http/http.dart' show Client;"));
    expect(out, contains('  Client? httpClient,'));
    expect(out, contains('  Authenticator? authenticator,'));
    expect(out, contains('    client: httpClient,'));
    expect(out, contains('    authenticator: authenticator,'));
  });

  test('registers an override type in the factory map', () {
    final out = emitter.emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      models: const [],
      enumNames: const {},
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, contains("import 'package:example/overrides.dart';"));
    expect(out, contains('OneOfThing: OneOfThing.fromJson,'));
  });

  test('emits a facade with direct-parameter and fromClient constructors', () {
    final out = emitter.emitClient(
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
            ],
            responseType: DartType('List<Gadget>'),
          ),
        ],
      ),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      models: const [ModelDef(name: 'Gadget', fields: [])],
      enumNames: const {},
    );

    expect(out, contains('class DemoApi {'));
    expect(out, contains('  DemoApi({'));
    expect(out, contains('    required Uri baseUrl,'));
    expect(out, contains('    Client? httpClient,'));
    expect(out, contains('    Authenticator? authenticator,'));
    expect(out, contains('  }) : this.fromClient(createClient('));
    expect(out, contains('  DemoApi.fromClient(ChopperClient client)'));
    expect(out, contains('      : _service = DemoService.create(client);'));
    expect(out, contains('      limit: limit ?? 50,'));
  });

  test('imports enums when a facade signature uses an enum', () {
    final out = emitter.emitClient(
      const ServiceDef(
        name: 'DemoService',
        operations: [
          OperationDef(
            methodName: 'listGadgets',
            httpMethod: 'GET',
            path: '/gadgets',
            parameters: [
              ParamDef(
                dartName: 'status',
                wireName: 'status',
                type: DartType('StatusEnum', isNullable: true),
                location: ParamLocation.query,
              ),
            ],
            responseType: DartType('dynamic'),
          ),
        ],
      ),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      models: const [],
      enumNames: const {'StatusEnum'},
    );

    expect(out, contains("import 'demo.enums.dart';"));
  });

  test('emits a barrel of exports', () {
    final out = emitter.emitBarrel(
      enumsImport: 'demo.enums.dart',
      modelsImport: 'demo.models.dart',
      serviceImport: 'demo.service.dart',
      clientImport: 'demo.client.dart',
    );

    expect(out, contains("export 'demo.enums.dart';"));
    expect(out, contains("export 'demo.models.dart';"));
    expect(out, contains("export 'demo.service.dart';"));
    expect(out, contains("export 'demo.client.dart';"));
  });
}
