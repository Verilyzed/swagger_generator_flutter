import 'package:swagger_generator_flutter/src/emit/response_decoder_emitter.dart';
import 'package:swagger_generator_flutter/src/ir/dart_type.dart';
import 'package:test/test.dart';

void main() {
  final emitter = ResponseDecoderEmitter(
    models: {'Cat'},
    enums: {'Status'},
    typedefs: {'Tags': 'List<String>', 'Counts': 'Map<String, int>'},
  );

  String emit(List<String> types) =>
      emitter.emit(types.map(DartType.new).toList());

  test('emits nothing for types the converter already decodes', () {
    expect(
      emit(['dynamic', 'String', 'int', 'bool', 'Cat', 'List<Cat>']),
      isEmpty,
    );
  });

  test('decodes a list of primitives', () {
    final out = emit(['List<String>']);
    expect(out, contains('const _responseDecoders'));
    expect(out, contains('List<String>: _decodeResponse0,'));
    expect(out, contains('(json as List).map((e0) => e0 as String).toList()'));
  });

  test('decodes a map with typed values', () {
    expect(
      emit(['Map<String, int>']),
      contains(
        '(json as Map<String, dynamic>).map((k0, e0) => MapEntry(k0, e0 as int))',
      ),
    );
  });

  test('decodes a map of models', () {
    expect(
      emit(['Map<String, Cat>']),
      contains('MapEntry(k0, Cat.fromJson(e0 as Map<String, dynamic>))'),
    );
  });

  test('decodes an enum by its wire value', () {
    expect(
      emit(['Status']),
      contains(
        r"Status.values.firstWhere((v) => v.toString() == '$json', "
        r'orElse: () => Status.$unknown)',
      ),
    );
  });

  test('decodes DateTime and double', () {
    final out = emit(['DateTime', 'double']);
    expect(out, contains('DateTime.parse(json as String)'));
    expect(out, contains('(json as num).toDouble()'));
  });

  test('decodes nested lists', () {
    expect(
      emit(['List<List<Cat>>']),
      contains(
        '(json as List).map((e0) => (e0 as List).map((e1) => '
        'Cat.fromJson(e1 as Map<String, dynamic>)).toList()).toList()',
      ),
    );
  });

  test('guards nullable elements', () {
    expect(
      emit(['List<int?>']),
      contains('(e0) => e0 == null ? null : e0 as int'),
    );
  });

  test('expands a typedef and keys it by its name', () {
    final out = emit(['Counts']);
    expect(out, contains('Counts: _decodeResponse0,'));
    expect(out, contains('MapEntry(k0, e0 as int)'));
  });

  test('emits one decoder per distinct runtime type', () {
    final out = emit(['Tags', 'List<String>', 'Tags']);
    expect(out, contains('Tags: _decodeResponse0,'));
    expect(out, isNot(contains('_decodeResponse1')));
  });
}
