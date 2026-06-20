import 'package:swagger_generator_flutter/src/emit/client_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:test/test.dart';

void main() {
  final emitter = ClientEmitter();

  test('emits a ChopperClient factory with the service', () {
    final out = emitter.emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
    );

    expect(out, contains("import 'package:chopper/chopper.dart';"));
    expect(out, contains('ChopperClient createClient('));
    expect(out, contains('DemoService.create('));
    expect(out, contains('converter: const JsonConverter()'));
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
