// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_scheduler.models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachmentInput _$AttachmentInputFromJson(Map<String, dynamic> json) =>
    AttachmentInput(
      filename: json['filename'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$AttachmentInputToJson(AttachmentInput instance) =>
    <String, dynamic>{
      'filename': instance.filename,
      'content': instance.content,
    };

AttachmentResponse _$AttachmentResponseFromJson(Map<String, dynamic> json) =>
    AttachmentResponse(
      attachmentId: json['attachment_id'] as String,
      filename: json['filename'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$AttachmentResponseToJson(AttachmentResponse instance) =>
    <String, dynamic>{
      'attachment_id': instance.attachmentId,
      'filename': instance.filename,
      'size': instance.size,
    };

BadInputResponse _$BadInputResponseFromJson(Map<String, dynamic> json) =>
    BadInputResponse(
      detail: json['detail'] as String,
      errorCode:
          $enumDecodeNullable(
            _$ErrorCodeEnumMap,
            json['error_code'],
            unknownValue: ErrorCode.$unknown,
          ) ??
          ErrorCode.badInput,
    );

Map<String, dynamic> _$BadInputResponseToJson(BadInputResponse instance) =>
    <String, dynamic>{
      'detail': instance.detail,
      'error_code': _$ErrorCodeEnumMap[instance.errorCode]!,
    };

const _$ErrorCodeEnumMap = {
  ErrorCode.internalServerError: 'INTERNAL_SERVER_ERROR',
  ErrorCode.resourceNotFound: 'RESOURCE_NOT_FOUND',
  ErrorCode.notAllowed: 'NOT_ALLOWED',
  ErrorCode.badInput: 'BAD_INPUT',
  ErrorCode.noUser: 'NO_USER',
  ErrorCode.accountEnded: 'ACCOUNT_ENDED',
  ErrorCode.accountNoPlan: 'ACCOUNT_NO_PLAN',
  ErrorCode.accountNoActivePlan: 'ACCOUNT_NO_ACTIVE_PLAN',
  ErrorCode.linkAssetAlreadyConnected: 'LINK_ASSET_ALREADY_CONNECTED',
  ErrorCode.relinkNoAssetLinked: 'RELINK_NO_ASSET_LINKED',
  ErrorCode.assetDeletionPending: 'ASSET_DELETION_PENDING',
  ErrorCode.locationLookupFailed: 'LOCATION_LOOKUP_FAILED',
  ErrorCode.$unknown: r'$unknown',
};

RunImmediatelyConfig _$RunImmediatelyConfigFromJson(
  Map<String, dynamic> json,
) => RunImmediatelyConfig(maxLevel: (json['max_level'] as num?)?.toDouble());

Map<String, dynamic> _$RunImmediatelyConfigToJson(
  RunImmediatelyConfig instance,
) => <String, dynamic>{'max_level': instance.maxLevel};

AssetState _$AssetStateFromJson(Map<String, dynamic> json) => AssetState(
  level: (json['level'] as num?)?.toDouble(),
  range: (json['range'] as num?)?.toDouble(),
  isConnected: json['is_connected'] as bool?,
  isActive: json['is_active'] as bool?,
  isComplete: json['is_complete'] as bool?,
  capacity: (json['capacity'] as num?)?.toDouble(),
  levelLimit: (json['level_limit'] as num?)?.toDouble(),
  throughput: (json['throughput'] as num?)?.toDouble(),
  timeRemaining: (json['time_remaining'] as num?)?.toDouble(),
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
  maxRate: (json['max_rate'] as num?)?.toDouble(),
  connectionState: $enumDecode(
    _$ConnectionStateEnumMap,
    json['connection_state'],
    unknownValue: ConnectionState.$unknown,
  ),
);

Map<String, dynamic> _$AssetStateToJson(AssetState instance) =>
    <String, dynamic>{
      'level': instance.level,
      'range': instance.range,
      'is_connected': instance.isConnected,
      'is_active': instance.isActive,
      'is_complete': instance.isComplete,
      'capacity': instance.capacity,
      'level_limit': instance.levelLimit,
      'throughput': instance.throughput,
      'time_remaining': instance.timeRemaining,
      'last_updated': instance.lastUpdated?.toIso8601String(),
      'max_rate': instance.maxRate,
      'connection_state': _$ConnectionStateEnumMap[instance.connectionState]!,
    };

const _$ConnectionStateEnumMap = {
  ConnectionState.unknown: 'UNKNOWN',
  ConnectionState.disconnected: 'DISCONNECTED',
  ConnectionState.connectedInitializing: 'CONNECTED:INITIALIZING',
  ConnectionState.connectedActive: 'CONNECTED:ACTIVE',
  ConnectionState.connectedStopped: 'CONNECTED:STOPPED',
  ConnectionState.connectedComplete: 'CONNECTED:COMPLETE',
  ConnectionState.connectedNoPower: 'CONNECTED:NO_POWER',
  ConnectionState.connectedFault: 'CONNECTED:FAULT',
  ConnectionState.connectedDraining: 'CONNECTED:DRAINING',
  ConnectionState.$unknown: r'$unknown',
};

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String,
  assetId: json['asset_id'] as String,
  calculatedStart: DateTime.parse(json['calculated_start'] as String),
  calculatedEnd: DateTime.parse(json['calculated_end'] as String),
  state: $enumDecode(
    _$TaskStateEnumEnumMap,
    json['state'],
    unknownValue: TaskStateEnum.$unknown,
  ),
  targetDate: DateTime.parse(json['target_date'] as String),
  type:
      $enumDecodeNullable(
        _$TaskTypeEnumEnumMap,
        json['type'],
        unknownValue: TaskTypeEnum.$unknown,
      ) ??
      TaskTypeEnum.costOptimized,
  endTrigger: $enumDecodeNullable(
    _$TaskEndTriggerEnumEnumMap,
    json['end_trigger'],
    unknownValue: TaskEndTriggerEnum.$unknown,
  ),
  targetLevel: (json['target_level'] as num?)?.toDouble(),
  costs: (json['costs'] as num?)?.toDouble(),
  totalQuantity: (json['total_quantity'] as num?)?.toDouble(),
  pricePerUnit: (json['price_per_unit'] as num?)?.toDouble(),
  failureReason: json['failure_reason'] == null
      ? null
      : FailureReason.fromJson(json['failure_reason'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'asset_id': instance.assetId,
  'calculated_start': instance.calculatedStart.toIso8601String(),
  'calculated_end': instance.calculatedEnd.toIso8601String(),
  'state': _$TaskStateEnumEnumMap[instance.state]!,
  'target_date': instance.targetDate.toIso8601String(),
  'type': _$TaskTypeEnumEnumMap[instance.type]!,
  'end_trigger': _$TaskEndTriggerEnumEnumMap[instance.endTrigger],
  'target_level': instance.targetLevel,
  'costs': instance.costs,
  'total_quantity': instance.totalQuantity,
  'price_per_unit': instance.pricePerUnit,
  'failure_reason': instance.failureReason,
};

const _$TaskStateEnumEnumMap = {
  TaskStateEnum.planned: 'PLANNED',
  TaskStateEnum.running: 'RUNNING',
  TaskStateEnum.finished: 'FINISHED',
  TaskStateEnum.failed: 'FAILED',
  TaskStateEnum.triggeredStart: 'TRIGGERED_START',
  TaskStateEnum.triggeredStop: 'TRIGGERED_STOP',
  TaskStateEnum.$unknown: r'$unknown',
};

const _$TaskTypeEnumEnumMap = {
  TaskTypeEnum.costOptimized: 'COST_OPTIMIZED',
  TaskTypeEnum.minLevel: 'MIN_LEVEL',
  TaskTypeEnum.immediately: 'IMMEDIATELY',
  TaskTypeEnum.$unknown: r'$unknown',
};

const _$TaskEndTriggerEnumEnumMap = {
  TaskEndTriggerEnum.level: 'LEVEL',
  TaskEndTriggerEnum.datetime: 'DATETIME',
  TaskEndTriggerEnum.$unknown: r'$unknown',
};

Run _$RunFromJson(Map<String, dynamic> json) => Run(
  id: json['id'] as String,
  assetId: json['asset_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
  targetDate: DateTime.parse(json['target_date'] as String),
  targetLevel: json['target_level'] == null
      ? null
      : Percent.fromJson(json['target_level'] as Map<String, dynamic>),
  state: $enumDecode(
    _$RunStateEnumEnumMap,
    json['state'],
    unknownValue: RunStateEnum.$unknown,
  ),
  tasks: (json['tasks'] as List<dynamic>)
      .map((e) => Task.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalQuantity: json['total_quantity'] == null
      ? null
      : Quantity.fromJson(json['total_quantity'] as Map<String, dynamic>),
  totalCosts: json['total_costs'] == null
      ? null
      : Money.fromJson(json['total_costs'] as Map<String, dynamic>),
  avgPricePerUnit: json['avg_price_per_unit'] == null
      ? null
      : Money.fromJson(json['avg_price_per_unit'] as Map<String, dynamic>),
  baselineCosts: json['baseline_costs'] == null
      ? null
      : Money.fromJson(json['baseline_costs'] as Map<String, dynamic>),
  savings: json['savings'] == null
      ? null
      : Money.fromJson(json['savings'] as Map<String, dynamic>),
  savingsPct: json['savings_pct'] == null
      ? null
      : Percent.fromJson(json['savings_pct'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RunToJson(Run instance) => <String, dynamic>{
  'id': instance.id,
  'asset_id': instance.assetId,
  'created_at': instance.createdAt.toIso8601String(),
  'ended_at': instance.endedAt?.toIso8601String(),
  'target_date': instance.targetDate.toIso8601String(),
  'target_level': instance.targetLevel,
  'state': _$RunStateEnumEnumMap[instance.state]!,
  'tasks': instance.tasks,
  'total_quantity': instance.totalQuantity,
  'total_costs': instance.totalCosts,
  'avg_price_per_unit': instance.avgPricePerUnit,
  'baseline_costs': instance.baselineCosts,
  'savings': instance.savings,
  'savings_pct': instance.savingsPct,
};

const _$RunStateEnumEnumMap = {
  RunStateEnum.active: 'ACTIVE',
  RunStateEnum.finished: 'FINISHED',
  RunStateEnum.$unknown: r'$unknown',
};

ActivityStatus _$ActivityStatusFromJson(Map<String, dynamic> json) =>
    ActivityStatus(
      assetId: json['asset_id'] as String,
      activityReason: $enumDecodeNullable(
        _$ActivityReasonEnumMap,
        json['activity_reason'],
        unknownValue: ActivityReason.$unknown,
      ),
    );

Map<String, dynamic> _$ActivityStatusToJson(ActivityStatus instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'activity_reason': _$ActivityReasonEnumMap[instance.activityReason],
    };

const _$ActivityReasonEnumMap = {
  ActivityReason.costOptimized: 'COST_OPTIMIZED',
  ActivityReason.minLevel: 'MIN_LEVEL',
  ActivityReason.immediately: 'IMMEDIATELY',
  ActivityReason.initializing: 'INITIALIZING',
  ActivityReason.manual: 'MANUAL',
  ActivityReason.$unknown: r'$unknown',
};

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  providerUserId: json['provider_user_id'] as String,
  accountId: json['account_id'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
  selectedAsset: json['selected_asset'] == null
      ? null
      : DiscoveredAsset.fromJson(
          json['selected_asset'] as Map<String, dynamic>,
        ),
  discoveredAssets: (json['discovered_assets'] as List<dynamic>?)
      ?.map((e) => DiscoveredAsset.fromJson(e as Map<String, dynamic>))
      .toList(),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'provider_user_id': instance.providerUserId,
  'account_id': instance.accountId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'created_at': instance.createdAt.toIso8601String(),
  'selected_asset': instance.selectedAsset,
  'discovered_assets': instance.discoveredAssets,
  'updated_at': instance.updatedAt?.toIso8601String(),
};

DeadlineSlot _$DeadlineSlotFromJson(Map<String, dynamic> json) => DeadlineSlot(
  targetTime: json['target_time'] as String,
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$DeadlineSlotToJson(DeadlineSlot instance) =>
    <String, dynamic>{
      'target_time': instance.targetTime,
      'active': instance.active,
    };

DiscoveredAsset _$DiscoveredAssetFromJson(Map<String, dynamic> json) =>
    DiscoveredAsset(
      assetId: json['asset_id'] as String,
      assetInformation: AssetInformation.fromJson(
        json['asset_information'] as Map<String, dynamic>,
      ),
      capability: $enumDecode(
        _$DiscoveredAssetCapabilityEnumMap,
        json['capability'],
        unknownValue: DiscoveredAssetCapability.$unknown,
      ),
      hasInterventions: json['has_interventions'] as bool,
    );

Map<String, dynamic> _$DiscoveredAssetToJson(DiscoveredAsset instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'asset_information': instance.assetInformation,
      'capability': _$DiscoveredAssetCapabilityEnumMap[instance.capability]!,
      'has_interventions': instance.hasInterventions,
    };

const _$DiscoveredAssetCapabilityEnumMap = {
  DiscoveredAssetCapability.fullyCapable: 'FULLY_CAPABLE',
  DiscoveredAssetCapability.incapable: 'INCAPABLE',
  DiscoveredAssetCapability.checkingCompatibility: 'CHECKING_COMPATIBILITY',
  DiscoveredAssetCapability.$unknown: r'$unknown',
};

ProviderLinkResponse _$ProviderLinkResponseFromJson(
  Map<String, dynamic> json,
) => ProviderLinkResponse(
  linkUrl: json['linkUrl'] as String,
  linkToken: json['linkToken'] as String,
);

Map<String, dynamic> _$ProviderLinkResponseToJson(
  ProviderLinkResponse instance,
) => <String, dynamic>{
  'linkUrl': instance.linkUrl,
  'linkToken': instance.linkToken,
};

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      detail: json['detail'] as String,
      errorId: json['error_id'] as String?,
      errorCode:
          $enumDecodeNullable(
            _$ErrorCodeEnumMap,
            json['error_code'],
            unknownValue: ErrorCode.$unknown,
          ) ??
          ErrorCode.internalServerError,
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'detail': instance.detail,
      'error_id': instance.errorId,
      'error_code': _$ErrorCodeEnumMap[instance.errorCode]!,
    };

Money _$MoneyFromJson(Map<String, dynamic> json) => Money(
  value: json['value'] as String?,
  unit: json['unit'] as String? ?? 'USD',
);

Map<String, dynamic> _$MoneyToJson(Money instance) => <String, dynamic>{
  'value': instance.value,
  'unit': instance.unit,
};

FailureReason _$FailureReasonFromJson(Map<String, dynamic> json) =>
    FailureReason(
      type: $enumDecode(
        _$FailureReasonTypeEnumEnumMap,
        json['type'],
        unknownValue: FailureReasonTypeEnum.$unknown,
      ),
      detail: json['detail'] as String,
    );

Map<String, dynamic> _$FailureReasonToJson(FailureReason instance) =>
    <String, dynamic>{
      'type': _$FailureReasonTypeEnumEnumMap[instance.type]!,
      'detail': instance.detail,
    };

const _$FailureReasonTypeEnumEnumMap = {
  FailureReasonTypeEnum.noResponse: 'NO_RESPONSE',
  FailureReasonTypeEnum.failedPrecondition: 'FAILED_PRECONDITION',
  FailureReasonTypeEnum.unnecessary: 'UNNECESSARY',
  FailureReasonTypeEnum.notFound: 'NOT_FOUND',
  FailureReasonTypeEnum.$unknown: r'$unknown',
};

FeatureFlagConfig _$FeatureFlagConfigFromJson(Map<String, dynamic> json) =>
    FeatureFlagConfig(
      scheduling: SchedulingStatus.fromJson(
        json['scheduling'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$FeatureFlagConfigToJson(FeatureFlagConfig instance) =>
    <String, dynamic>{'scheduling': instance.scheduling};

HttpValidationError _$HttpValidationErrorFromJson(Map<String, dynamic> json) =>
    HttpValidationError(
      detail: (json['detail'] as List<dynamic>?)
          ?.map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HttpValidationErrorToJson(
  HttpValidationError instance,
) => <String, dynamic>{'detail': instance.detail};

Intervention _$InterventionFromJson(Map<String, dynamic> json) => Intervention(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  domain: $enumDecode(
    _$DomainEnumMap,
    json['domain'],
    unknownValue: Domain.$unknown,
  ),
  access: $enumDecode(
    _$ResolutionAccessEnumMap,
    json['access'],
    unknownValue: ResolutionAccess.$unknown,
  ),
  agent: $enumDecode(
    _$ResolutionAgentEnumMap,
    json['agent'],
    unknownValue: ResolutionAgent.$unknown,
  ),
  action: $enumDecodeNullable(
    _$ResolutionActionEnumMap,
    json['action'],
    unknownValue: ResolutionAction.$unknown,
  ),
);

Map<String, dynamic> _$InterventionToJson(Intervention instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'domain': _$DomainEnumMap[instance.domain]!,
      'access': _$ResolutionAccessEnumMap[instance.access]!,
      'agent': _$ResolutionAgentEnumMap[instance.agent]!,
      'action': _$ResolutionActionEnumMap[instance.action],
    };

const _$DomainEnumMap = {
  Domain.account: 'Account',
  Domain.asset: 'Asset',
  Domain.$unknown: r'$unknown',
};

const _$ResolutionAccessEnumMap = {
  ResolutionAccess.remote: 'Remote',
  ResolutionAccess.physical: 'Physical',
  ResolutionAccess.$unknown: r'$unknown',
};

const _$ResolutionAgentEnumMap = {
  ResolutionAgent.user: 'User',
  ResolutionAgent.thirdParty: 'ThirdParty',
  ResolutionAgent.$unknown: r'$unknown',
};

const _$ResolutionActionEnumMap = {
  ResolutionAction.link: 'Link',
  ResolutionAction.linkAdditionalAsset: 'LinkAdditionalAsset',
  ResolutionAction.$unknown: r'$unknown',
};

Quantity _$QuantityFromJson(Map<String, dynamic> json) => Quantity(
  value: (json['value'] as num?)?.toDouble(),
  unit: json['unit'] as String? ?? 'units',
);

Map<String, dynamic> _$QuantityToJson(Quantity instance) => <String, dynamic>{
  'value': instance.value,
  'unit': instance.unit,
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  longitude: (json['longitude'] as num?)?.toDouble(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
  atBase: json['at_base'] as bool,
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'longitude': instance.longitude,
  'latitude': instance.latitude,
  'last_updated': instance.lastUpdated?.toIso8601String(),
  'at_base': instance.atBase,
};

MetricValue _$MetricValueFromJson(Map<String, dynamic> json) => MetricValue(
  value: (json['value'] as num).toInt(),
  previousValue: (json['previous_value'] as num).toInt(),
  trend: Percent.fromJson(json['trend'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MetricValueToJson(MetricValue instance) =>
    <String, dynamic>{
      'value': instance.value,
      'previous_value': instance.previousValue,
      'trend': instance.trend,
    };

NotAllowedResponse _$NotAllowedResponseFromJson(Map<String, dynamic> json) =>
    NotAllowedResponse(
      detail: json['detail'] as String,
      errorCode:
          $enumDecodeNullable(
            _$ErrorCodeEnumMap,
            json['error_code'],
            unknownValue: ErrorCode.$unknown,
          ) ??
          ErrorCode.notAllowed,
    );

Map<String, dynamic> _$NotAllowedResponseToJson(NotAllowedResponse instance) =>
    <String, dynamic>{
      'detail': instance.detail,
      'error_code': _$ErrorCodeEnumMap[instance.errorCode]!,
    };

NotFoundResponse _$NotFoundResponseFromJson(Map<String, dynamic> json) =>
    NotFoundResponse(
      detail: json['detail'] as String? ?? 'Ressource not found',
      errorCode:
          $enumDecodeNullable(
            _$ErrorCodeEnumMap,
            json['error_code'],
            unknownValue: ErrorCode.$unknown,
          ) ??
          ErrorCode.resourceNotFound,
      entity: json['entity'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$NotFoundResponseToJson(NotFoundResponse instance) =>
    <String, dynamic>{
      'detail': instance.detail,
      'error_code': _$ErrorCodeEnumMap[instance.errorCode]!,
      'entity': instance.entity,
      'id': instance.id,
    };

UsageCounter _$UsageCounterFromJson(Map<String, dynamic> json) => UsageCounter(
  reading: (json['reading'] as num?)?.toDouble(),
  lastUpdated: json['last_updated'] == null
      ? null
      : DateTime.parse(json['last_updated'] as String),
);

Map<String, dynamic> _$UsageCounterToJson(UsageCounter instance) =>
    <String, dynamic>{
      'reading': instance.reading,
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };

Percent _$PercentFromJson(Map<String, dynamic> json) => Percent(
  value: (json['value'] as num?)?.toDouble(),
  unit: json['unit'] as String? ?? '%',
);

Map<String, dynamic> _$PercentToJson(Percent instance) => <String, dynamic>{
  'value': instance.value,
  'unit': instance.unit,
};

PriceMetric _$PriceMetricFromJson(Map<String, dynamic> json) => PriceMetric(
  value: json['value'] as String?,
  unit: json['unit'] as String? ?? 'USD',
  pct: Percent.fromJson(json['pct'] as Map<String, dynamic>),
  trend: Percent.fromJson(json['trend'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PriceMetricToJson(PriceMetric instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': instance.unit,
      'pct': instance.pct,
      'trend': instance.trend,
    };

SelectAssetRequest _$SelectAssetRequestFromJson(Map<String, dynamic> json) =>
    SelectAssetRequest(assetId: json['asset_id'] as String);

Map<String, dynamic> _$SelectAssetRequestToJson(SelectAssetRequest instance) =>
    <String, dynamic>{'asset_id': instance.assetId};

RunMetrics _$RunMetricsFromJson(Map<String, dynamic> json) => RunMetrics(
  period: json['period'] as String,
  aggregation: $enumDecode(
    _$AggregationEnumEnumMap,
    json['aggregation'],
    unknownValue: AggregationEnum.$unknown,
  ),
  sessionCount: MetricValue.fromJson(
    json['session_count'] as Map<String, dynamic>,
  ),
  actualCosts: Money.fromJson(json['actual_costs'] as Map<String, dynamic>),
  baselineCosts: Money.fromJson(json['baseline_costs'] as Map<String, dynamic>),
  savings: PriceMetric.fromJson(json['savings'] as Map<String, dynamic>),
  weightedAvgPricePerUnit: PriceMetric.fromJson(
    json['weighted_avg_price_per_unit'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RunMetricsToJson(RunMetrics instance) =>
    <String, dynamic>{
      'period': instance.period,
      'aggregation': _$AggregationEnumEnumMap[instance.aggregation]!,
      'session_count': instance.sessionCount,
      'actual_costs': instance.actualCosts,
      'baseline_costs': instance.baselineCosts,
      'savings': instance.savings,
      'weighted_avg_price_per_unit': instance.weightedAvgPricePerUnit,
    };

const _$AggregationEnumEnumMap = {
  AggregationEnum.month: 'month',
  AggregationEnum.year: 'year',
  AggregationEnum.$unknown: r'$unknown',
};

SchedulingStatus _$SchedulingStatusFromJson(Map<String, dynamic> json) =>
    SchedulingStatus(enabled: json['enabled'] as bool);

Map<String, dynamic> _$SchedulingStatusToJson(SchedulingStatus instance) =>
    <String, dynamic>{'enabled': instance.enabled};

TicketInput _$TicketInputFromJson(Map<String, dynamic> json) => TicketInput(
  subject: json['subject'] as String,
  description: json['description'] as String,
  occurredAt: const DateConverter().fromJson(json['occurred_at'] as String),
  email: json['email'] as String,
);

Map<String, dynamic> _$TicketInputToJson(TicketInput instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'description': instance.description,
      'occurred_at': const DateConverter().toJson(instance.occurredAt),
      'email': instance.email,
    };

TicketResponse _$TicketResponseFromJson(Map<String, dynamic> json) =>
    TicketResponse(
      ticketId: json['ticket_id'] as String,
      requestUrl: json['request_url'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      success: json['success'] as bool,
    );

Map<String, dynamic> _$TicketResponseToJson(TicketResponse instance) =>
    <String, dynamic>{
      'ticket_id': instance.ticketId,
      'request_url': instance.requestUrl,
      'status': instance.status,
      'message': instance.message,
      'success': instance.success,
    };

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  id: json['id'] as String,
  assetId: json['asset_id'] as String,
  deadlineSchedule: (json['deadline_schedule'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => DeadlineSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'asset_id': instance.assetId,
  'deadline_schedule': instance.deadlineSchedule,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

ScheduleCreateRequest _$ScheduleCreateRequestFromJson(
  Map<String, dynamic> json,
) => ScheduleCreateRequest(
  deadlineSchedule: (json['deadline_schedule'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => DeadlineSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$ScheduleCreateRequestToJson(
  ScheduleCreateRequest instance,
) => <String, dynamic>{'deadline_schedule': instance.deadlineSchedule};

ScheduleUpdateRequest _$ScheduleUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ScheduleUpdateRequest(
  deadlineSchedule: (json['deadline_schedule'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => DeadlineSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$ScheduleUpdateRequestToJson(
  ScheduleUpdateRequest instance,
) => <String, dynamic>{'deadline_schedule': instance.deadlineSchedule};

ValidationError _$ValidationErrorFromJson(Map<String, dynamic> json) =>
    ValidationError(
      loc: json['loc'] as List<dynamic>,
      msg: json['msg'] as String,
      type: json['type'] as String,
      input: json['input'],
      ctx: json['ctx'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ValidationErrorToJson(ValidationError instance) =>
    <String, dynamic>{
      'loc': instance.loc,
      'msg': instance.msg,
      'type': instance.type,
      'input': instance.input,
      'ctx': instance.ctx,
    };

Asset _$AssetFromJson(Map<String, dynamic> json) => Asset(
  assetId: json['asset_id'] as String,
  lastSeen: DateTime.parse(json['last_seen'] as String),
  isReachable: json['is_reachable'] as bool?,
  assetInformation: AssetInformation.fromJson(
    json['asset_information'] as Map<String, dynamic>,
  ),
  resourceState: AssetState.fromJson(
    json['resource_state'] as Map<String, dynamic>,
  ),
  odometer: UsageCounter.fromJson(json['odometer'] as Map<String, dynamic>),
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  interventions: (json['interventions'] as List<dynamic>?)
      ?.map((e) => Intervention.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AssetToJson(Asset instance) => <String, dynamic>{
  'asset_id': instance.assetId,
  'last_seen': instance.lastSeen.toIso8601String(),
  'is_reachable': instance.isReachable,
  'asset_information': instance.assetInformation,
  'resource_state': instance.resourceState,
  'odometer': instance.odometer,
  'location': instance.location,
  'interventions': instance.interventions,
};

AssetInformation _$AssetInformationFromJson(Map<String, dynamic> json) =>
    AssetInformation(
      serialNumber: json['serial_number'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      year: (json['year'] as num?)?.toInt(),
      displayName: json['display_name'] as String?,
    );

Map<String, dynamic> _$AssetInformationToJson(AssetInformation instance) =>
    <String, dynamic>{
      'serial_number': instance.serialNumber,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'year': instance.year,
      'display_name': instance.displayName,
    };

AssetPolicy _$AssetPolicyFromJson(Map<String, dynamic> json) => AssetPolicy(
  id: json['id'] as String,
  schedulingActive: json['scheduling_active'] as bool,
  activityState: $enumDecode(
    _$ActivityStateEnumMap,
    json['activity_state'],
    unknownValue: ActivityState.$unknown,
  ),
  activityStateReason: $enumDecodeNullable(
    _$ActivityStateReasonEnumMap,
    json['activity_state_reason'],
    unknownValue: ActivityStateReason.$unknown,
  ),
  minLevel: (json['min_level'] as num).toDouble(),
  runImmediatelyConfig: json['run_immediately_config'] == null
      ? null
      : RunImmediatelyConfig.fromJson(
          json['run_immediately_config'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AssetPolicyToJson(AssetPolicy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scheduling_active': instance.schedulingActive,
      'activity_state': _$ActivityStateEnumMap[instance.activityState]!,
      'activity_state_reason':
          _$ActivityStateReasonEnumMap[instance.activityStateReason],
      'min_level': instance.minLevel,
      'run_immediately_config': instance.runImmediatelyConfig,
    };

const _$ActivityStateEnumMap = {
  ActivityState.shouldRun: 'SHOULD_RUN',
  ActivityState.shouldNotRun: 'SHOULD_NOT_RUN',
  ActivityState.indeterminate: 'INDETERMINATE',
  ActivityState.$unknown: r'$unknown',
};

const _$ActivityStateReasonEnumMap = {
  ActivityStateReason.byTask: 'BY_TASK',
  ActivityStateReason.byOverride: 'BY_OVERRIDE',
  ActivityStateReason.$unknown: r'$unknown',
};

AssetPolicyRequest _$AssetPolicyRequestFromJson(Map<String, dynamic> json) =>
    AssetPolicyRequest(
      schedulingActive: json['scheduling_active'] as bool?,
      minLevel: (json['min_level'] as num?)?.toDouble(),
      runImmediatelyConfig: json['run_immediately_config'] == null
          ? null
          : RunImmediatelyConfig.fromJson(
              json['run_immediately_config'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AssetPolicyRequestToJson(AssetPolicyRequest instance) =>
    <String, dynamic>{
      'scheduling_active': instance.schedulingActive,
      'min_level': instance.minLevel,
      'run_immediately_config': instance.runImmediatelyConfig,
    };

StreamTokenResponse _$StreamTokenResponseFromJson(Map<String, dynamic> json) =>
    StreamTokenResponse(token: json['token'] as String);

Map<String, dynamic> _$StreamTokenResponseToJson(
  StreamTokenResponse instance,
) => <String, dynamic>{'token': instance.token};
