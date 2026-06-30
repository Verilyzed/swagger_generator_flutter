// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show Client;
import 'edge_cases_v31.service.dart';
import 'edge_cases_v31.models.dart';

typedef JsonFactory = dynamic Function(Map<String, dynamic> json);

class JsonSerializableConverter extends JsonConverter {
  const JsonSerializableConverter(this.factories);

  final Map<Type, JsonFactory> factories;

  T? _decodeMap<T>(Map<String, dynamic> values) {
    final factory = factories[T];
    return factory == null ? null : factory(values) as T;
  }

  List<T> _decodeList<T>(Iterable values) => values
      .whereType<Map<String, dynamic>>()
      .map<T?>(_decodeMap<T>)
      .whereType<T>()
      .toList();

  dynamic _decode<T>(dynamic entity) {
    if (entity is Iterable) return _decodeList<T>(entity);
    if (entity is Map<String, dynamic>) return _decodeMap<T>(entity);
    return entity;
  }

  @override
  Future<Response<ResultType>> convertResponse<ResultType, Inner>(
    Response response,
  ) async {
    final decoded = await super.convertResponse<dynamic, dynamic>(response);
    return decoded.copyWith<ResultType>(
      body: _decode<Inner>(decoded.body),
    );
  }
}

ChopperClient createClient({
  required Uri baseUrl,
  Client? httpClient,
  List<Interceptor>? interceptors,
  Authenticator? authenticator,
}) {
  return ChopperClient(
    baseUrl: baseUrl,
    client: httpClient,
    converter: const JsonSerializableConverter({
      Ping: Ping.fromJson,
      TypeShapes: TypeShapes.fromJson,
      ThreeOneConstructs: ThreeOneConstructs.fromJson,
      Cat: Cat.fromJson,
      Dog: Dog.fromJson,
      Base: Base.fromJson,
      Derived: Derived.fromJson,
      Holder: Holder.fromJson,
      MapAndProps: MapAndProps.fromJson,
      FreeMapTrue: FreeMapTrue.fromJson,
      FreeMapFalse: FreeMapFalse.fromJson,
      Nested: Nested.fromJson,
      Tree: Tree.fromJson,
      NodeA: NodeA.fromJson,
      NodeB: NodeB.fromJson,
      Formats: Formats.fromJson,
      EnumHolder: EnumHolder.fromJson,
    }),
    interceptors: interceptors ?? const [],
    authenticator: authenticator,
    services: [EdgeCasesV31Service.create()],
  );
}

class EdgeCasesV31Api {
  final EdgeCasesV31Service _service;

  EdgeCasesV31Api({
    required Uri baseUrl,
    Client? httpClient,
    List<Interceptor>? interceptors,
    Authenticator? authenticator,
  }) : this.fromClient(createClient(
          baseUrl: baseUrl,
          httpClient: httpClient,
          interceptors: interceptors,
          authenticator: authenticator,
        ));

  EdgeCasesV31Api.fromClient(ChopperClient client)
      : _service = EdgeCasesV31Service.create(client);

  Future<Response<Ping>> getPing() =>
      _service.getPing();

}

