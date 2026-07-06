// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'edge_cases_v30.service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$EdgeCasesV30Service extends EdgeCasesV30Service {
  _$EdgeCasesV30Service([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = EdgeCasesV30Service;

  @override
  Future<Response<Ping>> getPing() {
    final Uri $url = Uri.parse('/ping');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Ping, Ping>($request);
  }
}
