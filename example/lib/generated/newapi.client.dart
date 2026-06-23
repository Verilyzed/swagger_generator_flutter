// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'newapi.service.dart';
import 'newapi.models.dart';

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
  List<Interceptor>? interceptors,
}) {
  return ChopperClient(
    baseUrl: baseUrl,
    converter: const JsonSerializableConverter({
      ApiRequest: ApiRequest.fromJson,
      ErrorResponse: ErrorResponse.fromJson,
      FieldModel: FieldModel.fromJson,
      File: File.fromJson,
      FullItem: FullItem.fromJson,
      GeneratorRecipe: GeneratorRecipe.fromJson,
      Item: Item.fromJson,
      ServiceDependency: ServiceDependency.fromJson,
      Vault: Vault.fromJson,
      ApiRequestActor: ApiRequestActor.fromJson,
      ApiRequestResourceItem: ApiRequestResourceItem.fromJson,
      ApiRequestResourceVault: ApiRequestResourceVault.fromJson,
      ApiRequestResource: ApiRequestResource.fromJson,
      FieldSection: FieldSection.fromJson,
      FileSection: FileSection.fromJson,
      FullItemSectionsItem: FullItemSectionsItem.fromJson,
      ItemUrlsItem: ItemUrlsItem.fromJson,
      ItemVault: ItemVault.fromJson,
      PatchItem: PatchItem.fromJson,
      GetServerHealthResponse: GetServerHealthResponse.fromJson,
    }),
    interceptors: interceptors ?? const [],
    services: [NewapiService.create()],
  );
}

