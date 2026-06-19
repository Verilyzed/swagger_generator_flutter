import 'package:swagger_generator_flutter/src/ir/api_spec.dart';
import 'package:swagger_generator_flutter/src/parser/spec_parser.dart';
import 'package:swagger_generator_flutter/src/resolve/dart_type_resolver.dart';
import 'package:swagger_generator_flutter/src/resolve/name_giver.dart';
import 'package:test/test.dart';

SpecParser _parser() {
  final names = NameGiver();
  return SpecParser(names, DartTypeResolver(names));
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
}
