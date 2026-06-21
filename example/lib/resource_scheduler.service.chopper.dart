// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'resource_scheduler.service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ResourceSchedulerService extends ResourceSchedulerService {
  _$ResourceSchedulerService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ResourceSchedulerService;

  @override
  Future<Response<Schedule>> getScheduleForAsset(
    String assetId,
    DeadlineFilterEnum deadlineFilter,
  ) {
    final Uri $url = Uri.parse('/assets/${assetId}/schedule');
    final Map<String, dynamic> $params = <String, dynamic>{
      'deadline_filter': deadlineFilter,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<Schedule, Schedule>($request);
  }

  @override
  Future<Response<Schedule>> createSchedule(
    String assetId,
    ScheduleCreateRequest body,
  ) {
    final Uri $url = Uri.parse('/assets/${assetId}/schedule');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<Schedule, Schedule>($request);
  }

  @override
  Future<Response<Schedule>> updateSchedule(
    String assetId,
    String scheduleId,
    ScheduleUpdateRequest body,
  ) {
    final Uri $url = Uri.parse('/assets/${assetId}/schedule/${scheduleId}');
    final $body = body;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<Schedule, Schedule>($request);
  }

  @override
  Future<Response<List<Asset>>> listAssets(int accountId) {
    final Uri $url = Uri.parse('/assets');
    final Map<String, dynamic> $params = <String, dynamic>{
      'account_id': accountId,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<Asset>, Asset>($request);
  }

  @override
  Future<Response<Asset>> getAsset(String assetId) {
    final Uri $url = Uri.parse('/assets/${assetId}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Asset, Asset>($request);
  }

  @override
  Future<Response<ActivityStatus>> getAssetActivityStatus(String assetId) {
    final Uri $url = Uri.parse('/assets/${assetId}/activity_status');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<ActivityStatus, ActivityStatus>($request);
  }

  @override
  Future<Response<dynamic>> refreshAsset(String assetId) {
    final Uri $url = Uri.parse('/assets/${assetId}/refresh');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AssetPolicy>> getAssetPolicy(String assetId) {
    final Uri $url = Uri.parse('/asset_policy/${assetId}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<AssetPolicy, AssetPolicy>($request);
  }

  @override
  Future<Response<dynamic>> patchAssetPolicy(
    String assetId,
    AssetPolicyRequest body,
  ) {
    final Uri $url = Uri.parse('/asset_policy/${assetId}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Task>>> listTasksForAsset(
    String assetId,
    AggregationEnum? aggregation,
    String? period,
    TaskSortFieldEnum? sort,
    SortOrderEnum order,
    int? limit,
  ) {
    final Uri $url = Uri.parse('/assets/${assetId}/tasks');
    final Map<String, dynamic> $params = <String, dynamic>{
      'aggregation': aggregation,
      'period': period,
      'sort': sort,
      'order': order,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<Task>, Task>($request);
  }

  @override
  Future<Response<StreamTokenResponse>> getStreamTokenForAsset(String assetId) {
    final Uri $url = Uri.parse('/assets/${assetId}/stream_token');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<StreamTokenResponse, StreamTokenResponse>($request);
  }

  @override
  Future<Response<TicketResponse>> createTicket(
    String assetId,
    TicketInput body,
  ) {
    final Uri $url = Uri.parse('/tickets');
    final Map<String, dynamic> $params = <String, dynamic>{'asset_id': assetId};
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<TicketResponse, TicketResponse>($request);
  }

  @override
  Future<Response<AttachmentResponse>> attachImageToTicket(
    String ticketId,
    AttachmentInput body,
  ) {
    final Uri $url = Uri.parse('/tickets/${ticketId}/attachment');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<AttachmentResponse, AttachmentResponse>($request);
  }

  @override
  Future<Response<ProviderLinkResponse>> postAccountLink(String accountId) {
    final Uri $url = Uri.parse('/accounts/${accountId}/link');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<ProviderLinkResponse, ProviderLinkResponse>($request);
  }

  @override
  Future<Response<ProviderLinkResponse>> postAccountRelink(String accountId) {
    final Uri $url = Uri.parse('/accounts/${accountId}/relink');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<ProviderLinkResponse, ProviderLinkResponse>($request);
  }

  @override
  Future<Response<Account>> getAccount(String accountId) {
    final Uri $url = Uri.parse('/accounts/${accountId}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<Account, Account>($request);
  }

  @override
  Future<Response<dynamic>> deleteAccount(String accountId) {
    final Uri $url = Uri.parse('/accounts/${accountId}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Account>> selectAsset(
    String accountId,
    SelectAssetRequest body,
  ) {
    final Uri $url = Uri.parse('/accounts/${accountId}:select-asset');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<Account, Account>($request);
  }

  @override
  Future<Response<FeatureFlagConfig>> getFeatures() {
    final Uri $url = Uri.parse('/system/features');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<FeatureFlagConfig, FeatureFlagConfig>($request);
  }

  @override
  Future<Response<List<Run>>> listRunsForAsset(
    String assetId,
    int limit,
    int page,
    SortOrderEnum sortOrder,
    RunStateEnum? state,
  ) {
    final Uri $url = Uri.parse('/assets/${assetId}/runs');
    final Map<String, dynamic> $params = <String, dynamic>{
      'limit': limit,
      'page': page,
      'sort_order': sortOrder,
      'state': state,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<Run>, Run>($request);
  }

  @override
  Future<Response<RunMetrics>> getRunMetrics(
    String assetId,
    AggregationEnum aggregation,
    String? period,
  ) {
    final Uri $url = Uri.parse('/assets/${assetId}/runs/metrics');
    final Map<String, dynamic> $params = <String, dynamic>{
      'aggregation': aggregation,
      'period': period,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<RunMetrics, RunMetrics>($request);
  }
}
