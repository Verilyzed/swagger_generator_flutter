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

enum TaskEndTriggerEnum {
  @JsonValue('LEVEL')
  level,
  @JsonValue('DATETIME')
  datetime,
  // Fallback for values not present in the spec.
  $unknown,
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

enum RunStateEnum {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('FINISHED')
  finished,
  // Fallback for values not present in the spec.
  $unknown,
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

enum ActivityStateReason {
  @JsonValue('BY_TASK')
  byTask,
  @JsonValue('BY_OVERRIDE')
  byOverride,
  // Fallback for values not present in the spec.
  $unknown,
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

enum Domain {
  @JsonValue('Account')
  account,
  @JsonValue('Asset')
  asset,
  // Fallback for values not present in the spec.
  $unknown,
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

enum TaskSortFieldEnum {
  @JsonValue('price_per_unit')
  pricePerUnit,
  // Fallback for values not present in the spec.
  $unknown,
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

enum ResolutionAccess {
  @JsonValue('Remote')
  remote,
  @JsonValue('Physical')
  physical,
  // Fallback for values not present in the spec.
  $unknown,
}

enum ResolutionAction {
  @JsonValue('Link')
  link,
  @JsonValue('LinkAdditionalAsset')
  linkAdditionalAsset,
  // Fallback for values not present in the spec.
  $unknown,
}

enum ResolutionAgent {
  @JsonValue('User')
  user,
  @JsonValue('ThirdParty')
  thirdParty,
  // Fallback for values not present in the spec.
  $unknown,
}

enum SortOrderEnum {
  @JsonValue('asc')
  asc,
  @JsonValue('desc')
  desc,
  // Fallback for values not present in the spec.
  $unknown,
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

