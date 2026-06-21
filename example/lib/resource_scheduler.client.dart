// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'resource_scheduler.service.dart';

ChopperClient createClient({
  required Uri baseUrl,
  List<Interceptor>? interceptors,
}) {
  return ChopperClient(
    baseUrl: baseUrl,
    converter: const JsonConverter(),
    interceptors: interceptors ?? const [],
    services: [ResourceSchedulerService.create()],
  );
}

