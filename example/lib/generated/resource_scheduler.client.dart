// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'resource_scheduler.service.dart';
import 'resource_scheduler.models.dart';

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
  List<Interceptor>? interceptors,
}) {
  return ChopperClient(
    baseUrl: baseUrl,
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
    services: [ResourceSchedulerService.create()],
  );
}

