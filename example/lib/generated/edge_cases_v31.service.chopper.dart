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
  Future<Response<List<String>>> getStrings() {
    final Uri $url = Uri.parse('/responses/strings');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<List<String>, String>($request);
  }

  @override
  Future<Response<Map<String, int>>> getCounts() {
    final Uri $url = Uri.parse('/responses/counts');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Map<String, int>, Map<String, int>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> getFreeMap() {
    final Uri $url = Uri.parse('/responses/free-map');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, Ping>>> getPingMap() {
    final Uri $url = Uri.parse('/responses/ping-map');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Map<String, Ping>, Map<String, Ping>>($request);
  }

  @override
  Future<Response<IntEnum>> getIntEnum() {
    final Uri $url = Uri.parse('/responses/int-enum');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<IntEnum, IntEnum>($request);
  }

  @override
  Future<Response<DateTime>> getTimestamp() {
    final Uri $url = Uri.parse('/responses/timestamp');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<DateTime, DateTime>($request);
  }

  @override
  Future<Response<double>> getRatio() {
    final Uri $url = Uri.parse('/responses/ratio');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<double, double>($request);
  }

  @override
  Future<Response<List<List<Ping>>>> getGrid() {
    final Uri $url = Uri.parse('/responses/grid');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<List<List<Ping>>, List<Ping>>($request);
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
