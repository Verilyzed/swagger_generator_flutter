// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:chopper/chopper.dart';
import 'resource_scheduler.models.dart';
import 'resource_scheduler.enums.dart';

part 'resource_scheduler.service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class ResourceSchedulerService extends ChopperService {
  @GET(path: '/assets/{asset_id}/schedule')
  Future<Response<Schedule>> getScheduleForAsset({
    @Path('asset_id') required String assetId,
    @Query('deadline_filter') DeadlineFilterEnum deadlineFilter = DeadlineFilterEnum.all,
  });

  @POST(path: '/assets/{asset_id}/schedule')
  Future<Response<Schedule>> createSchedule({
    @Path('asset_id') required String assetId,
    @Body() required ScheduleCreateRequest body,
  });

  @PUT(path: '/assets/{asset_id}/schedule/{schedule_id}')
  Future<Response<Schedule>> updateSchedule({
    @Path('asset_id') required String assetId,
    @Path('schedule_id') required String scheduleId,
    @Body() required ScheduleUpdateRequest body,
  });

  @GET(path: '/assets')
  Future<Response<List<Asset>>> listAssets({
    @Query('account_id') required int accountId,
  });

  @GET(path: '/assets/{asset_id}')
  Future<Response<Asset>> getAsset({
    @Path('asset_id') required String assetId,
  });

  @GET(path: '/assets/{asset_id}/activity_status')
  Future<Response<ActivityStatus>> getAssetActivityStatus({
    @Path('asset_id') required String assetId,
  });

  @POST(path: '/assets/{asset_id}/refresh')
  Future<Response<dynamic>> refreshAsset({
    @Path('asset_id') required String assetId,
  });

  @GET(path: '/asset_policy/{asset_id}')
  Future<Response<AssetPolicy>> getAssetPolicy({
    @Path('asset_id') required String assetId,
  });

  @PATCH(path: '/asset_policy/{asset_id}')
  Future<Response<dynamic>> patchAssetPolicy({
    @Path('asset_id') required String assetId,
    @Body() required AssetPolicyRequest body,
  });

  @GET(path: '/assets/{asset_id}/tasks')
  Future<Response<List<Task>>> listTasksForAsset({
    @Path('asset_id') required String assetId,
    @Query('aggregation') AggregationEnum? aggregation,
    @Query('period') String? period,
    @Query('sort') TaskSortFieldEnum? sort,
    @Query('order') SortOrderEnum order = SortOrderEnum.asc,
    @Query('limit') int? limit,
  });

  @POST(path: '/assets/{asset_id}/stream_token')
  Future<Response<StreamTokenResponse>> getStreamTokenForAsset({
    @Path('asset_id') required String assetId,
  });

  @POST(path: '/tickets')
  Future<Response<TicketResponse>> createTicket({
    @Query('asset_id') required String assetId,
    @Body() required TicketInput body,
  });

  @POST(path: '/tickets/{ticket_id}/attachment')
  Future<Response<AttachmentResponse>> attachImageToTicket({
    @Path('ticket_id') required String ticketId,
    @Body() required AttachmentInput body,
  });

  @POST(path: '/accounts/{account_id}/link')
  Future<Response<ProviderLinkResponse>> postAccountLink({
    @Path('account_id') required String accountId,
  });

  @POST(path: '/accounts/{account_id}/relink')
  Future<Response<ProviderLinkResponse>> postAccountRelink({
    @Path('account_id') required String accountId,
  });

  @GET(path: '/accounts/{account_id}')
  Future<Response<Account>> getAccount({
    @Path('account_id') required String accountId,
  });

  @DELETE(path: '/accounts/{account_id}')
  Future<Response<dynamic>> deleteAccount({
    @Path('account_id') required String accountId,
  });

  @POST(path: '/accounts/{account_id}:select-asset')
  Future<Response<Account>> selectAsset({
    @Path('account_id') required String accountId,
    @Body() required SelectAssetRequest body,
  });

  @GET(path: '/system/features')
  Future<Response<FeatureFlagConfig>> getFeatures();

  @GET(path: '/assets/{asset_id}/runs')
  Future<Response<List<Run>>> listRunsForAsset({
    @Path('asset_id') required String assetId,
    @Query('limit') int limit = 5,
    @Query('page') int page = 0,
    @Query('sort_order') SortOrderEnum sortOrder = SortOrderEnum.desc,
    @Query('state') RunStateEnum? state,
  });

  @GET(path: '/assets/{asset_id}/runs/metrics')
  Future<Response<RunMetrics>> getRunMetrics({
    @Path('asset_id') required String assetId,
    @Query('aggregation') required AggregationEnum aggregation,
    @Query('period') String? period,
  });

  static ResourceSchedulerService create([ChopperClient? client]) =>
      _$ResourceSchedulerService(client);
}

