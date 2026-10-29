// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'edge_cases_v31.models.dart';
import 'edge_cases_v31.enums.dart';

part 'edge_cases_v31.service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class EdgeCasesV31Service extends ChopperService {
  @GET(path: '/ping')
  Future<Response<Ping>> getPing();

  @GET(path: '/responses/strings')
  Future<Response<List<String>>> getStrings();

  @GET(path: '/responses/counts')
  Future<Response<Map<String, int>>> getCounts();

  @GET(path: '/responses/free-map')
  Future<Response<FreeMapTrue>> getFreeMap();

  @GET(path: '/responses/ping-map')
  Future<Response<Map<String, Ping>>> getPingMap();

  @GET(path: '/responses/int-enum')
  Future<Response<IntEnum>> getIntEnum();

  @GET(path: '/responses/timestamp')
  Future<Response<DateTime>> getTimestamp();

  @GET(path: '/responses/ratio')
  Future<Response<double>> getRatio();

  @GET(path: '/responses/grid')
  Future<Response<List<List<Ping>>>> getGrid();

  @GET(path: '/params')
  Future<Response<dynamic>> getParams({
    @Header('X-Token') String? xToken,
    @Query('tags') List<String>? tags,
    @Query('filter') Map<String, String>? filter,
  });

  @POST(path: '/bodies')
  Future<Response<dynamic>> postBodies({
    @Body() required List<Cat> body,
  });

  @POST(path: '/prim')
  Future<Response<String>> postPrim({
    @Body() String? body,
  });

  static EdgeCasesV31Service create([ChopperClient? client]) =>
      _$EdgeCasesV31Service(client);
}

