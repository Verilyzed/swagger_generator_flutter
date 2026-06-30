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
}
