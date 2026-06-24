// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';

enum AggregationEnum {
  @JsonValue('month')
  month,
  @JsonValue('year')
  year,
  // Fallback for values not present in the spec.
  $unknown,
}

extension AggregationEnumWire on AggregationEnum {
  String get wireValue => const {
    AggregationEnum.month: 'month',
    AggregationEnum.year: 'year',
  }[this] ?? '';
}

enum TaskStateEnum {
  @JsonValue('PLANNED')
  planned,
  @JsonValue('RUNNING')
  running,
  @JsonValue('FINISHED')
  finished,
  @JsonValue('FAILED')
  failed,
  @JsonValue('TRIGGERED_START')
  triggeredStart,
  @JsonValue('TRIGGERED_STOP')
  triggeredStop,
  // Fallback for values not present in the spec.
  $unknown,
}

extension TaskStateEnumWire on TaskStateEnum {
  String get wireValue => const {
    TaskStateEnum.planned: 'PLANNED',
    TaskStateEnum.running: 'RUNNING',
    TaskStateEnum.finished: 'FINISHED',
    TaskStateEnum.failed: 'FAILED',
    TaskStateEnum.triggeredStart: 'TRIGGERED_START',
    TaskStateEnum.triggeredStop: 'TRIGGERED_STOP',
  }[this] ?? '';
}

enum TaskEndTriggerEnum {
  @JsonValue('LEVEL')
  level,
  @JsonValue('DATETIME')
  datetime,
  // Fallback for values not present in the spec.
  $unknown,
}

extension TaskEndTriggerEnumWire on TaskEndTriggerEnum {
  String get wireValue => const {
    TaskEndTriggerEnum.level: 'LEVEL',
    TaskEndTriggerEnum.datetime: 'DATETIME',
  }[this] ?? '';
}

enum TaskTypeEnum {
  @JsonValue('COST_OPTIMIZED')
  costOptimized,
  @JsonValue('MIN_LEVEL')
  minLevel,
  @JsonValue('IMMEDIATELY')
  immediately,
  // Fallback for values not present in the spec.
  $unknown,
}

extension TaskTypeEnumWire on TaskTypeEnum {
  String get wireValue => const {
    TaskTypeEnum.costOptimized: 'COST_OPTIMIZED',
    TaskTypeEnum.minLevel: 'MIN_LEVEL',
    TaskTypeEnum.immediately: 'IMMEDIATELY',
  }[this] ?? '';
}

enum ActivityReason {
  @JsonValue('COST_OPTIMIZED')
  costOptimized,
  @JsonValue('MIN_LEVEL')
  minLevel,
  @JsonValue('IMMEDIATELY')
  immediately,
  @JsonValue('INITIALIZING')
  initializing,
  @JsonValue('MANUAL')
  manual,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ActivityReasonWire on ActivityReason {
  String get wireValue => const {
    ActivityReason.costOptimized: 'COST_OPTIMIZED',
    ActivityReason.minLevel: 'MIN_LEVEL',
    ActivityReason.immediately: 'IMMEDIATELY',
    ActivityReason.initializing: 'INITIALIZING',
    ActivityReason.manual: 'MANUAL',
  }[this] ?? '';
}

enum RunStateEnum {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('FINISHED')
  finished,
  // Fallback for values not present in the spec.
  $unknown,
}

extension RunStateEnumWire on RunStateEnum {
  String get wireValue => const {
    RunStateEnum.active: 'ACTIVE',
    RunStateEnum.finished: 'FINISHED',
  }[this] ?? '';
}

enum ActivityState {
  @JsonValue('SHOULD_RUN')
  shouldRun,
  @JsonValue('SHOULD_NOT_RUN')
  shouldNotRun,
  @JsonValue('INDETERMINATE')
  indeterminate,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ActivityStateWire on ActivityState {
  String get wireValue => const {
    ActivityState.shouldRun: 'SHOULD_RUN',
    ActivityState.shouldNotRun: 'SHOULD_NOT_RUN',
    ActivityState.indeterminate: 'INDETERMINATE',
  }[this] ?? '';
}

enum ActivityStateReason {
  @JsonValue('BY_TASK')
  byTask,
  @JsonValue('BY_OVERRIDE')
  byOverride,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ActivityStateReasonWire on ActivityStateReason {
  String get wireValue => const {
    ActivityStateReason.byTask: 'BY_TASK',
    ActivityStateReason.byOverride: 'BY_OVERRIDE',
  }[this] ?? '';
}

enum DeadlineFilterEnum {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('all')
  all,
  // Fallback for values not present in the spec.
  $unknown,
}

extension DeadlineFilterEnumWire on DeadlineFilterEnum {
  String get wireValue => const {
    DeadlineFilterEnum.active: 'active',
    DeadlineFilterEnum.inactive: 'inactive',
    DeadlineFilterEnum.all: 'all',
  }[this] ?? '';
}

enum DiscoveredAssetCapability {
  @JsonValue('FULLY_CAPABLE')
  fullyCapable,
  @JsonValue('INCAPABLE')
  incapable,
  @JsonValue('CHECKING_COMPATIBILITY')
  checkingCompatibility,
  // Fallback for values not present in the spec.
  $unknown,
}

extension DiscoveredAssetCapabilityWire on DiscoveredAssetCapability {
  String get wireValue => const {
    DiscoveredAssetCapability.fullyCapable: 'FULLY_CAPABLE',
    DiscoveredAssetCapability.incapable: 'INCAPABLE',
    DiscoveredAssetCapability.checkingCompatibility: 'CHECKING_COMPATIBILITY',
  }[this] ?? '';
}

enum Domain {
  @JsonValue('Account')
  account,
  @JsonValue('Asset')
  asset,
  // Fallback for values not present in the spec.
  $unknown,
}

extension DomainWire on Domain {
  String get wireValue => const {
    Domain.account: 'Account',
    Domain.asset: 'Asset',
  }[this] ?? '';
}

enum ErrorCode {
  @JsonValue('INTERNAL_SERVER_ERROR')
  internalServerError,
  @JsonValue('RESOURCE_NOT_FOUND')
  resourceNotFound,
  @JsonValue('NOT_ALLOWED')
  notAllowed,
  @JsonValue('BAD_INPUT')
  badInput,
  @JsonValue('NO_USER')
  noUser,
  @JsonValue('ACCOUNT_ENDED')
  accountEnded,
  @JsonValue('ACCOUNT_NO_PLAN')
  accountNoPlan,
  @JsonValue('ACCOUNT_NO_ACTIVE_PLAN')
  accountNoActivePlan,
  @JsonValue('LINK_ASSET_ALREADY_CONNECTED')
  linkAssetAlreadyConnected,
  @JsonValue('RELINK_NO_ASSET_LINKED')
  relinkNoAssetLinked,
  @JsonValue('ASSET_DELETION_PENDING')
  assetDeletionPending,
  @JsonValue('LOCATION_LOOKUP_FAILED')
  locationLookupFailed,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ErrorCodeWire on ErrorCode {
  String get wireValue => const {
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
  }[this] ?? '';
}

enum FailureReasonTypeEnum {
  @JsonValue('NO_RESPONSE')
  noResponse,
  @JsonValue('FAILED_PRECONDITION')
  failedPrecondition,
  @JsonValue('UNNECESSARY')
  unnecessary,
  @JsonValue('NOT_FOUND')
  notFound,
  // Fallback for values not present in the spec.
  $unknown,
}

extension FailureReasonTypeEnumWire on FailureReasonTypeEnum {
  String get wireValue => const {
    FailureReasonTypeEnum.noResponse: 'NO_RESPONSE',
    FailureReasonTypeEnum.failedPrecondition: 'FAILED_PRECONDITION',
    FailureReasonTypeEnum.unnecessary: 'UNNECESSARY',
    FailureReasonTypeEnum.notFound: 'NOT_FOUND',
  }[this] ?? '';
}

enum TaskSortFieldEnum {
  @JsonValue('price_per_unit')
  pricePerUnit,
  // Fallback for values not present in the spec.
  $unknown,
}

extension TaskSortFieldEnumWire on TaskSortFieldEnum {
  String get wireValue => const {
    TaskSortFieldEnum.pricePerUnit: 'price_per_unit',
  }[this] ?? '';
}

enum ConnectionState {
  @JsonValue('UNKNOWN')
  unknown,
  @JsonValue('DISCONNECTED')
  disconnected,
  @JsonValue('CONNECTED:INITIALIZING')
  connectedInitializing,
  @JsonValue('CONNECTED:ACTIVE')
  connectedActive,
  @JsonValue('CONNECTED:STOPPED')
  connectedStopped,
  @JsonValue('CONNECTED:COMPLETE')
  connectedComplete,
  @JsonValue('CONNECTED:NO_POWER')
  connectedNoPower,
  @JsonValue('CONNECTED:FAULT')
  connectedFault,
  @JsonValue('CONNECTED:DRAINING')
  connectedDraining,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ConnectionStateWire on ConnectionState {
  String get wireValue => const {
    ConnectionState.unknown: 'UNKNOWN',
    ConnectionState.disconnected: 'DISCONNECTED',
    ConnectionState.connectedInitializing: 'CONNECTED:INITIALIZING',
    ConnectionState.connectedActive: 'CONNECTED:ACTIVE',
    ConnectionState.connectedStopped: 'CONNECTED:STOPPED',
    ConnectionState.connectedComplete: 'CONNECTED:COMPLETE',
    ConnectionState.connectedNoPower: 'CONNECTED:NO_POWER',
    ConnectionState.connectedFault: 'CONNECTED:FAULT',
    ConnectionState.connectedDraining: 'CONNECTED:DRAINING',
  }[this] ?? '';
}

enum ResolutionAccess {
  @JsonValue('Remote')
  remote,
  @JsonValue('Physical')
  physical,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ResolutionAccessWire on ResolutionAccess {
  String get wireValue => const {
    ResolutionAccess.remote: 'Remote',
    ResolutionAccess.physical: 'Physical',
  }[this] ?? '';
}

enum ResolutionAction {
  @JsonValue('Link')
  link,
  @JsonValue('LinkAdditionalAsset')
  linkAdditionalAsset,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ResolutionActionWire on ResolutionAction {
  String get wireValue => const {
    ResolutionAction.link: 'Link',
    ResolutionAction.linkAdditionalAsset: 'LinkAdditionalAsset',
  }[this] ?? '';
}

enum ResolutionAgent {
  @JsonValue('User')
  user,
  @JsonValue('ThirdParty')
  thirdParty,
  // Fallback for values not present in the spec.
  $unknown,
}

extension ResolutionAgentWire on ResolutionAgent {
  String get wireValue => const {
    ResolutionAgent.user: 'User',
    ResolutionAgent.thirdParty: 'ThirdParty',
  }[this] ?? '';
}

enum SortOrderEnum {
  @JsonValue('asc')
  asc,
  @JsonValue('desc')
  desc,
  // Fallback for values not present in the spec.
  $unknown,
}

extension SortOrderEnumWire on SortOrderEnum {
  String get wireValue => const {
    SortOrderEnum.asc: 'asc',
    SortOrderEnum.desc: 'desc',
  }[this] ?? '';
}

enum Weekday {
  @JsonValue('Monday')
  monday,
  @JsonValue('Tuesday')
  tuesday,
  @JsonValue('Wednesday')
  wednesday,
  @JsonValue('Thursday')
  thursday,
  @JsonValue('Friday')
  friday,
  @JsonValue('Saturday')
  saturday,
  @JsonValue('Sunday')
  sunday,
  // Fallback for values not present in the spec.
  $unknown,
}

extension WeekdayWire on Weekday {
  String get wireValue => const {
    Weekday.monday: 'Monday',
    Weekday.tuesday: 'Tuesday',
    Weekday.wednesday: 'Wednesday',
    Weekday.thursday: 'Thursday',
    Weekday.friday: 'Friday',
    Weekday.saturday: 'Saturday',
    Weekday.sunday: 'Sunday',
  }[this] ?? '';
}

