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
      contains('Response<ResultType> convertResponse<ResultType, Item>('),
    );
    expect(out, contains('converter: const JsonSerializableConverter({'));
    expect(out, contains('Gadget: Gadget.fromJson,'));
    expect(out, contains('GadgetContainer: GadgetContainer.fromJson,'));
    expect(out, contains('services: [DemoService.create()],'));
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
