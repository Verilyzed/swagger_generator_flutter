// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';
import 'resource_scheduler.enums.dart';

part 'resource_scheduler.models.g.dart';

@JsonSerializable()
class AttachmentInput {
  @JsonKey(name: 'filename')
  final String filename;
  @JsonKey(name: 'content')
  final String content;

  const AttachmentInput({
    required this.filename,
    required this.content,
  });

  AttachmentInput copyWith({
    String? filename,
    String? content,
  }) {
    return AttachmentInput(
      filename: filename ?? this.filename,
      content: content ?? this.content,
    );
  }

  factory AttachmentInput.fromJson(Map<String, dynamic> json) =>
      _$AttachmentInputFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentInputToJson(this);
}

@JsonSerializable()
class AttachmentResponse {
  @JsonKey(name: 'attachment_id')
  final String attachmentId;
  @JsonKey(name: 'filename')
  final String filename;
  @JsonKey(name: 'size')
  final int size;

  const AttachmentResponse({
    required this.attachmentId,
    required this.filename,
    required this.size,
  });

  AttachmentResponse copyWith({
    String? attachmentId,
    String? filename,
    int? size,
  }) {
    return AttachmentResponse(
      attachmentId: attachmentId ?? this.attachmentId,
      filename: filename ?? this.filename,
      size: size ?? this.size,
    );
  }

  factory AttachmentResponse.fromJson(Map<String, dynamic> json) =>
      _$AttachmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentResponseToJson(this);
}

@JsonSerializable()
class BadInputResponse {
  @JsonKey(name: 'detail')
  final String detail;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;

  const BadInputResponse({
    required this.detail,
    this.errorCode = ErrorCode.badInput,
  });

  BadInputResponse copyWith({
    String? detail,
    ErrorCode? errorCode,
  }) {
    return BadInputResponse(
      detail: detail ?? this.detail,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  factory BadInputResponse.fromJson(Map<String, dynamic> json) =>
      _$BadInputResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BadInputResponseToJson(this);
}

@JsonSerializable()
class RunImmediatelyConfig {
  @JsonKey(name: 'max_level')
  final double? maxLevel;

  const RunImmediatelyConfig({
    this.maxLevel,
  });

  RunImmediatelyConfig copyWith({
    double? maxLevel,
  }) {
    return RunImmediatelyConfig(
      maxLevel: maxLevel ?? this.maxLevel,
    );
  }

  factory RunImmediatelyConfig.fromJson(Map<String, dynamic> json) =>
      _$RunImmediatelyConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RunImmediatelyConfigToJson(this);
}

@JsonSerializable()
class AssetState {
  @JsonKey(name: 'level')
  final double? level;
  @JsonKey(name: 'range')
  final double? range;
  @JsonKey(name: 'is_connected')
  final bool? isConnected;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'is_complete')
  final bool? isComplete;
  @JsonKey(name: 'capacity')
  final double? capacity;
  @JsonKey(name: 'level_limit')
  final double? levelLimit;
  @JsonKey(name: 'throughput')
  final double? throughput;
  @JsonKey(name: 'time_remaining')
  final double? timeRemaining;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  @JsonKey(name: 'max_rate')
  final double? maxRate;
  @JsonKey(name: 'connection_state', unknownEnumValue: ConnectionState.$unknown)
  final ConnectionState connectionState;

  const AssetState({
    this.level,
    this.range,
    this.isConnected,
    this.isActive,
    this.isComplete,
    this.capacity,
    this.levelLimit,
    this.throughput,
    this.timeRemaining,
    this.lastUpdated,
    this.maxRate,
    required this.connectionState,
  });

  AssetState copyWith({
    double? level,
    double? range,
    bool? isConnected,
    bool? isActive,
    bool? isComplete,
    double? capacity,
    double? levelLimit,
    double? throughput,
    double? timeRemaining,
    DateTime? lastUpdated,
    double? maxRate,
    ConnectionState? connectionState,
  }) {
    return AssetState(
      level: level ?? this.level,
      range: range ?? this.range,
      isConnected: isConnected ?? this.isConnected,
      isActive: isActive ?? this.isActive,
      isComplete: isComplete ?? this.isComplete,
      capacity: capacity ?? this.capacity,
      levelLimit: levelLimit ?? this.levelLimit,
      throughput: throughput ?? this.throughput,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      maxRate: maxRate ?? this.maxRate,
      connectionState: connectionState ?? this.connectionState,
    );
  }

  factory AssetState.fromJson(Map<String, dynamic> json) =>
      _$AssetStateFromJson(json);

  Map<String, dynamic> toJson() => _$AssetStateToJson(this);
}

@JsonSerializable()
class Task {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'calculated_start')
  final DateTime calculatedStart;
  @JsonKey(name: 'calculated_end')
  final DateTime calculatedEnd;
  @JsonKey(name: 'state', unknownEnumValue: TaskStateEnum.$unknown)
  final TaskStateEnum state;
  @JsonKey(name: 'target_date')
  final DateTime targetDate;
  @JsonKey(name: 'type', unknownEnumValue: TaskTypeEnum.$unknown)
  final TaskTypeEnum type;
  @JsonKey(name: 'end_trigger', unknownEnumValue: TaskEndTriggerEnum.$unknown)
  final TaskEndTriggerEnum? endTrigger;
  @JsonKey(name: 'target_level')
  final double? targetLevel;
  @JsonKey(name: 'costs')
  final double? costs;
  @JsonKey(name: 'total_quantity')
  final double? totalQuantity;
  @JsonKey(name: 'price_per_unit')
  final double? pricePerUnit;
  @JsonKey(name: 'failure_reason')
  final FailureReason? failureReason;

  const Task({
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

  Task copyWith({
    String? id,
    String? assetId,
    DateTime? calculatedStart,
    DateTime? calculatedEnd,
    TaskStateEnum? state,
    DateTime? targetDate,
    TaskTypeEnum? type,
    TaskEndTriggerEnum? endTrigger,
    double? targetLevel,
    double? costs,
    double? totalQuantity,
    double? pricePerUnit,
    FailureReason? failureReason,
  }) {
    return Task(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      calculatedStart: calculatedStart ?? this.calculatedStart,
      calculatedEnd: calculatedEnd ?? this.calculatedEnd,
      state: state ?? this.state,
      targetDate: targetDate ?? this.targetDate,
      type: type ?? this.type,
      endTrigger: endTrigger ?? this.endTrigger,
      targetLevel: targetLevel ?? this.targetLevel,
      costs: costs ?? this.costs,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) =>
      _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@JsonSerializable()
class Run {
  @JsonKey(name: 'id')
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
  @JsonKey(name: 'state', unknownEnumValue: RunStateEnum.$unknown)
  final RunStateEnum state;
  @JsonKey(name: 'tasks')
  final List<Task> tasks;
  @JsonKey(name: 'total_quantity')
  final Quantity? totalQuantity;
  @JsonKey(name: 'total_costs')
  final Money? totalCosts;
  @JsonKey(name: 'avg_price_per_unit')
  final Money? avgPricePerUnit;
  @JsonKey(name: 'baseline_costs')
  final Money? baselineCosts;
  @JsonKey(name: 'savings')
  final Money? savings;
  @JsonKey(name: 'savings_pct')
  final Percent? savingsPct;

  const Run({
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

  Run copyWith({
    String? id,
    String? assetId,
    DateTime? createdAt,
    DateTime? endedAt,
    DateTime? targetDate,
    Percent? targetLevel,
    RunStateEnum? state,
    List<Task>? tasks,
    Quantity? totalQuantity,
    Money? totalCosts,
    Money? avgPricePerUnit,
    Money? baselineCosts,
    Money? savings,
    Percent? savingsPct,
  }) {
    return Run(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      targetDate: targetDate ?? this.targetDate,
      targetLevel: targetLevel ?? this.targetLevel,
      state: state ?? this.state,
      tasks: tasks ?? this.tasks,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalCosts: totalCosts ?? this.totalCosts,
      avgPricePerUnit: avgPricePerUnit ?? this.avgPricePerUnit,
      baselineCosts: baselineCosts ?? this.baselineCosts,
      savings: savings ?? this.savings,
      savingsPct: savingsPct ?? this.savingsPct,
    );
  }

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

  const ActivityStatus({
    required this.assetId,
    this.activityReason,
  });

  ActivityStatus copyWith({
    String? assetId,
    ActivityReason? activityReason,
  }) {
    return ActivityStatus(
      assetId: assetId ?? this.assetId,
      activityReason: activityReason ?? this.activityReason,
    );
  }

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
  @JsonKey(name: 'latitude')
  final double latitude;
  @JsonKey(name: 'longitude')
  final double longitude;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'selected_asset')
  final DiscoveredAsset? selectedAsset;
  @JsonKey(name: 'discovered_assets')
  final List<DiscoveredAsset>? discoveredAssets;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Account({
    required this.providerUserId,
    required this.accountId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.selectedAsset,
    this.discoveredAssets,
    this.updatedAt,
  });

  Account copyWith({
    String? providerUserId,
    String? accountId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DiscoveredAsset? selectedAsset,
    List<DiscoveredAsset>? discoveredAssets,
    DateTime? updatedAt,
  }) {
    return Account(
      providerUserId: providerUserId ?? this.providerUserId,
      accountId: accountId ?? this.accountId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      discoveredAssets: discoveredAssets ?? this.discoveredAssets,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class DeadlineSlot {
  @JsonKey(name: 'target_time')
  final String targetTime;
  @JsonKey(name: 'active')
  final bool active;

  const DeadlineSlot({
    required this.targetTime,
    this.active = true,
  });

  DeadlineSlot copyWith({
    String? targetTime,
    bool? active,
  }) {
    return DeadlineSlot(
      targetTime: targetTime ?? this.targetTime,
      active: active ?? this.active,
    );
  }

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
  @JsonKey(name: 'capability', unknownEnumValue: DiscoveredAssetCapability.$unknown)
  final DiscoveredAssetCapability capability;
  @JsonKey(name: 'has_interventions')
  final bool hasInterventions;

  const DiscoveredAsset({
    required this.assetId,
    required this.assetInformation,
    required this.capability,
    required this.hasInterventions,
  });

  DiscoveredAsset copyWith({
    String? assetId,
    AssetInformation? assetInformation,
    DiscoveredAssetCapability? capability,
    bool? hasInterventions,
  }) {
    return DiscoveredAsset(
      assetId: assetId ?? this.assetId,
      assetInformation: assetInformation ?? this.assetInformation,
      capability: capability ?? this.capability,
      hasInterventions: hasInterventions ?? this.hasInterventions,
    );
  }

  factory DiscoveredAsset.fromJson(Map<String, dynamic> json) =>
      _$DiscoveredAssetFromJson(json);

  Map<String, dynamic> toJson() => _$DiscoveredAssetToJson(this);
}

@JsonSerializable()
class ProviderLinkResponse {
  @JsonKey(name: 'linkUrl')
  final String linkUrl;
  @JsonKey(name: 'linkToken')
  final String linkToken;

  const ProviderLinkResponse({
    required this.linkUrl,
    required this.linkToken,
  });

  ProviderLinkResponse copyWith({
    String? linkUrl,
    String? linkToken,
  }) {
    return ProviderLinkResponse(
      linkUrl: linkUrl ?? this.linkUrl,
      linkToken: linkToken ?? this.linkToken,
    );
  }

  factory ProviderLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$ProviderLinkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderLinkResponseToJson(this);
}

@JsonSerializable()
class ErrorResponse {
  @JsonKey(name: 'detail')
  final String detail;
  @JsonKey(name: 'error_id')
  final String? errorId;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;

  const ErrorResponse({
    required this.detail,
    this.errorId,
    this.errorCode = ErrorCode.internalServerError,
  });

  ErrorResponse copyWith({
    String? detail,
    String? errorId,
    ErrorCode? errorCode,
  }) {
    return ErrorResponse(
      detail: detail ?? this.detail,
      errorId: errorId ?? this.errorId,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

@JsonSerializable()
class Money {
  @JsonKey(name: 'value')
  final String? value;
  @JsonKey(name: 'unit')
  final String unit;

  const Money({
    this.value,
    this.unit = 'USD',
  });

  Money copyWith({
    String? value,
    String? unit,
  }) {
    return Money(
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  factory Money.fromJson(Map<String, dynamic> json) =>
      _$MoneyFromJson(json);

  Map<String, dynamic> toJson() => _$MoneyToJson(this);
}

@JsonSerializable()
class FailureReason {
  @JsonKey(name: 'type', unknownEnumValue: FailureReasonTypeEnum.$unknown)
  final FailureReasonTypeEnum type;
  @JsonKey(name: 'detail')
  final String detail;

  const FailureReason({
    required this.type,
    required this.detail,
  });

  FailureReason copyWith({
    FailureReasonTypeEnum? type,
    String? detail,
  }) {
    return FailureReason(
      type: type ?? this.type,
      detail: detail ?? this.detail,
    );
  }

  factory FailureReason.fromJson(Map<String, dynamic> json) =>
      _$FailureReasonFromJson(json);

  Map<String, dynamic> toJson() => _$FailureReasonToJson(this);
}

@JsonSerializable()
class FeatureFlagConfig {
  @JsonKey(name: 'scheduling')
  final SchedulingStatus scheduling;

  const FeatureFlagConfig({
    required this.scheduling,
  });

  FeatureFlagConfig copyWith({
    SchedulingStatus? scheduling,
  }) {
    return FeatureFlagConfig(
      scheduling: scheduling ?? this.scheduling,
    );
  }

  factory FeatureFlagConfig.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagConfigFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureFlagConfigToJson(this);
}

@JsonSerializable()
class HttpValidationError {
  @JsonKey(name: 'detail')
  final List<ValidationError>? detail;

  const HttpValidationError({
    this.detail,
  });

  HttpValidationError copyWith({
    List<ValidationError>? detail,
  }) {
    return HttpValidationError(
      detail: detail ?? this.detail,
    );
  }

  factory HttpValidationError.fromJson(Map<String, dynamic> json) =>
      _$HttpValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$HttpValidationErrorToJson(this);
}

@JsonSerializable()
class Intervention {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'domain', unknownEnumValue: Domain.$unknown)
  final Domain domain;
  @JsonKey(name: 'access', unknownEnumValue: ResolutionAccess.$unknown)
  final ResolutionAccess access;
  @JsonKey(name: 'agent', unknownEnumValue: ResolutionAgent.$unknown)
  final ResolutionAgent agent;
  @JsonKey(name: 'action', unknownEnumValue: ResolutionAction.$unknown)
  final ResolutionAction? action;

  const Intervention({
    required this.id,
    required this.title,
    required this.description,
    required this.domain,
    required this.access,
    required this.agent,
    this.action,
  });

  Intervention copyWith({
    String? id,
    String? title,
    String? description,
    Domain? domain,
    ResolutionAccess? access,
    ResolutionAgent? agent,
    ResolutionAction? action,
  }) {
    return Intervention(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      access: access ?? this.access,
      agent: agent ?? this.agent,
      action: action ?? this.action,
    );
  }

  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);

  Map<String, dynamic> toJson() => _$InterventionToJson(this);
}

@JsonSerializable()
class Quantity {
  @JsonKey(name: 'value')
  final double? value;
  @JsonKey(name: 'unit')
  final String unit;

  const Quantity({
    this.value,
    this.unit = 'units',
  });

  Quantity copyWith({
    double? value,
    String? unit,
  }) {
    return Quantity(
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  factory Quantity.fromJson(Map<String, dynamic> json) =>
      _$QuantityFromJson(json);

  Map<String, dynamic> toJson() => _$QuantityToJson(this);
}

@JsonSerializable()
class Location {
  @JsonKey(name: 'longitude')
  final double? longitude;
  @JsonKey(name: 'latitude')
  final double? latitude;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  @JsonKey(name: 'at_base')
  final bool atBase;

  const Location({
    this.longitude,
    this.latitude,
    this.lastUpdated,
    required this.atBase,
  });

  Location copyWith({
    double? longitude,
    double? latitude,
    DateTime? lastUpdated,
    bool? atBase,
  }) {
    return Location(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      atBase: atBase ?? this.atBase,
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class MetricValue {
  @JsonKey(name: 'value')
  final int value;
  @JsonKey(name: 'previous_value')
  final int previousValue;
  @JsonKey(name: 'trend')
  final Percent trend;

  const MetricValue({
    required this.value,
    required this.previousValue,
    required this.trend,
  });

  MetricValue copyWith({
    int? value,
    int? previousValue,
    Percent? trend,
  }) {
    return MetricValue(
      value: value ?? this.value,
      previousValue: previousValue ?? this.previousValue,
      trend: trend ?? this.trend,
    );
  }

  factory MetricValue.fromJson(Map<String, dynamic> json) =>
      _$MetricValueFromJson(json);

  Map<String, dynamic> toJson() => _$MetricValueToJson(this);
}

@JsonSerializable()
class NotAllowedResponse {
  @JsonKey(name: 'detail')
  final String detail;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;

  const NotAllowedResponse({
    required this.detail,
    this.errorCode = ErrorCode.notAllowed,
  });

  NotAllowedResponse copyWith({
    String? detail,
    ErrorCode? errorCode,
  }) {
    return NotAllowedResponse(
      detail: detail ?? this.detail,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  factory NotAllowedResponse.fromJson(Map<String, dynamic> json) =>
      _$NotAllowedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotAllowedResponseToJson(this);
}

@JsonSerializable()
class NotFoundResponse {
  @JsonKey(name: 'detail')
  final String detail;
  @JsonKey(name: 'error_code', unknownEnumValue: ErrorCode.$unknown)
  final ErrorCode errorCode;
  @JsonKey(name: 'entity')
  final String? entity;
  @JsonKey(name: 'id')
  final String? id;

  const NotFoundResponse({
    this.detail = 'Ressource not found',
    this.errorCode = ErrorCode.resourceNotFound,
    this.entity,
    this.id,
  });

  NotFoundResponse copyWith({
    String? detail,
    ErrorCode? errorCode,
    String? entity,
    String? id,
  }) {
    return NotFoundResponse(
      detail: detail ?? this.detail,
      errorCode: errorCode ?? this.errorCode,
      entity: entity ?? this.entity,
      id: id ?? this.id,
    );
  }

  factory NotFoundResponse.fromJson(Map<String, dynamic> json) =>
      _$NotFoundResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotFoundResponseToJson(this);
}

@JsonSerializable()
class UsageCounter {
  @JsonKey(name: 'reading')
  final double? reading;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;

  const UsageCounter({
    this.reading,
    this.lastUpdated,
  });

  UsageCounter copyWith({
    double? reading,
    DateTime? lastUpdated,
  }) {
    return UsageCounter(
      reading: reading ?? this.reading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory UsageCounter.fromJson(Map<String, dynamic> json) =>
      _$UsageCounterFromJson(json);

  Map<String, dynamic> toJson() => _$UsageCounterToJson(this);
}

@JsonSerializable()
class Percent {
  @JsonKey(name: 'value')
  final double? value;
  @JsonKey(name: 'unit')
  final String unit;

  const Percent({
    this.value,
    this.unit = '%',
  });

  Percent copyWith({
    double? value,
    String? unit,
  }) {
    return Percent(
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  factory Percent.fromJson(Map<String, dynamic> json) =>
      _$PercentFromJson(json);

  Map<String, dynamic> toJson() => _$PercentToJson(this);
}

@JsonSerializable()
class PriceMetric {
  @JsonKey(name: 'value')
  final String? value;
  @JsonKey(name: 'unit')
  final String unit;
  @JsonKey(name: 'pct')
  final Percent pct;
  @JsonKey(name: 'trend')
  final Percent trend;

  const PriceMetric({
    this.value,
    this.unit = 'USD',
    required this.pct,
    required this.trend,
  });

  PriceMetric copyWith({
    String? value,
    String? unit,
    Percent? pct,
    Percent? trend,
  }) {
    return PriceMetric(
      value: value ?? this.value,
      unit: unit ?? this.unit,
      pct: pct ?? this.pct,
      trend: trend ?? this.trend,
    );
  }

  factory PriceMetric.fromJson(Map<String, dynamic> json) =>
      _$PriceMetricFromJson(json);

  Map<String, dynamic> toJson() => _$PriceMetricToJson(this);
}

@JsonSerializable()
class SelectAssetRequest {
  @JsonKey(name: 'asset_id')
  final String assetId;

  const SelectAssetRequest({
    required this.assetId,
  });

  SelectAssetRequest copyWith({
    String? assetId,
  }) {
    return SelectAssetRequest(
      assetId: assetId ?? this.assetId,
    );
  }

  factory SelectAssetRequest.fromJson(Map<String, dynamic> json) =>
      _$SelectAssetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SelectAssetRequestToJson(this);
}

@JsonSerializable()
class RunMetrics {
  @JsonKey(name: 'period')
  final String period;
  @JsonKey(name: 'aggregation', unknownEnumValue: AggregationEnum.$unknown)
  final AggregationEnum aggregation;
  @JsonKey(name: 'session_count')
  final MetricValue sessionCount;
  @JsonKey(name: 'actual_costs')
  final Money actualCosts;
  @JsonKey(name: 'baseline_costs')
  final Money baselineCosts;
  @JsonKey(name: 'savings')
  final PriceMetric savings;
  @JsonKey(name: 'weighted_avg_price_per_unit')
  final PriceMetric weightedAvgPricePerUnit;

  const RunMetrics({
    required this.period,
    required this.aggregation,
    required this.sessionCount,
    required this.actualCosts,
    required this.baselineCosts,
    required this.savings,
    required this.weightedAvgPricePerUnit,
  });

  RunMetrics copyWith({
    String? period,
    AggregationEnum? aggregation,
    MetricValue? sessionCount,
    Money? actualCosts,
    Money? baselineCosts,
    PriceMetric? savings,
    PriceMetric? weightedAvgPricePerUnit,
  }) {
    return RunMetrics(
      period: period ?? this.period,
      aggregation: aggregation ?? this.aggregation,
      sessionCount: sessionCount ?? this.sessionCount,
      actualCosts: actualCosts ?? this.actualCosts,
      baselineCosts: baselineCosts ?? this.baselineCosts,
      savings: savings ?? this.savings,
      weightedAvgPricePerUnit: weightedAvgPricePerUnit ?? this.weightedAvgPricePerUnit,
    );
  }

  factory RunMetrics.fromJson(Map<String, dynamic> json) =>
      _$RunMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$RunMetricsToJson(this);
}

@JsonSerializable()
class SchedulingStatus {
  @JsonKey(name: 'enabled')
  final bool enabled;

  const SchedulingStatus({
    required this.enabled,
  });

  SchedulingStatus copyWith({
    bool? enabled,
  }) {
    return SchedulingStatus(
      enabled: enabled ?? this.enabled,
    );
  }

  factory SchedulingStatus.fromJson(Map<String, dynamic> json) =>
      _$SchedulingStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SchedulingStatusToJson(this);
}

@JsonSerializable()
class TicketInput {
  @JsonKey(name: 'subject')
  final String subject;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'occurred_at')
  final String occurredAt;
  @JsonKey(name: 'email')
  final String email;

  const TicketInput({
    required this.subject,
    required this.description,
    required this.occurredAt,
    required this.email,
  });

  TicketInput copyWith({
    String? subject,
    String? description,
    String? occurredAt,
    String? email,
  }) {
    return TicketInput(
      subject: subject ?? this.subject,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      email: email ?? this.email,
    );
  }

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
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'success')
  final bool success;

  const TicketResponse({
    required this.ticketId,
    required this.requestUrl,
    required this.status,
    required this.message,
    required this.success,
  });

  TicketResponse copyWith({
    String? ticketId,
    String? requestUrl,
    String? status,
    String? message,
    bool? success,
  }) {
    return TicketResponse(
      ticketId: ticketId ?? this.ticketId,
      requestUrl: requestUrl ?? this.requestUrl,
      status: status ?? this.status,
      message: message ?? this.message,
      success: success ?? this.success,
    );
  }

  factory TicketResponse.fromJson(Map<String, dynamic> json) =>
      _$TicketResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TicketResponseToJson(this);
}

@JsonSerializable()
class Schedule {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'deadline_schedule')
  final Map<Weekday, List<DeadlineSlot>> deadlineSchedule;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Schedule({
    required this.id,
    required this.assetId,
    required this.deadlineSchedule,
    required this.createdAt,
    required this.updatedAt,
  });

  Schedule copyWith({
    String? id,
    String? assetId,
    Map<Weekday, List<DeadlineSlot>>? deadlineSchedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      deadlineSchedule: deadlineSchedule ?? this.deadlineSchedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);
}

@JsonSerializable()
class ScheduleCreateRequest {
  @JsonKey(name: 'deadline_schedule')
  final Map<Weekday, List<DeadlineSlot>> deadlineSchedule;

  const ScheduleCreateRequest({
    required this.deadlineSchedule,
  });

  ScheduleCreateRequest copyWith({
    Map<Weekday, List<DeadlineSlot>>? deadlineSchedule,
  }) {
    return ScheduleCreateRequest(
      deadlineSchedule: deadlineSchedule ?? this.deadlineSchedule,
    );
  }

  factory ScheduleCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ScheduleCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleCreateRequestToJson(this);
}

@JsonSerializable()
class ScheduleUpdateRequest {
  @JsonKey(name: 'deadline_schedule')
  final Map<Weekday, List<DeadlineSlot>> deadlineSchedule;

  const ScheduleUpdateRequest({
    required this.deadlineSchedule,
  });

  ScheduleUpdateRequest copyWith({
    Map<Weekday, List<DeadlineSlot>>? deadlineSchedule,
  }) {
    return ScheduleUpdateRequest(
      deadlineSchedule: deadlineSchedule ?? this.deadlineSchedule,
    );
  }

  factory ScheduleUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ScheduleUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleUpdateRequestToJson(this);
}

@JsonSerializable()
class ValidationError {
  @JsonKey(name: 'loc')
  final List<dynamic> loc;
  @JsonKey(name: 'msg')
  final String msg;
  @JsonKey(name: 'type')
  final String type;
  @JsonKey(name: 'input')
  final dynamic input;
  @JsonKey(name: 'ctx')
  final Map<String, dynamic>? ctx;

  const ValidationError({
    required this.loc,
    required this.msg,
    required this.type,
    required this.input,
    this.ctx,
  });

  ValidationError copyWith({
    List<dynamic>? loc,
    String? msg,
    String? type,
    dynamic input,
    Map<String, dynamic>? ctx,
  }) {
    return ValidationError(
      loc: loc ?? this.loc,
      msg: msg ?? this.msg,
      type: type ?? this.type,
      input: input ?? this.input,
      ctx: ctx ?? this.ctx,
    );
  }

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
  @JsonKey(name: 'odometer')
  final UsageCounter odometer;
  @JsonKey(name: 'location')
  final Location location;
  @JsonKey(name: 'interventions')
  final List<Intervention>? interventions;

  const Asset({
    required this.assetId,
    required this.lastSeen,
    this.isReachable,
    required this.assetInformation,
    required this.resourceState,
    required this.odometer,
    required this.location,
    this.interventions,
  });

  Asset copyWith({
    String? assetId,
    DateTime? lastSeen,
    bool? isReachable,
    AssetInformation? assetInformation,
    AssetState? resourceState,
    UsageCounter? odometer,
    Location? location,
    List<Intervention>? interventions,
  }) {
    return Asset(
      assetId: assetId ?? this.assetId,
      lastSeen: lastSeen ?? this.lastSeen,
      isReachable: isReachable ?? this.isReachable,
      assetInformation: assetInformation ?? this.assetInformation,
      resourceState: resourceState ?? this.resourceState,
      odometer: odometer ?? this.odometer,
      location: location ?? this.location,
      interventions: interventions ?? this.interventions,
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json) =>
      _$AssetFromJson(json);

  Map<String, dynamic> toJson() => _$AssetToJson(this);
}

@JsonSerializable()
class AssetInformation {
  @JsonKey(name: 'serial_number')
  final String? serialNumber;
  @JsonKey(name: 'manufacturer')
  final String? manufacturer;
  @JsonKey(name: 'model')
  final String? model;
  @JsonKey(name: 'year')
  final int? year;
  @JsonKey(name: 'display_name')
  final String? displayName;

  const AssetInformation({
    this.serialNumber,
    this.manufacturer,
    this.model,
    this.year,
    this.displayName,
  });

  AssetInformation copyWith({
    String? serialNumber,
    String? manufacturer,
    String? model,
    int? year,
    String? displayName,
  }) {
    return AssetInformation(
      serialNumber: serialNumber ?? this.serialNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      year: year ?? this.year,
      displayName: displayName ?? this.displayName,
    );
  }

  factory AssetInformation.fromJson(Map<String, dynamic> json) =>
      _$AssetInformationFromJson(json);

  Map<String, dynamic> toJson() => _$AssetInformationToJson(this);
}

@JsonSerializable()
class AssetPolicy {
  @JsonKey(name: 'id')
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

  const AssetPolicy({
    required this.id,
    required this.schedulingActive,
    required this.activityState,
    this.activityStateReason,
    required this.minLevel,
    this.runImmediatelyConfig,
  });

  AssetPolicy copyWith({
    String? id,
    bool? schedulingActive,
    ActivityState? activityState,
    ActivityStateReason? activityStateReason,
    double? minLevel,
    RunImmediatelyConfig? runImmediatelyConfig,
  }) {
    return AssetPolicy(
      id: id ?? this.id,
      schedulingActive: schedulingActive ?? this.schedulingActive,
      activityState: activityState ?? this.activityState,
      activityStateReason: activityStateReason ?? this.activityStateReason,
      minLevel: minLevel ?? this.minLevel,
      runImmediatelyConfig: runImmediatelyConfig ?? this.runImmediatelyConfig,
    );
  }

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

  const AssetPolicyRequest({
    this.schedulingActive,
    this.minLevel,
    this.runImmediatelyConfig,
  });

  AssetPolicyRequest copyWith({
    bool? schedulingActive,
    double? minLevel,
    RunImmediatelyConfig? runImmediatelyConfig,
  }) {
    return AssetPolicyRequest(
      schedulingActive: schedulingActive ?? this.schedulingActive,
      minLevel: minLevel ?? this.minLevel,
      runImmediatelyConfig: runImmediatelyConfig ?? this.runImmediatelyConfig,
    );
  }

  factory AssetPolicyRequest.fromJson(Map<String, dynamic> json) =>
      _$AssetPolicyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AssetPolicyRequestToJson(this);
}

@JsonSerializable()
class StreamTokenResponse {
  @JsonKey(name: 'token')
  final String token;

  const StreamTokenResponse({
    required this.token,
  });

  StreamTokenResponse copyWith({
    String? token,
  }) {
    return StreamTokenResponse(
      token: token ?? this.token,
    );
  }

  factory StreamTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$StreamTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StreamTokenResponseToJson(this);
}

