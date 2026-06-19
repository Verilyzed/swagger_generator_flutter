import 'dart:convert';

import 'package:yaml/yaml.dart';

/// Loads OpenAPI spec content into plain Dart maps.
class SpecLoader {
  Map<String, dynamic> load(String content, {required String path}) {
    final isYaml = path.endsWith('.yaml') || path.endsWith('.yml');
    final decoded = isYaml ? _normalize(loadYaml(content)) : jsonDecode(content);
    if (decoded is! Map) {
      throw FormatException(
        'Expected an OpenAPI document with a top-level object',
        path,
      );
    }
    return decoded.cast<String, dynamic>();
  }

  dynamic _normalize(dynamic node) {
    if (node is YamlMap) {
      return <String, dynamic>{
        for (final entry in node.entries)
          entry.key.toString(): _normalize(entry.value),
      };
    }
    if (node is YamlList) {
      return node.map(_normalize).toList();
    }
    return node;
  }
}
