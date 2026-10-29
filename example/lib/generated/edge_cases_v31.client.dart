// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show Client;
import 'edge_cases_v31.service.dart';
import 'edge_cases_v31.models.dart';
import 'edge_cases_v31.enums.dart';

typedef JsonFactory = dynamic Function(Map<String, dynamic> json);

class JsonSerializableConverter extends JsonConverter {
  const JsonSerializableConverter(this.factories, [this.decoders = const {}]);

  final Map<Type, JsonFactory> factories;
  final Map<Type, Object? Function(Object?)> decoders;

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
    final contentType = response.headers['content-type']
        ?.split(';').first.trim().toLowerCase();
    final isJson = contentType == 'application/json' ||
        (contentType?.endsWith('+json') ?? false);
    final isNoContent = response.statusCode == 204 ||
        response.statusCode == 205 ||
        response.base.request?.method == 'HEAD' ||
        (contentType == null && response.bodyString.isEmpty);
    if (isNoContent || (contentType != null && !isJson)) {
      return Response<ResultType>(
        response.base,
        isNoContent ? null : response.body,
        error: response.error,
      );
    }
    final decoded = await super.convertResponse<dynamic, dynamic>(response);
    final rawBody = response.bodyString.trim();
    final body = isJson && (rawBody.isEmpty || rawBody == 'null')
        ? null
        : (decoders[ResultType] ?? _decode<Inner>)(decoded.body);
    return Response<ResultType>(
      decoded.base,
      body,
      error: decoded.error,
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
      FreeMapFalse: FreeMapFalse.fromJson,
      Nested: Nested.fromJson,
      Tree: Tree.fromJson,
      NodeA: NodeA.fromJson,
      NodeB: NodeB.fromJson,
      Formats: Formats.fromJson,
      EnumHolder: EnumHolder.fromJson,
      NastyNames: NastyNames.fromJson,
    }, _responseDecoders),
    interceptors: interceptors ?? const [],
    authenticator: authenticator,
    services: [EdgeCasesV31Service.create()],
  );
}

Object? _decodeResponse0(Object? json) =>
    (json as List).map((e0) => e0 as String).toList();

Object? _decodeResponse1(Object? json) =>
    (json as Map<String, dynamic>).map((k0, e0) => MapEntry(k0, e0 as int));

Object? _decodeResponse2(Object? json) =>
    (json as Map<String, dynamic>).map((k0, e0) => MapEntry(k0, e0));

Object? _decodeResponse3(Object? json) =>
    (json as Map<String, dynamic>).map((k0, e0) => MapEntry(k0, Ping.fromJson(e0 as Map<String, dynamic>)));

Object? _decodeResponse4(Object? json) =>
    IntEnum.values.firstWhere((v) => v.toString() == '$json', orElse: () => IntEnum.$unknown);

Object? _decodeResponse5(Object? json) =>
    DateTime.parse(json as String);

Object? _decodeResponse6(Object? json) =>
    (json as num).toDouble();

Object? _decodeResponse7(Object? json) =>
    (json as List).map((e0) => (e0 as List).map((e1) => Ping.fromJson(e1 as Map<String, dynamic>)).toList()).toList();

const _responseDecoders = <Type, Object? Function(Object?)>{
  List<String>: _decodeResponse0,
  Map<String, int>: _decodeResponse1,
  FreeMapTrue: _decodeResponse2,
  Map<String, Ping>: _decodeResponse3,
  IntEnum: _decodeResponse4,
  DateTime: _decodeResponse5,
  double: _decodeResponse6,
  List<List<Ping>>: _decodeResponse7,
};

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

  Future<Response<List<String>>> getStrings() =>
      _service.getStrings();

  Future<Response<Map<String, int>>> getCounts() =>
      _service.getCounts();

  Future<Response<FreeMapTrue>> getFreeMap() =>
      _service.getFreeMap();

  Future<Response<Map<String, Ping>>> getPingMap() =>
      _service.getPingMap();

  Future<Response<IntEnum>> getIntEnum() =>
      _service.getIntEnum();

  Future<Response<DateTime>> getTimestamp() =>
      _service.getTimestamp();

  Future<Response<double>> getRatio() =>
      _service.getRatio();

  Future<Response<List<List<Ping>>>> getGrid() =>
      _service.getGrid();

  Future<Response<dynamic>> getParams({
    String? xToken,
    List<String>? tags,
    Map<String, String>? filter,
  }) =>
      _service.getParams(
        xToken: xToken,
        tags: tags,
        filter: filter,
      );

  Future<Response<dynamic>> postBodies({
    required List<Cat> body,
  }) =>
      _service.postBodies(
        body: body,
      );

  Future<Response<String>> postPrim({
    String? body,
  }) =>
      _service.postPrim(
        body: body,
      );

}

