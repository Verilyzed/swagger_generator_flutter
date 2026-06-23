import 'package:swagger_generator_flutter/src/parser/schema_hoister.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

SchemaHoister _hoister() => SchemaHoister(NameGiver());

Map<String, dynamic> _schemas(Map<String, dynamic> spec) =>
    ((spec['components'] as Map)['schemas'] as Map).cast<String, dynamic>();

Map<String, dynamic> _props(Map<String, dynamic> schema) =>
    (schema['properties'] as Map).cast<String, dynamic>();

void main() {
  test('hoists an inline response object to <OperationId>Response', () {
    final out = _hoister().hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/health': {
          'get': {
            'operationId': 'getServerHealth',
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'name': {'type': 'string'},
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    });

    final schemas = _schemas(out);
    expect(
      _props(schemas['GetServerHealthResponse'] as Map<String, dynamic>),
      contains('name'),
    );

    final paths = (out['paths'] as Map).cast<String, dynamic>();
    final get = ((paths['/health'] as Map)['get'] as Map).cast<String, dynamic>();
    final response =
        ((get['responses'] as Map)['200'] as Map).cast<String, dynamic>();
    final media = ((response['content'] as Map)['application/json'] as Map)
        .cast<String, dynamic>();
    expect(media['schema'],
        {r'$ref': '#/components/schemas/GetServerHealthResponse'});
  });

  test('hoists an inline request body to <OperationId>Request', () {
    final out = _hoister().hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/x': {
          'post': {
            'operationId': 'createX',
            'requestBody': {
              'content': {
                'application/json': {
                  'schema': {
                    'type': 'object',
                    'properties': {
                      'a': {'type': 'string'},
                    },
                  },
                },
              },
            },
          },
        },
      },
    });

    expect(_schemas(out), contains('CreateXRequest'));
  });

  test('hoists a nested property object and recurses', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'properties': {
              'recipe': {
                'type': 'object',
                'properties': {
                  'length': {'type': 'integer'},
                },
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final schemas = _schemas(out);
    expect(schemas, contains('ItemRecipe'));
    expect(_props(schemas['Item'] as Map<String, dynamic>)['recipe'],
        {r'$ref': '#/components/schemas/ItemRecipe'});
  });

  test('hoists an inline enum and keeps a default on the ref', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'properties': {
              'category': {
                'type': 'string',
                'enum': ['LOGIN', 'PASSWORD'],
                'default': 'LOGIN',
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final schemas = _schemas(out);
    expect((schemas['ItemCategory'] as Map<String, dynamic>)['enum'],
        ['LOGIN', 'PASSWORD']);
    expect(_props(schemas['Item'] as Map<String, dynamic>)['category'], {
      r'$ref': '#/components/schemas/ItemCategory',
      'default': 'LOGIN',
    });
  });

  test('hoists an array items object to <Context>Item', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'Patch': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'op': {'type': 'string'},
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final schemas = _schemas(out);
    expect(schemas, contains('PatchItem'));
    expect((schemas['Patch'] as Map<String, dynamic>)['items'],
        {r'$ref': '#/components/schemas/PatchItem'});
  });

  test('de-duplicates a generated name that already exists', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'ItemRecipe': {'type': 'string'},
          'Item': {
            'type': 'object',
            'properties': {
              'recipe': {
                'type': 'object',
                'properties': {
                  'length': {'type': 'integer'},
                },
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final schemas = _schemas(out);
    expect(schemas, contains('ItemRecipe2'));
    expect(_props(schemas['Item'] as Map<String, dynamic>)['recipe'],
        {r'$ref': '#/components/schemas/ItemRecipe2'});
  });

  test('leaves refs, additionalProperties, and bare objects untouched', () {
    final out = _hoister().hoist({
      'components': {
        'schemas': {
          'A': {
            'type': 'object',
            'properties': {
              'ref': {r'$ref': '#/components/schemas/B'},
              'map': {
                'type': 'object',
                'additionalProperties': {'type': 'string'},
              },
              'bare': {'type': 'object'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    });

    final props = _props(_schemas(out)['A'] as Map<String, dynamic>);
    expect(props['ref'], {r'$ref': '#/components/schemas/B'});
    expect((props['map'] as Map)['additionalProperties'], {'type': 'string'});
    expect(props['bare'], {'type': 'object'});
  });

  test('leaves multipart media schemas inline', () {
    final out = _hoister().hoist({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/upload': {
          'post': {
            'operationId': 'upload',
            'requestBody': {
              'content': {
                'multipart/form-data': {
                  'schema': {
                    'type': 'object',
                    'properties': {
                      'file': {'type': 'string', 'format': 'binary'},
                    },
                  },
                },
              },
            },
          },
        },
      },
    });

    expect(_schemas(out), isEmpty);
    final post = (((out['paths'] as Map)['/upload'] as Map)['post'] as Map)
        .cast<String, dynamic>();
    final schema = (((post['requestBody'] as Map)['content'] as Map)
        ['multipart/form-data'] as Map)['schema'] as Map;
    expect(schema.containsKey('properties'), isTrue);
    expect(schema.containsKey(r'$ref'), isFalse);
  });
}
