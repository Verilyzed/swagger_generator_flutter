// ignore_for_file: avoid_relative_lib_imports

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '../../example/lib/generated/edge_cases_v31.api.dart';

EdgeCasesV31Api _api(String body) => EdgeCasesV31Api(
  baseUrl: Uri.parse('https://example.test'),
  httpClient: MockClient(
    (_) async =>
        http.Response(body, 200, headers: {'content-type': 'application/json'}),
  ),
);

void main() {
  test('decodes a list of strings', () async {
    final response = await _api('["a","b"]').getStrings();
    expect(response.body, ['a', 'b']);
  });

  test('decodes a map with integer values', () async {
    final response = await _api('{"a":1,"b":2}').getCounts();
    expect(response.body, {'a': 1, 'b': 2});
  });

  test('decodes a named free-form map', () async {
    final response = await _api('{"a":{"b":true}}').getFreeMap();
    expect(response.body, {
      'a': {'b': true},
    });
  });

  test('decodes a map of models', () async {
    final response = await _api('{"x":{"id":"ping-1"}}').getPingMap();
    expect(response.body!['x']!.id, 'ping-1');
  });

  test('decodes an integer enum', () async {
    final response = await _api('2').getIntEnum();
    expect(response.body, IntEnum.$2);
  });

  test('decodes an unknown enum value to the fallback', () async {
    final response = await _api('9').getIntEnum();
    expect(response.body, IntEnum.$unknown);
  });

  test('decodes a date-time', () async {
    final response = await _api('"2026-10-29T10:00:00Z"').getTimestamp();
    expect(response.body, DateTime.utc(2026, 10, 29, 10));
  });

  test('decodes an integral number as double', () async {
    final response = await _api('3').getRatio();
    expect(response.body, 3.0);
  });

  test('decodes nested lists of models', () async {
    final response = await _api('[[{"id":"a"}],[{"id":"b"}]]').getGrid();
    expect(response.body!.map((row) => row.single.id), ['a', 'b']);
  });

  test('still decodes a model', () async {
    final response = await _api('{"id":"ping-1"}').getPing();
    expect(response.body!.id, 'ping-1');
  });
}
