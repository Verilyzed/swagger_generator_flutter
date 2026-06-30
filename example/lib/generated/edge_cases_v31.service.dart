// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'edge_cases_v31.models.dart';

part 'edge_cases_v31.service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class EdgeCasesV31Service extends ChopperService {
  @GET(path: '/ping')
  Future<Response<Ping>> getPing();

  static EdgeCasesV31Service create([ChopperClient? client]) =>
      _$EdgeCasesV31Service(client);
}

