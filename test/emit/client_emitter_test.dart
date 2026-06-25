import 'package:swagger_generator_flutter/src/emit/client_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:test/test.dart';

void main() {
  final emitter = ClientEmitter();

  test('emits a deserializing converter and registers model factories', () {
    final out = emitter.emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      models: const [
        ModelDef(name: 'Gadget', fields: []),
        ModelDef(name: 'GadgetContainer', fields: []),
      ],
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
      models: const [],
      overrideTypes: const {'OneOfThing'},
      overridesImport: 'package:example/overrides.dart',
    );

    expect(out, contains("import 'package:example/overrides.dart';"));
    expect(out, contains('OneOfThing: OneOfThing.fromJson,'));
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
