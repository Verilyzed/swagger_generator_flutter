// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'newapi.models.dart';

part 'newapi.service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class NewapiService extends ChopperService {
  @GET(path: '/activity')
  Future<Response<List<ApiRequest>>> getApiActivity({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET(path: '/health')
  Future<Response<GetServerHealthResponse>> getServerHealth();

  @GET(path: '/heartbeat')
  Future<Response<String>> getHeartbeat();

  @GET(path: '/metrics')
  Future<Response<String>> getPrometheusMetrics();

  @GET(path: '/vaults')
  Future<Response<List<Vault>>> getVaults({
    @Query('filter') String? filter,
  });

  @GET(path: '/vaults/{vaultUuid}')
  Future<Response<Vault>> getVaultById({
    @Path('vaultUuid') required String vaultUuid,
  });

  @GET(path: '/vaults/{vaultUuid}/items')
  Future<Response<List<Item>>> getVaultItems({
    @Path('vaultUuid') required String vaultUuid,
    @Query('filter') String? filter,
  });

  @POST(path: '/vaults/{vaultUuid}/items')
  Future<Response<FullItem>> createVaultItem({
    @Path('vaultUuid') required String vaultUuid,
    @Body() FullItem? body,
  });

  @DELETE(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<dynamic>> deleteVaultItem({
    @Path('vaultUuid') required String vaultUuid,
    @Path('itemUuid') required String itemUuid,
  });

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<FullItem>> getVaultItemById({
    @Path('vaultUuid') required String vaultUuid,
    @Path('itemUuid') required String itemUuid,
  });

  @PATCH(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<FullItem>> patchVaultItem({
    @Path('vaultUuid') required String vaultUuid,
    @Path('itemUuid') required String itemUuid,
    @Body() List<PatchItem>? body,
  });

  @PUT(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<FullItem>> updateVaultItem({
    @Path('vaultUuid') required String vaultUuid,
    @Path('itemUuid') required String itemUuid,
    @Body() FullItem? body,
  });

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}/files')
  Future<Response<List<File>>> getItemFiles({
    @Path('vaultUuid') required String vaultUuid,
    @Path('itemUuid') required String itemUuid,
    @Query('inline_files') bool? inlineFiles,
  });

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}/files/{fileUuid}')
  Future<Response<File>> getDetailsOfFileById({
    @Path('vaultUuid') required String vaultUuid,
    @Path('itemUuid') required String itemUuid,
    @Path('fileUuid') required String fileUuid,
    @Query('inline_files') bool? inlineFiles,
  });

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}/files/{fileUuid}/content')
  Future<Response<String>> downloadFileById();

  static NewapiService create([ChopperClient? client]) =>
      _$NewapiService(client);
}

