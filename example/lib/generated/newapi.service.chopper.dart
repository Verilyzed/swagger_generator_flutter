// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'newapi.service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$NewapiService extends NewapiService {
  _$NewapiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = NewapiService;

  @override
  Future<Response<List<ApiRequest>>> getApiActivity({
    int limit = 50,
    int offset = 0,
  }) {
    final Uri $url = Uri.parse('/activity');
    final Map<String, dynamic> $params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<ApiRequest>, ApiRequest>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getServerHealth() {
    final Uri $url = Uri.parse('/health');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<dynamic>> getHeartbeat() {
    final Uri $url = Uri.parse('/heartbeat');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getPrometheusMetrics() {
    final Uri $url = Uri.parse('/metrics');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Vault>>> getVaults({String? filter}) {
    final Uri $url = Uri.parse('/vaults');
    final Map<String, dynamic> $params = <String, dynamic>{'filter': filter};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<Vault>, Vault>($request);
  }

  @override
  Future<Response<Vault>> getVaultById(String vaultUuid) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Vault, Vault>($request);
  }

  @override
  Future<Response<List<Item>>> getVaultItems(
    String vaultUuid, {
    String? filter,
  }) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}/items');
    final Map<String, dynamic> $params = <String, dynamic>{'filter': filter};
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<Item>, Item>($request);
  }

  @override
  Future<Response<FullItem>> createVaultItem(
    String vaultUuid, {
    FullItem? body,
  }) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}/items');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<FullItem, FullItem>($request);
  }

  @override
  Future<Response<dynamic>> deleteVaultItem(String vaultUuid, String itemUuid) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}/items/${itemUuid}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<FullItem>> getVaultItemById(
    String vaultUuid,
    String itemUuid,
  ) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}/items/${itemUuid}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<FullItem, FullItem>($request);
  }

  @override
  Future<Response<FullItem>> patchVaultItem(
    String vaultUuid,
    String itemUuid, {
    List<Map<String, dynamic>>? body,
  }) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}/items/${itemUuid}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<FullItem, FullItem>($request);
  }

  @override
  Future<Response<FullItem>> updateVaultItem(
    String vaultUuid,
    String itemUuid, {
    FullItem? body,
  }) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}/items/${itemUuid}');
    final $body = body;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<FullItem, FullItem>($request);
  }

  @override
  Future<Response<List<File>>> getItemFiles(
    String vaultUuid,
    String itemUuid, {
    bool? inlineFiles,
  }) {
    final Uri $url = Uri.parse('/vaults/${vaultUuid}/items/${itemUuid}/files');
    final Map<String, dynamic> $params = <String, dynamic>{
      'inline_files': inlineFiles,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<File>, File>($request);
  }

  @override
  Future<Response<File>> getDetailsOfFileById(
    String vaultUuid,
    String itemUuid,
    String fileUuid, {
    bool? inlineFiles,
  }) {
    final Uri $url = Uri.parse(
      '/vaults/${vaultUuid}/items/${itemUuid}/files/${fileUuid}',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'inline_files': inlineFiles,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<File, File>($request);
  }

  @override
  Future<Response<dynamic>> downloadFileById() {
    final Uri $url = Uri.parse(
      '/vaults/{vaultUuid}/items/{itemUuid}/files/{fileUuid}/content',
    );
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
