// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'edge_cases_v31.service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$EdgeCasesV31Service extends EdgeCasesV31Service {
  _$EdgeCasesV31Service([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = EdgeCasesV31Service;

  @override
  Future<Response<Ping>> getPing() {
    final Uri $url = Uri.parse('/ping');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Ping, Ping>($request);
  }

  @override
  Future<Response<dynamic>> getParams({
    String? xToken,
    List<String>? tags,
    Map<String, String>? filter,
  }) {
    final Uri $url = Uri.parse('/params');
    final Map<String, dynamic> $params = <String, dynamic>{
      'tags': tags,
      'filter': filter,
    };
    final Map<String, String> $headers = {
      if (xToken != null) 'X-Token': xToken,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postBodies({required List<Cat> body}) {
    final Uri $url = Uri.parse('/bodies');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<String>> postPrim({String? body}) {
    final Uri $url = Uri.parse('/prim');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<String, String>($request);
  }
}
