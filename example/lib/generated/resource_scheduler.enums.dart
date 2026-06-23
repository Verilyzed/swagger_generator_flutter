// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:json_annotation/json_annotation.dart';

enum AggregationEnum {
  @JsonValue('month')
  month,
  @JsonValue('year')
  year,
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
}

enum TaskEndTriggerEnum {
  @JsonValue('LEVEL')
  level,
  @JsonValue('DATETIME')
  datetime,
}

enum TaskTypeEnum {
  @JsonValue('COST_OPTIMIZED')
  costOptimized,
  @JsonValue('MIN_LEVEL')
  minLevel,
  @JsonValue('IMMEDIATELY')
  immediately,
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
}

enum RunStateEnum {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('FINISHED')
  finished,
}

enum ActivityState {
  @JsonValue('SHOULD_RUN')
  shouldRun,
  @JsonValue('SHOULD_NOT_RUN')
  shouldNotRun,
  @JsonValue('INDETERMINATE')
  indeterminate,
}

enum ActivityStateReason {
  @JsonValue('BY_TASK')
  byTask,
  @JsonValue('BY_OVERRIDE')
  byOverride,
}

enum DeadlineFilterEnum {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('all')
  all,
}

enum DiscoveredAssetCapability {
  @JsonValue('FULLY_CAPABLE')
  fullyCapable,
  @JsonValue('INCAPABLE')
  incapable,
  @JsonValue('CHECKING_COMPATIBILITY')
  checkingCompatibility,
}

enum Domain {
  @JsonValue('Account')
  account,
  @JsonValue('Asset')
  asset,
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
}

enum TaskSortFieldEnum {
  @JsonValue('price_per_unit')
  pricePerUnit,
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
}

enum ResolutionAccess {
  @JsonValue('Remote')
  remote,
  @JsonValue('Physical')
  physical,
}

enum ResolutionAction {
  @JsonValue('Link')
  link,
  @JsonValue('LinkAdditionalAsset')
  linkAdditionalAsset,
}

enum ResolutionAgent {
  @JsonValue('User')
  user,
  @JsonValue('ThirdParty')
  thirdParty,
}

enum SortOrderEnum {
  @JsonValue('asc')
  asc,
  @JsonValue('desc')
  desc,
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
}

