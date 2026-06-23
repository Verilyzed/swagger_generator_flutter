// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'newapi.models.dart';

part 'newapi.service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class NewapiService extends ChopperService {
  @GET(path: '/activity')
  Future<Response<List<ApiRequest>>> getApiActivity({
    @Query('limit') int limit = 50,
    @Query('offset') int offset = 0,
  });

  @GET(path: '/health')
  Future<Response<Map<String, dynamic>>> getServerHealth();

  @GET(path: '/heartbeat')
  Future<Response<dynamic>> getHeartbeat();

  @GET(path: '/metrics')
  Future<Response<dynamic>> getPrometheusMetrics();

  @GET(path: '/vaults')
  Future<Response<List<Vault>>> getVaults({
    @Query('filter') String? filter,
  });

  @GET(path: '/vaults/{vaultUuid}')
  Future<Response<Vault>> getVaultById(
    @Path('vaultUuid') String vaultUuid,
  );

  @GET(path: '/vaults/{vaultUuid}/items')
  Future<Response<List<Item>>> getVaultItems(
    @Path('vaultUuid') String vaultUuid,
    {
    @Query('filter') String? filter,
  });

  @POST(path: '/vaults/{vaultUuid}/items')
  Future<Response<FullItem>> createVaultItem(
    @Path('vaultUuid') String vaultUuid,
    {
    @Body() FullItem? body,
  });

  @DELETE(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<dynamic>> deleteVaultItem(
    @Path('vaultUuid') String vaultUuid,
    @Path('itemUuid') String itemUuid,
  );

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<FullItem>> getVaultItemById(
    @Path('vaultUuid') String vaultUuid,
    @Path('itemUuid') String itemUuid,
  );

  @PATCH(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<FullItem>> patchVaultItem(
    @Path('vaultUuid') String vaultUuid,
    @Path('itemUuid') String itemUuid,
    {
    @Body() List<Map<String, dynamic>>? body,
  });

  @PUT(path: '/vaults/{vaultUuid}/items/{itemUuid}')
  Future<Response<FullItem>> updateVaultItem(
    @Path('vaultUuid') String vaultUuid,
    @Path('itemUuid') String itemUuid,
    {
    @Body() FullItem? body,
  });

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}/files')
  Future<Response<List<File>>> getItemFiles(
    @Path('vaultUuid') String vaultUuid,
    @Path('itemUuid') String itemUuid,
    {
    @Query('inline_files') bool? inlineFiles,
  });

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}/files/{fileUuid}')
  Future<Response<File>> getDetailsOfFileById(
    @Path('vaultUuid') String vaultUuid,
    @Path('itemUuid') String itemUuid,
    @Path('fileUuid') String fileUuid,
    {
    @Query('inline_files') bool? inlineFiles,
  });

  @GET(path: '/vaults/{vaultUuid}/items/{itemUuid}/files/{fileUuid}/content')
  Future<Response<dynamic>> downloadFileById();

  static NewapiService create([ChopperClient? client]) =>
      _$NewapiService(client);
}

