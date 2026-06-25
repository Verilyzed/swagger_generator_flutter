import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/parser/spec_parser.dart';
import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

SpecParser _parser() {
  final names = NameGiver();
  return SpecParser(names, OpenApi31TypeResolver(names));
}

void main() {
  test('parses enums', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'AggregationEnum': {
            'type': 'string',
            'enum': ['month', 'year'],
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    expect(spec.enums.single.name, 'AggregationEnum');
    expect(
      spec.enums.single.values.map((v) => v.jsonValue),
      ['month', 'year'],
    );
  });

  test('parses models with required and nullable fields', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Task': {
            'type': 'object',
            'required': ['id'],
            'properties': {
              'id': {'type': 'string'},
              'costs': {
                'anyOf': [
                  {'type': 'number'},
                  {'type': 'null'},
                ],
              },
              'asset_id': {'type': 'string'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final task = spec.models.single;
    final id = task.fields.firstWhere((f) => f.jsonKey == 'id');
    final costs = task.fields.firstWhere((f) => f.jsonKey == 'costs');
    final assetId = task.fields.firstWhere((f) => f.jsonKey == 'asset_id');

    expect(id.isRequired, isTrue);
    expect(costs.type.isNullable, isTrue);
    expect(assetId.dartName, 'assetId');
  });

  test('parses an operation with path param and response type', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/assets/{asset_id}/schedule': {
          'get': {
            'operationId': 'get_schedule_for_asset',
            'parameters': [
              {
                'in': 'path',
                'name': 'asset_id',
                'required': true,
                'schema': {'type': 'string'},
              },
            ],
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'schema': {r'$ref': '#/components/schemas/Schedule'},
                  },
                },
              },
            },
          },
        },
      },
    }, name: 'demo');

    final op = spec.service.operations.single;
    expect(op.methodName, 'getScheduleForAsset');
    expect(op.httpMethod, 'GET');
    expect(op.path, '/assets/{asset_id}/schedule');
    expect(op.parameters.single.location, ParamLocation.path);
    expect(op.responseType.name, 'Schedule');
    expect(spec.service.name, 'DemoService');
  });

  test('enum-typed field with string default yields enum-member default', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'ErrorCode': {
            'type': 'string',
            'enum': ['NOT_ALLOWED', 'RESOURCE_NOT_FOUND'],
          },
          'NotAllowedResponse': {
            'type': 'object',
            'properties': {
              'error_code': {
                r'$ref': '#/components/schemas/ErrorCode',
                'default': 'NOT_ALLOWED',
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final model = spec.models.single;
    final field = model.fields.single;
    expect(field.defaultValue, 'ErrorCode.notAllowed');
  });

  test('plain string field default yields quoted literal', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Task': {
            'type': 'object',
            'properties': {
              'label': {'type': 'string', 'default': 'hi'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final field = spec.models.single.fields.single;
    expect(field.defaultValue, "'hi'");
  });

  test('skips path-level parameters and summary keys', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/tasks': {
          'summary': 'Task routes',
          'parameters': [
            {
              'in': 'query',
              'name': 'limit',
              'schema': {'type': 'integer'},
            },
          ],
          'get': {
            'operationId': 'list_tasks',
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.methodName, 'listTasks');
  });

  test('parses query param optionality and defaults', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'StatusEnum': {
            'type': 'string',
            'enum': ['active', 'inactive'],
          },
        },
      },
      'paths': {
        '/gadgets': {
          'get': {
            'operationId': 'list_gadgets',
            'parameters': [
              {
                'in': 'query',
                'name': 'limit',
                'required': false,
                'schema': {'type': 'integer', 'default': 50},
              },
              {
                'in': 'query',
                'name': 'status',
                'required': false,
                'schema': {
                  r'$ref': '#/components/schemas/StatusEnum',
                  'default': 'active',
                },
              },
            ],
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    final op = spec.service.operations.single;
    final limit = op.parameters.firstWhere((p) => p.wireName == 'limit');
    final status = op.parameters.firstWhere((p) => p.wireName == 'status');
    expect(limit.isRequired, isFalse);
    expect(limit.defaultValue, '50');
    expect(status.defaultValue, 'StatusEnum.active');
  });

  test('path params are required', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/gadgets/{gadget_id}': {
          'get': {
            'operationId': 'get_gadget',
            'parameters': [
              {
                'in': 'path',
                'name': 'gadget_id',
                'required': true,
                'schema': {'type': 'string'},
              },
            ],
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.parameters.single.isRequired, isTrue);
  });

  test('names methods from the path when nameFromPath is true', () {
    final names = NameGiver();
    final parser = SpecParser(
      names,
      OpenApi31TypeResolver(names),
      nameFromPath: true,
    );
    final spec = parser.parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/health': {
          'get': {
            'operationId': 'GetServerHealth',
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.methodName, 'getHealth');
  });

  test('names methods from the operationId by default', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/health': {
          'get': {
            'operationId': 'GetServerHealth',
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.methodName, 'getServerHealth');
  });

  test('parses a multipart body into part parameters', () {
    final spec = _parser().parse({
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
                    'required': ['file'],
                    'properties': {
                      'file': {'type': 'string', 'format': 'binary'},
                      'label': {'type': 'string'},
                    },
                  },
                },
              },
            },
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    final params = spec.service.operations.single.parameters;
    final file = params.firstWhere((p) => p.wireName == 'file');
    final label = params.firstWhere((p) => p.wireName == 'label');
    expect(file.location, ParamLocation.partFile);
    expect(file.type.name, 'MultipartFile');
    expect(file.isRequired, isTrue);
    expect(label.location, ParamLocation.part);
    expect(label.type.name, 'String');
    expect(params.any((p) => p.location == ParamLocation.body), isFalse);
  });

  test('treats a 3.1 contentMediaType string as a file part', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/u': {
          'post': {
            'operationId': 'u',
            'requestBody': {
              'content': {
                'multipart/form-data': {
                  'schema': {
                    'type': 'object',
                    'required': ['file'],
                    'properties': {
                      'file': {
                        'type': 'string',
                        'contentMediaType': 'application/octet-stream',
                      },
                    },
                  },
                },
              },
            },
            'responses': <String, dynamic>{},
          },
        },
      },
    }, name: 'demo');

    final file = spec.service.operations.single.parameters.single;
    expect(file.location, ParamLocation.partFile);
    expect(file.type.name, 'MultipartFile');
  });

  test('flattens allOf into a single model', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'required': ['id'],
            'properties': {
              'id': {'type': 'string'},
              'title': {'type': 'string'},
            },
          },
          'FullItem': {
            'allOf': [
              {r'$ref': '#/components/schemas/Item'},
              {
                'type': 'object',
                'properties': {
                  'sections': {'type': 'string'},
                },
              },
            ],
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final full = spec.models.firstWhere((m) => m.name == 'FullItem');
    final keys = full.fields.map((f) => f.jsonKey).toSet();
    expect(keys, containsAll(<String>['id', 'title', 'sections']));
    expect(full.fields.firstWhere((f) => f.jsonKey == 'id').isRequired, isTrue);
  });

  test('marks non-required fields without a default as nullable', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'required': ['id'],
            'properties': {
              'id': {'type': 'string'},
              'note': {'type': 'string'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final item = spec.models.single;
    expect(item.fields.firstWhere((f) => f.jsonKey == 'id').type.isNullable,
        isFalse);
    expect(item.fields.firstWhere((f) => f.jsonKey == 'note').type.isNullable,
        isTrue);
  });

  test('does not make a dynamic non-required field nullable', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'Item': {
            'type': 'object',
            'properties': {
              'extra': <String, dynamic>{},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final field = spec.models.single.fields.single;
    expect(field.type.name, 'dynamic');
    expect(field.type.isNullable, isFalse);
  });

  test('formats an enum default from a ref-to-enum field', () {
    final spec = _parser().parse({
      'components': {
        'schemas': {
          'ItemCategory': {
            'type': 'string',
            'enum': ['LOGIN', 'PASSWORD'],
          },
          'Item': {
            'type': 'object',
            'properties': {
              'category': {
                r'$ref': '#/components/schemas/ItemCategory',
                'default': 'LOGIN',
              },
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    final field =
        spec.models.firstWhere((m) => m.name == 'Item').fields.single;
    expect(field.type.name, 'ItemCategory');
    expect(field.defaultValue, 'ItemCategory.login');
  });

  test('resolves a text/plain response as its schema type', () {
    final spec = _parser().parse({
      'components': {'schemas': <String, dynamic>{}},
      'paths': {
        '/heartbeat': {
          'get': {
            'operationId': 'getHeartbeat',
            'responses': {
              '200': {
                'content': {
                  'text/plain': {
                    'schema': {'type': 'string'},
                  },
                },
              },
            },
          },
        },
      },
    }, name: 'demo');

    expect(spec.service.operations.single.responseType.display, 'String');
  });

  test('skips generating an overridden schema', () {
    final names = NameGiver();
    final resolver = OpenApi31TypeResolver(
      names,
      schemas: {
        'OneOfThing': {
          'oneOf': [
            {r'$ref': '#/components/schemas/A'},
          ],
        },
      },
      overrides: {'OneOfThing'},
    );
    final spec = SpecParser(names, resolver, overrideSchemas: {'OneOfThing'})
        .parse({
      'components': {
        'schemas': {
          'OneOfThing': {
            'oneOf': [
              {r'$ref': '#/components/schemas/A'},
            ],
          },
          'Foo': {
            'type': 'object',
            'properties': {
              'thing': {r'$ref': '#/components/schemas/OneOfThing'},
            },
          },
        },
      },
      'paths': <String, dynamic>{},
    }, name: 'demo');

    expect(spec.models.map((m) => m.name), isNot(contains('OneOfThing')));
    expect(spec.models.map((m) => m.name), contains('Foo'));
    expect(spec.enums.map((e) => e.name), isNot(contains('OneOfThing')));
    final foo = spec.models.firstWhere((m) => m.name == 'Foo');
    expect(foo.fields.single.type.name, 'OneOfThing');
  });
}
