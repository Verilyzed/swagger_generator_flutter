// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'resource_scheduler.models.dart';
import 'resource_scheduler.enums.dart';

part 'resource_scheduler.service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class ResourceSchedulerService extends ChopperService {
  @GET(path: '/assets/{asset_id}/schedule')
  Future<Response<Schedule>> getScheduleForAsset(
    @Path('asset_id') String assetId,
    @Query('deadline_filter') DeadlineFilterEnum deadlineFilter,
  );

  @POST(path: '/assets/{asset_id}/schedule')
  Future<Response<Schedule>> createSchedule(
    @Path('asset_id') String assetId,
    @Body() ScheduleCreateRequest body,
  );

  @PUT(path: '/assets/{asset_id}/schedule/{schedule_id}')
  Future<Response<Schedule>> updateSchedule(
    @Path('asset_id') String assetId,
    @Path('schedule_id') String scheduleId,
    @Body() ScheduleUpdateRequest body,
  );

  @GET(path: '/assets')
  Future<Response<List<Asset>>> listAssets(
    @Query('account_id') int accountId,
  );

  @GET(path: '/assets/{asset_id}')
  Future<Response<Asset>> getAsset(
    @Path('asset_id') String assetId,
  );

  @GET(path: '/assets/{asset_id}/activity_status')
  Future<Response<ActivityStatus>> getAssetActivityStatus(
    @Path('asset_id') String assetId,
  );

  @POST(path: '/assets/{asset_id}/refresh')
  Future<Response<dynamic>> refreshAsset(
    @Path('asset_id') String assetId,
  );

  @GET(path: '/asset_policy/{asset_id}')
  Future<Response<AssetPolicy>> getAssetPolicy(
    @Path('asset_id') String assetId,
  );

  @PATCH(path: '/asset_policy/{asset_id}')
  Future<Response<dynamic>> patchAssetPolicy(
    @Path('asset_id') String assetId,
    @Body() AssetPolicyRequest body,
  );

  @GET(path: '/assets/{asset_id}/tasks')
  Future<Response<List<Task>>> listTasksForAsset(
    @Path('asset_id') String assetId,
    @Query('aggregation') AggregationEnum? aggregation,
    @Query('period') String? period,
    @Query('sort') TaskSortFieldEnum? sort,
    @Query('order') SortOrderEnum order,
    @Query('limit') int? limit,
  );

  @POST(path: '/assets/{asset_id}/stream_token')
  Future<Response<StreamTokenResponse>> getStreamTokenForAsset(
    @Path('asset_id') String assetId,
  );

  @POST(path: '/tickets')
  Future<Response<TicketResponse>> createTicket(
    @Query('asset_id') String assetId,
    @Body() TicketInput body,
  );

  @POST(path: '/tickets/{ticket_id}/attachment')
  Future<Response<AttachmentResponse>> attachImageToTicket(
    @Path('ticket_id') String ticketId,
    @Body() AttachmentInput body,
  );

  @POST(path: '/accounts/{account_id}/link')
  Future<Response<ProviderLinkResponse>> postAccountLink(
    @Path('account_id') String accountId,
  );

  @POST(path: '/accounts/{account_id}/relink')
  Future<Response<ProviderLinkResponse>> postAccountRelink(
    @Path('account_id') String accountId,
  );

  @GET(path: '/accounts/{account_id}')
  Future<Response<Account>> getAccount(
    @Path('account_id') String accountId,
  );

  @DELETE(path: '/accounts/{account_id}')
  Future<Response<dynamic>> deleteAccount(
    @Path('account_id') String accountId,
  );

  @POST(path: '/accounts/{account_id}:select-asset')
  Future<Response<Account>> selectAsset(
    @Path('account_id') String accountId,
    @Body() SelectAssetRequest body,
  );

  @GET(path: '/system/features')
  Future<Response<FeatureFlagConfig>> getFeatures(
  );

  @GET(path: '/assets/{asset_id}/runs')
  Future<Response<List<Run>>> listRunsForAsset(
    @Path('asset_id') String assetId,
    @Query('limit') int limit,
    @Query('page') int page,
    @Query('sort_order') SortOrderEnum sortOrder,
    @Query('state') RunStateEnum? state,
  );

  @GET(path: '/assets/{asset_id}/runs/metrics')
  Future<Response<RunMetrics>> getRunMetrics(
    @Path('asset_id') String assetId,
    @Query('aggregation') AggregationEnum aggregation,
    @Query('period') String? period,
  );

  static ResourceSchedulerService create([ChopperClient? client]) =>
      _$ResourceSchedulerService(client);
}

