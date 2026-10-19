// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:swagger_generator_flutter/src/emit/client_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:test/test.dart';

import '../../example/lib/generated/edge_cases_v31.client.dart' as generated;
import '../../example/lib/generated/edge_cases_v31.models.dart';

String _converterSource(String source) => source.substring(
  source.indexOf('typedef JsonFactory'),
  source.indexOf('ChopperClient createClient('),
);

Response<String> _response(String body, {Object? error}) {
  final base = http.Response(
    body,
    200,
    headers: {'content-type': 'application/json', 'x-request-id': 'test'},
    request: http.Request('GET', Uri.parse('https://example.test/ping')),
  );
  return Response(base, base.body, error: error);
}

void main() {
  const converter = generated.JsonSerializableConverter({Ping: Ping.fromJson});

  test('bundled converter snapshots match the current emitter', () {
    final source = ClientEmitter().emitClient(
      const ServiceDef(name: 'DemoService', operations: []),
      serviceImport: 'demo.service.dart',
      modelsImport: 'demo.models.dart',
      enumsImport: 'demo.enums.dart',
      models: const [],
      enumNames: const {},
    );

    for (final name in [
      'edge_cases_v30',
      'edge_cases_v31',
      'newapi',
      'resource_scheduler',
    ]) {
      final snapshot = File(
        'example/lib/generated/$name.client.dart',
      ).readAsStringSync();
      expect(
        _converterSource(snapshot),
        _converterSource(source),
        reason: name,
      );
    }
  });

  group('generated JsonSerializableConverter', () {
    for (final entry in {
      'JSON null': 'null',
      'JSON null with whitespace': ' \nnull\t ',
      'empty body': '',
      'whitespace-only body': ' \n\t ',
    }.entries) {
      test('${entry.key} becomes a null model body', () async {
        final result = await converter.convertResponse<Ping?, Ping>(
          _response(entry.value),
        );

        expect(result.body, isNull);
        expect(result.isSuccessful, isTrue);
      });

      test('${entry.key} becomes a null dynamic body', () async {
        final result = await converter.convertResponse<dynamic, dynamic>(
          _response(entry.value),
        );

        expect(result.body, isNull);
      });
    }

    test('maps a JSON object to a model', () async {
      final result = await converter.convertResponse<Ping, Ping>(
        _response('{"id":"ping-1"}'),
      );

      expect(result.body, isA<Ping>());
      expect(result.body!.id, 'ping-1');
    });

    test('maps a JSON array to a model list', () async {
      final result = await converter.convertResponse<List<Ping>, Ping>(
        _response('[{"id":"ping-1"},{"id":"ping-2"}]'),
      );

      expect(result.body, isA<List<Ping>>());
      expect(result.body!.map((model) => model.id), ['ping-1', 'ping-2']);
    });

    test('preserves a JSON string literal containing null', () async {
      final result = await converter.convertResponse<String, String>(
        _response('"null"'),
      );

      expect(result.body, 'null');
    });

    test('preserves an empty JSON string literal', () async {
      final result = await converter.convertResponse<String, String>(
        _response('""'),
      );

      expect(result.body, '');
    });

    test('preserves a JSON string', () async {
      final result = await converter.convertResponse<String, String>(
        _response('"hello"'),
      );

      expect(result.body, 'hello');
    });

    test('preserves a JSON integer', () async {
      final result = await converter.convertResponse<int, int>(_response('42'));

      expect(result.body, 42);
    });

    test('preserves a JSON boolean', () async {
      final result = await converter.convertResponse<bool, bool>(
        _response('false'),
      );

      expect(result.body, isFalse);
    });

    test('preserves a dynamic scalar response', () async {
      final result = await converter.convertResponse<dynamic, dynamic>(
        _response('42'),
      );

      expect(result.body, 42);
    });

    for (final body in ['null', '', '{"id":"ping-1"}']) {
      test('preserves response metadata for $body', () async {
        final error = Object();
        final original = _response(body, error: error);
        final result = await converter.convertResponse<Ping?, Ping>(original);

        expect(result.base, same(original.base));
        expect(result.statusCode, original.statusCode);
        expect(result.headers, original.headers);
        expect(result.base.request, same(original.base.request));
        expect(result.error, same(error));
      });
    }

    test('returns JSON null through the Chopper HTTP pipeline', () async {
      final client = ChopperClient(
        baseUrl: Uri.parse('https://example.test'),
        client: MockClient(
          (_) async => http.Response(
            'null',
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
        converter: converter,
      );
      addTearDown(client.dispose);

      final result = await client.send<Ping?, Ping>(
        Request('GET', Uri.parse('/ping'), client.baseUrl),
      );

      expect(result.body, isNull);
      expect(result.statusCode, 200);
    });

    for (final status in [400, 500]) {
      for (final convertErrors in [false, true]) {
        test(
          '$status preserves error handling (converter: $convertErrors)',
          () async {
            const body = '{"message":"failed"}';
            final base = http.Response(
              body,
              status,
              headers: {'content-type': 'application/json'},
            );
            final client = ChopperClient(
              baseUrl: Uri.parse('https://example.test'),
              client: MockClient((_) async => base),
              converter: converter,
              errorConverter: convertErrors ? converter : null,
            );
            addTearDown(client.dispose);

            final result = await client.send<Ping?, Ping>(
              Request('GET', Uri.parse('/ping'), client.baseUrl),
            );

            expect(result.isSuccessful, isFalse);
            expect(result.statusCode, status);
            expect(result.body, isNull);
            expect(result.bodyString, body);
            expect(result.headers, base.headers);
            expect(result.error, convertErrors ? {'message': 'failed'} : body);
          },
        );
      }
    }
  });
}
