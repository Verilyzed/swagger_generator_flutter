// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'resource_scheduler.enums.dart';

part 'resource_scheduler.models.g.dart';

@JsonSerializable()
class AttachmentInput {
  final String filename;
  final String content;

  AttachmentInput({
    required this.filename,
    required this.content,
  });

  factory AttachmentInput.fromJson(Map<String, dynamic> json) =>
      _$AttachmentInputFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentInputToJson(this);
}

@JsonSerializable()
class AttachmentResponse {
  @JsonKey(name: 'attachment_id')
  final String attachmentId;
  final String filename;
  final int size;

  AttachmentResponse({
    required this.attachmentId,
    required this.filename,
    required this.size,
  });

  factory AttachmentResponse.fromJson(Map<String, dynamic> json) =>
      _$AttachmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentResponseToJson(this);
}

@JsonSerializable()
class BadInputResponse {
  final String detail;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;

  BadInputResponse({
    required this.detail,
    this.errorCode = ErrorCode.badInput,
  });

  factory BadInputResponse.fromJson(Map<String, dynamic> json) =>
      _$BadInputResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BadInputResponseToJson(this);
}

@JsonSerializable()
class RunImmediatelyConfig {
  @JsonKey(name: 'max_level')
  final double? maxLevel;

  RunImmediatelyConfig({
    this.maxLevel,
  });

  factory RunImmediatelyConfig.fromJson(Map<String, dynamic> json) =>
      _$RunImmediatelyConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RunImmediatelyConfigToJson(this);
}

@JsonSerializable()
class AssetState {
  final double? level;
  final double? range;
  @JsonKey(name: 'is_connected')
  final bool? isConnected;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'is_complete')
  final bool? isComplete;
  final double? capacity;
  @JsonKey(name: 'level_limit')
  final double? levelLimit;
  final double? throughput;
  @JsonKey(name: 'time_remaining')
  final double? timeRemaining;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  @JsonKey(name: 'max_rate')
  final double? maxRate;
  @JsonKey(name: 'connection_state', unknownEnumValue: ConnectionState.$unknown)
  final ConnectionState connectionState;

  AssetState({
    required this.level,
    required this.range,
    required this.isConnected,
    required this.isActive,
    required this.isComplete,
    required this.capacity,
    required this.levelLimit,
    required this.throughput,
    required this.timeRemaining,
    required this.lastUpdated,
    required this.maxRate,
    required this.connectionState,
  });

  factory AssetState.fromJson(Map<String, dynamic> json) =>
      _$AssetStateFromJson(json);

  Map<String, dynamic> toJson() => _$AssetStateToJson(this);
}

@JsonSerializable()
class Task {
  final String id;
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'calculated_start')
  final DateTime calculatedStart;
  @JsonKey(name: 'calculated_end')
  final DateTime calculatedEnd;
  @JsonKey(unknownEnumValue: TaskStateEnum.$unknown)
  final TaskStateEnum state;
  @JsonKey(name: 'target_date')
  final DateTime targetDate;
  @JsonKey(unknownEnumValue: TaskTypeEnum.$unknown)
  final TaskTypeEnum type;
  @JsonKey(name: 'end_trigger', unknownEnumValue: TaskEndTriggerEnum.$unknown)
  final TaskEndTriggerEnum? endTrigger;
  @JsonKey(name: 'target_level')
  final double? targetLevel;
  final double? costs;
  @JsonKey(name: 'total_quantity')
  final double? totalQuantity;
  @JsonKey(name: 'price_per_unit')
  final double? pricePerUnit;
  @JsonKey(name: 'failure_reason')
  final FailureReason? failureReason;

  Task({
    required this.id,
    required this.assetId,
    required this.calculatedStart,
    required this.calculatedEnd,
    required this.state,
    required this.targetDate,
    this.type = TaskTypeEnum.costOptimized,
    this.endTrigger,
    this.targetLevel,
    this.costs,
    this.totalQuantity,
    this.pricePerUnit,
    this.failureReason,
  });

  factory Task.fromJson(Map<String, dynamic> json) =>
      _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@JsonSerializable()
class Run {
  final String id;
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'ended_at')
  final DateTime? endedAt;
  @JsonKey(name: 'target_date')
  final DateTime targetDate;
  @JsonKey(name: 'target_level')
  final Percent? targetLevel;
  @JsonKey(unknownEnumValue: RunStateEnum.$unknown)
  final RunStateEnum state;
  final List<Task> tasks;
  @JsonKey(name: 'total_quantity')
  final Quantity? totalQuantity;
  @JsonKey(name: 'total_costs')
  final Money? totalCosts;
  @JsonKey(name: 'avg_price_per_unit')
  final Money? avgPricePerUnit;
  @JsonKey(name: 'baseline_costs')
  final Money? baselineCosts;
  final Money? savings;
  @JsonKey(name: 'savings_pct')
  final Percent? savingsPct;

  Run({
    required this.id,
    required this.assetId,
    required this.createdAt,
    this.endedAt,
    required this.targetDate,
    this.targetLevel,
    required this.state,
    required this.tasks,
    this.totalQuantity,
    this.totalCosts,
    this.avgPricePerUnit,
    this.baselineCosts,
    this.savings,
    this.savingsPct,
  });

  factory Run.fromJson(Map<String, dynamic> json) =>
      _$RunFromJson(json);

  Map<String, dynamic> toJson() => _$RunToJson(this);
}

@JsonSerializable()
class ActivityStatus {
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'activity_reason', unknownEnumValue: ActivityReason.$unknown)
  final ActivityReason? activityReason;

  ActivityStatus({
    required this.assetId,
    this.activityReason,
  });

  factory ActivityStatus.fromJson(Map<String, dynamic> json) =>
      _$ActivityStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityStatusToJson(this);
}

@JsonSerializable()
class Account {
  @JsonKey(name: 'provider_user_id')
  final String providerUserId;
  @JsonKey(name: 'account_id')
  final String accountId;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'selected_asset')
  final DiscoveredAsset? selectedAsset;
  @JsonKey(name: 'discovered_assets')
  final List<DiscoveredAsset>? discoveredAssets;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Account({
    required this.providerUserId,
    required this.accountId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.selectedAsset,
    this.discoveredAssets,
    this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class DeadlineSlot {
  @JsonKey(name: 'target_time')
  final String targetTime;
  final bool active;

  DeadlineSlot({
    required this.targetTime,
    this.active = true,
  });

  factory DeadlineSlot.fromJson(Map<String, dynamic> json) =>
      _$DeadlineSlotFromJson(json);

  Map<String, dynamic> toJson() => _$DeadlineSlotToJson(this);
}

@JsonSerializable()
class DiscoveredAsset {
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'asset_information')
  final AssetInformation assetInformation;
  @JsonKey(unknownEnumValue: DiscoveredAssetCapability.$unknown)
  final DiscoveredAssetCapability capability;
  @JsonKey(name: 'has_interventions')
  final bool hasInterventions;

  DiscoveredAsset({
    required this.assetId,
    required this.assetInformation,
    required this.capability,
    required this.hasInterventions,
  });

  factory DiscoveredAsset.fromJson(Map<String, dynamic> json) =>
      _$DiscoveredAssetFromJson(json);

  Map<String, dynamic> toJson() => _$DiscoveredAssetToJson(this);
}

@JsonSerializable()
class ProviderLinkResponse {
  final String linkUrl;
  final String linkToken;

  ProviderLinkResponse({
    required this.linkUrl,
    required this.linkToken,
  });

  factory ProviderLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderLinkResponseToJson(this);
}

@JsonSerializable()
class ErrorResponse {
  final String detail;
  @JsonKey(name: 'error_id')
  final String? errorId;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;

  ErrorResponse({
    required this.detail,
    required this.errorId,
    this.errorCode = ErrorCode.internalServerError,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
class Money {
  final String? value;
  final String unit;

  Money({
    this.value,
    this.unit = 'USD',
  });

  factory Money.fromJson(Map<String, dynamic> json) =>
      _$MoneyFromJson(json);

  Map<String, dynamic> toJson() => _$MoneyToJson(this);
}

@JsonSerializable()
class FailureReason {
  @JsonKey(unknownEnumValue: FailureReasonTypeEnum.$unknown)
  final FailureReasonTypeEnum type;
  final String detail;

  FailureReason({
    required this.type,
    required this.detail,
  });

  factory FailureReason.fromJson(Map<String, dynamic> json) =>
      _$FailureReasonFromJson(json);

  Map<String, dynamic> toJson() => _$FailureReasonToJson(this);
}

@JsonSerializable()
class FeatureFlagConfig {
  final SchedulingStatus scheduling;

  FeatureFlagConfig({
    required this.scheduling,
  });

  factory FeatureFlagConfig.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagConfigFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureFlagConfigToJson(this);
}

@JsonSerializable()
class HttpValidationError {
  final List<ValidationError>? detail;

  HttpValidationError({
    this.detail,
  });

  factory HttpValidationError.fromJson(Map<String, dynamic> json) =>
      _$HttpValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$HttpValidationErrorToJson(this);
}

@JsonSerializable()
class Intervention {
  final String id;
  final String title;
  final String description;
  @JsonKey(unknownEnumValue: Domain.$unknown)
  final Domain domain;
  @JsonKey(unknownEnumValue: ResolutionAccess.$unknown)
  final ResolutionAccess access;
  @JsonKey(unknownEnumValue: ResolutionAgent.$unknown)
  final ResolutionAgent agent;
  @JsonKey(unknownEnumValue: ResolutionAction.$unknown)
  final ResolutionAction? action;

  Intervention({
    required this.id,
    required this.title,
    required this.description,
    required this.domain,
    required this.access,
    required this.agent,
    this.action,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);

  Map<String, dynamic> toJson() => _$InterventionToJson(this);
}

@JsonSerializable()
class Quantity {
  final double? value;
  final String unit;

  Quantity({
    this.value,
    this.unit = 'units',
  });

  factory Quantity.fromJson(Map<String, dynamic> json) =>
      _$QuantityFromJson(json);

  Map<String, dynamic> toJson() => _$QuantityToJson(this);
}

@JsonSerializable()
class Location {
  final double? longitude;
  final double? latitude;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  @JsonKey(name: 'at_base')
  final bool atBase;

  Location({
    required this.longitude,
    required this.latitude,
    required this.lastUpdated,
    required this.atBase,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class MetricValue {
  final int value;
  @JsonKey(name: 'previous_value')
  final int previousValue;
  final Percent trend;

  MetricValue({
    required this.value,
    required this.previousValue,
    required this.trend,
  });

  factory MetricValue.fromJson(Map<String, dynamic> json) =>
      _$MetricValueFromJson(json);

  Map<String, dynamic> toJson() => _$MetricValueToJson(this);
}

@JsonSerializable()
class NotAllowedResponse {
  final String detail;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;

  NotAllowedResponse({
    required this.detail,
    this.errorCode = ErrorCode.notAllowed,
  });

  factory NotAllowedResponse.fromJson(Map<String, dynamic> json) =>
      _$NotAllowedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotAllowedResponseToJson(this);
}

@JsonSerializable()
class NotFoundResponse {
  final String detail;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;
  final String? entity;
  final String? id;

  NotFoundResponse({
    this.detail = 'Ressource not found',
    this.errorCode = ErrorCode.resourceNotFound,
    this.entity,
    this.id,
  });

  factory NotFoundResponse.fromJson(Map<String, dynamic> json) =>
      _$NotFoundResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotFoundResponseToJson(this);
}

@JsonSerializable()
class UsageCounter {
  final double? reading;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;

  UsageCounter({
    required this.reading,
    required this.lastUpdated,
  });

  factory UsageCounter.fromJson(Map<String, dynamic> json) =>
      _$UsageCounterFromJson(json);

  Map<String, dynamic> toJson() => _$UsageCounterToJson(this);
}

@JsonSerializable()
class Percent {
  final double? value;
  final String unit;

  Percent({
    this.value,
    this.unit = '%',
  });

  factory Percent.fromJson(Map<String, dynamic> json) =>
      _$PercentFromJson(json);

  Map<String, dynamic> toJson() => _$PercentToJson(this);
}

@JsonSerializable()
class PriceMetric {
  final String? value;
  final String unit;
  final Percent pct;
  final Percent trend;

  PriceMetric({
    this.value,
    this.unit = 'USD',
    required this.pct,
    required this.trend,
  });

  factory PriceMetric.fromJson(Map<String, dynamic> json) =>
      _$PriceMetricFromJson(json);

  Map<String, dynamic> toJson() => _$PriceMetricToJson(this);
}

@JsonSerializable()
class SelectAssetRequest {
  @JsonKey(name: 'asset_id')
  final String assetId;

  SelectAssetRequest({
    required this.assetId,
  });

  factory SelectAssetRequest.fromJson(Map<String, dynamic> json) =>
      _$SelectAssetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SelectAssetRequestToJson(this);
}

@JsonSerializable()
class RunMetrics {
  final String period;
  @JsonKey(unknownEnumValue: AggregationEnum.$unknown)
  final AggregationEnum aggregation;
  @JsonKey(name: 'session_count')
  final MetricValue sessionCount;
  @JsonKey(name: 'actual_costs')
  final Money actualCosts;
  @JsonKey(name: 'baseline_costs')
  final Money baselineCosts;
  final PriceMetric savings;
  @JsonKey(name: 'weighted_avg_price_per_unit')
  final PriceMetric weightedAvgPricePerUnit;

  RunMetrics({
    required this.period,
    required this.aggregation,
    required this.sessionCount,
    required this.actualCosts,
    required this.baselineCosts,
    required this.savings,
    required this.weightedAvgPricePerUnit,
  });

  factory RunMetrics.fromJson(Map<String, dynamic> json) =>
      _$RunMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$RunMetricsToJson(this);
}

@JsonSerializable()
class SchedulingStatus {
  final bool enabled;

  SchedulingStatus({
    required this.enabled,
  });

  factory SchedulingStatus.fromJson(Map<String, dynamic> json) =>
      _$SchedulingStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SchedulingStatusToJson(this);
}

@JsonSerializable()
class TicketInput {
  final String subject;
  final String description;
  @JsonKey(name: 'occurred_at')
  final String occurredAt;
  final String email;

  TicketInput({
    required this.subject,
    required this.description,
    required this.occurredAt,
    required this.email,
  });

  factory TicketInput.fromJson(Map<String, dynamic> json) =>
      _$TicketInputFromJson(json);

  Map<String, dynamic> toJson() => _$TicketInputToJson(this);
}

@JsonSerializable()
class TicketResponse {
  @JsonKey(name: 'ticket_id')
  final String ticketId;
  @JsonKey(name: 'request_url')
  final String requestUrl;
  final String status;
  final String message;
  final bool success;

  TicketResponse({
    required this.ticketId,
    required this.requestUrl,
    required this.status,
    required this.message,
    required this.success,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) =>
      _$TicketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TicketResponseToJson(this);
}

@JsonSerializable()
class Schedule {
  final String id;
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'deadline_schedule')
  final Map<String, List<DeadlineSlot>> deadlineSchedule;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.assetId,
    required this.deadlineSchedule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}

@JsonSerializable()
class ScheduleCreateRequest {
  @JsonKey(name: 'deadline_schedule')
  final Map<String, List<DeadlineSlot>> deadlineSchedule;

  ScheduleCreateRequest({
    required this.deadlineSchedule,
  });

  factory ScheduleCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ScheduleCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleCreateRequestToJson(this);
}

@JsonSerializable()
class ScheduleUpdateRequest {
  @JsonKey(name: 'deadline_schedule')
  final Map<String, List<DeadlineSlot>> deadlineSchedule;

  ScheduleUpdateRequest({
    required this.deadlineSchedule,
  });

  factory ScheduleUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ScheduleUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleUpdateRequestToJson(this);
}

@JsonSerializable()
class ValidationError {
  final List<dynamic> loc;
  final String msg;
  final String type;
  final dynamic input;
  final Map<String, dynamic>? ctx;

  ValidationError({
    required this.loc,
    required this.msg,
    required this.type,
    required this.input,
    this.ctx,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}

@JsonSerializable()
class Asset {
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'last_seen')
  final DateTime lastSeen;
  @JsonKey(name: 'is_reachable')
  final bool? isReachable;
  @JsonKey(name: 'asset_information')
  final AssetInformation assetInformation;
  @JsonKey(name: 'resource_state')
  final AssetState resourceState;
  final UsageCounter odometer;
  final Location location;
  final List<Intervention>? interventions;

  Asset({
    required this.assetId,
    required this.lastSeen,
    required this.isReachable,
    required this.assetInformation,
    required this.resourceState,
    required this.odometer,
    required this.location,
    this.interventions,
  });

  factory Asset.fromJson(Map<String, dynamic> json) =>
      _$AssetFromJson(json);

  Map<String, dynamic> toJson() => _$AssetToJson(this);
}

@JsonSerializable()
class AssetInformation {
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  final String? manufacturer;
  final String? model;
  final int? year;
  @JsonKey(name: 'display_name')
  final String? displayName;

  AssetInformation({
    required this.serialNumber,
    required this.manufacturer,
    required this.model,
    required this.year,
    required this.displayName,
  });

  factory AssetInformation.fromJson(Map<String, dynamic> json) =>
      _$AssetInformationFromJson(json);

  Map<String, dynamic> toJson() => _$AssetInformationToJson(this);
}

@JsonSerializable()
class AssetPolicy {
  final String id;
  @JsonKey(name: 'scheduling_active')
  final bool schedulingActive;
  @JsonKey(name: 'activity_state', unknownEnumValue: ActivityState.$unknown)
  final ActivityState activityState;
  @JsonKey(name: 'activity_state_reason', unknownEnumValue: ActivityStateReason.$unknown)
  final ActivityStateReason? activityStateReason;
  @JsonKey(name: 'min_level')
  final double minLevel;
  @JsonKey(name: 'run_immediately_config')
  final RunImmediatelyConfig? runImmediatelyConfig;

  AssetPolicy({
    required this.id,
    required this.schedulingActive,
    required this.activityState,
    this.activityStateReason,
    required this.minLevel,
    required this.runImmediatelyConfig,
  });

  factory AssetPolicy.fromJson(Map<String, dynamic> json) =>
      _$AssetPolicyFromJson(json);

  Map<String, dynamic> toJson() => _$AssetPolicyToJson(this);
}

@JsonSerializable()
class AssetPolicyRequest {
  @JsonKey(name: 'scheduling_active')
  final bool? schedulingActive;
  @JsonKey(name: 'min_level')
  final double? minLevel;
  @JsonKey(name: 'run_immediately_config')
  final RunImmediatelyConfig? runImmediatelyConfig;

  AssetPolicyRequest({
    this.schedulingActive,
    this.minLevel,
    this.runImmediatelyConfig,
  });

  factory AssetPolicyRequest.fromJson(Map<String, dynamic> json) =>
      _$AssetPolicyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssetPolicyRequestToJson(this);
}

@JsonSerializable()
class StreamTokenResponse {
  final String token;

  StreamTokenResponse({
    required this.token,
  });

  factory StreamTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$StreamTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StreamTokenResponseToJson(this);
}

