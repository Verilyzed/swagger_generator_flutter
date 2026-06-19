import 'package:swagger_generator_flutter/src/emit/source_writer.dart';
import 'package:test/test.dart';

void main() {
  test('header has the generated banner', () {
    expect(
      SourceWriter.header(),
      startsWith('// GENERATED CODE - DO NOT MODIFY BY HAND'),
    );
  });

  test('importLine formats a directive', () {
    expect(
      SourceWriter.importLine('package:json_annotation/json_annotation.dart'),
      "import 'package:json_annotation/json_annotation.dart';",
    );
  });
}
