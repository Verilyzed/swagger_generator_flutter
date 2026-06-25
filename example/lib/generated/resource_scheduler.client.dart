// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' show Client;
import 'resource_scheduler.service.dart';
import 'resource_scheduler.models.dart';
import 'resource_scheduler.enums.dart';

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
      AttachmentInput: AttachmentInput.fromJson,
      AttachmentResponse: AttachmentResponse.fromJson,
      BadInputResponse: BadInputResponse.fromJson,
      RunImmediatelyConfig: RunImmediatelyConfig.fromJson,
      AssetState: AssetState.fromJson,
      Task: Task.fromJson,
      Run: Run.fromJson,
      ActivityStatus: ActivityStatus.fromJson,
      Account: Account.fromJson,
      DeadlineSlot: DeadlineSlot.fromJson,
      DiscoveredAsset: DiscoveredAsset.fromJson,
      ProviderLinkResponse: ProviderLinkResponse.fromJson,
      ErrorResponse: ErrorResponse.fromJson,
      Money: Money.fromJson,
      FailureReason: FailureReason.fromJson,
      FeatureFlagConfig: FeatureFlagConfig.fromJson,
      HttpValidationError: HttpValidationError.fromJson,
      Intervention: Intervention.fromJson,
      Quantity: Quantity.fromJson,
      Location: Location.fromJson,
      MetricValue: MetricValue.fromJson,
      NotAllowedResponse: NotAllowedResponse.fromJson,
      NotFoundResponse: NotFoundResponse.fromJson,
      UsageCounter: UsageCounter.fromJson,
      Percent: Percent.fromJson,
      PriceMetric: PriceMetric.fromJson,
      SelectAssetRequest: SelectAssetRequest.fromJson,
      RunMetrics: RunMetrics.fromJson,
      SchedulingStatus: SchedulingStatus.fromJson,
      TicketInput: TicketInput.fromJson,
      TicketResponse: TicketResponse.fromJson,
      Schedule: Schedule.fromJson,
      ScheduleCreateRequest: ScheduleCreateRequest.fromJson,
      ScheduleUpdateRequest: ScheduleUpdateRequest.fromJson,
      ValidationError: ValidationError.fromJson,
      Asset: Asset.fromJson,
      AssetInformation: AssetInformation.fromJson,
      AssetPolicy: AssetPolicy.fromJson,
      AssetPolicyRequest: AssetPolicyRequest.fromJson,
      StreamTokenResponse: StreamTokenResponse.fromJson,
    }),
    interceptors: interceptors ?? const [],
    authenticator: authenticator,
    services: [ResourceSchedulerService.create()],
  );
}

class ResourceSchedulerApi {
  final ResourceSchedulerService _service;

  ResourceSchedulerApi({
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

  ResourceSchedulerApi.fromClient(ChopperClient client)
      : _service = ResourceSchedulerService.create(client);

  Future<Response<Schedule>> getScheduleForAsset({
    required String assetId,
    DeadlineFilterEnum? deadlineFilter,
  }) =>
      _service.getScheduleForAsset(
        assetId: assetId,
        deadlineFilter: deadlineFilter ?? DeadlineFilterEnum.all,
      );

  Future<Response<Schedule>> createSchedule({
    required String assetId,
    required ScheduleCreateRequest body,
  }) =>
      _service.createSchedule(
        assetId: assetId,
        body: body,
      );

  Future<Response<Schedule>> updateSchedule({
    required String assetId,
    required String scheduleId,
    required ScheduleUpdateRequest body,
  }) =>
      _service.updateSchedule(
        assetId: assetId,
        scheduleId: scheduleId,
        body: body,
      );

  Future<Response<List<Asset>>> listAssets({
    required int accountId,
  }) =>
      _service.listAssets(
        accountId: accountId,
      );

  Future<Response<Asset>> getAsset({
    required String assetId,
  }) =>
      _service.getAsset(
        assetId: assetId,
      );

  Future<Response<ActivityStatus>> getAssetActivityStatus({
    required String assetId,
  }) =>
      _service.getAssetActivityStatus(
        assetId: assetId,
      );

  Future<Response<dynamic>> refreshAsset({
    required String assetId,
  }) =>
      _service.refreshAsset(
        assetId: assetId,
      );

  Future<Response<AssetPolicy>> getAssetPolicy({
    required String assetId,
  }) =>
      _service.getAssetPolicy(
        assetId: assetId,
      );

  Future<Response<dynamic>> patchAssetPolicy({
    required String assetId,
    required AssetPolicyRequest body,
  }) =>
      _service.patchAssetPolicy(
        assetId: assetId,
        body: body,
      );

  Future<Response<List<Task>>> listTasksForAsset({
    required String assetId,
    AggregationEnum? aggregation,
    String? period,
    TaskSortFieldEnum? sort,
    SortOrderEnum? order,
    int? limit,
  }) =>
      _service.listTasksForAsset(
        assetId: assetId,
        aggregation: aggregation,
        period: period,
        sort: sort,
        order: order ?? SortOrderEnum.asc,
        limit: limit,
      );

  Future<Response<StreamTokenResponse>> getStreamTokenForAsset({
    required String assetId,
  }) =>
      _service.getStreamTokenForAsset(
        assetId: assetId,
      );

  Future<Response<TicketResponse>> createTicket({
    required String assetId,
    required TicketInput body,
  }) =>
      _service.createTicket(
        assetId: assetId,
        body: body,
      );

  Future<Response<AttachmentResponse>> attachImageToTicket({
    required String ticketId,
    required AttachmentInput body,
  }) =>
      _service.attachImageToTicket(
        ticketId: ticketId,
        body: body,
      );

  Future<Response<ProviderLinkResponse>> postAccountLink({
    required String accountId,
  }) =>
      _service.postAccountLink(
        accountId: accountId,
      );

  Future<Response<ProviderLinkResponse>> postAccountRelink({
    required String accountId,
  }) =>
      _service.postAccountRelink(
        accountId: accountId,
      );

  Future<Response<Account>> getAccount({
    required String accountId,
  }) =>
      _service.getAccount(
        accountId: accountId,
      );

  Future<Response<dynamic>> deleteAccount({
    required String accountId,
  }) =>
      _service.deleteAccount(
        accountId: accountId,
      );

  Future<Response<Account>> selectAsset({
    required String accountId,
    required SelectAssetRequest body,
  }) =>
      _service.selectAsset(
        accountId: accountId,
        body: body,
      );

  Future<Response<FeatureFlagConfig>> getFeatures() =>
      _service.getFeatures();

  Future<Response<List<Run>>> listRunsForAsset({
    required String assetId,
    int? limit,
    int? page,
    SortOrderEnum? sortOrder,
    RunStateEnum? state,
  }) =>
      _service.listRunsForAsset(
        assetId: assetId,
        limit: limit ?? 5,
        page: page ?? 0,
        sortOrder: sortOrder ?? SortOrderEnum.desc,
        state: state,
      );

  Future<Response<RunMetrics>> getRunMetrics({
    required String assetId,
    required AggregationEnum aggregation,
    String? period,
  }) =>
      _service.getRunMetrics(
        assetId: assetId,
        aggregation: aggregation,
        period: period,
      );

}

