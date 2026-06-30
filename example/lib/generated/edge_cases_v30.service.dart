// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'edge_cases_v30.models.dart';

part 'edge_cases_v30.service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class EdgeCasesV30Service extends ChopperService {
  @GET(path: '/ping')
  Future<Response<Ping>> getPing();

  static EdgeCasesV30Service create([ChopperClient? client]) =>
      _$EdgeCasesV30Service(client);
}

