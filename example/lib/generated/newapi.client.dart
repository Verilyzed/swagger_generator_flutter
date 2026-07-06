// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show Client;
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
  Client? httpClient,
  List<Interceptor>? interceptors,
  Authenticator? authenticator,
}) {
  return ChopperClient(
    baseUrl: baseUrl,
    client: httpClient,
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
    authenticator: authenticator,
    services: [NewapiService.create()],
  );
}

class NewapiApi {
  final NewapiService _service;

  NewapiApi({
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

  NewapiApi.fromClient(ChopperClient client)
      : _service = NewapiService.create(client);

  Future<Response<List<ApiRequest>>> getApiActivity({
    int? limit,
    int? offset,
  }) =>
      _service.getApiActivity(
        limit: limit ?? 50,
        offset: offset ?? 0,
      );

  Future<Response<GetServerHealthResponse>> getServerHealth() =>
      _service.getServerHealth();

  Future<Response<String>> getHeartbeat() =>
      _service.getHeartbeat();

  Future<Response<String>> getPrometheusMetrics() =>
      _service.getPrometheusMetrics();

  Future<Response<List<Vault>>> getVaults({
    String? filter,
  }) =>
      _service.getVaults(
        filter: filter,
      );

  Future<Response<Vault>> getVaultById({
    required String vaultUuid,
  }) =>
      _service.getVaultById(
        vaultUuid: vaultUuid,
      );

  Future<Response<List<Item>>> getVaultItems({
    required String vaultUuid,
    String? filter,
  }) =>
      _service.getVaultItems(
        vaultUuid: vaultUuid,
        filter: filter,
      );

  Future<Response<FullItem>> createVaultItem({
    required String vaultUuid,
    FullItem? body,
  }) =>
      _service.createVaultItem(
        vaultUuid: vaultUuid,
        body: body,
      );

  Future<Response<dynamic>> deleteVaultItem({
    required String vaultUuid,
    required String itemUuid,
  }) =>
      _service.deleteVaultItem(
        vaultUuid: vaultUuid,
        itemUuid: itemUuid,
      );

  Future<Response<FullItem>> getVaultItemById({
    required String vaultUuid,
    required String itemUuid,
  }) =>
      _service.getVaultItemById(
        vaultUuid: vaultUuid,
        itemUuid: itemUuid,
      );

  Future<Response<FullItem>> patchVaultItem({
    required String vaultUuid,
    required String itemUuid,
    PatchModel? body,
  }) =>
      _service.patchVaultItem(
        vaultUuid: vaultUuid,
        itemUuid: itemUuid,
        body: body,
      );

  Future<Response<FullItem>> updateVaultItem({
    required String vaultUuid,
    required String itemUuid,
    FullItem? body,
  }) =>
      _service.updateVaultItem(
        vaultUuid: vaultUuid,
        itemUuid: itemUuid,
        body: body,
      );

  Future<Response<List<File>>> getItemFiles({
    required String vaultUuid,
    required String itemUuid,
    bool? inlineFiles,
  }) =>
      _service.getItemFiles(
        vaultUuid: vaultUuid,
        itemUuid: itemUuid,
        inlineFiles: inlineFiles,
      );

  Future<Response<File>> getDetailsOfFileById({
    required String vaultUuid,
    required String itemUuid,
    required String fileUuid,
    bool? inlineFiles,
  }) =>
      _service.getDetailsOfFileById(
        vaultUuid: vaultUuid,
        itemUuid: itemUuid,
        fileUuid: fileUuid,
        inlineFiles: inlineFiles,
      );

  Future<Response<String>> downloadFileById() =>
      _service.downloadFileById();

}

