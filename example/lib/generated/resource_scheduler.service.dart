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
    @Query('deadline_filter') DeadlineFilterEnum? deadlineFilter,
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
    @Query('order') SortOrderEnum? order,
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
    @Query('limit') int? limit,
    @Query('page') int? page,
    @Query('sort_order') SortOrderEnum? sortOrder,
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

class ResourceSchedulerApi {
  final ResourceSchedulerService _service;

  ResourceSchedulerApi(ChopperClient client) : _service = ResourceSchedulerService.create(client);

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

