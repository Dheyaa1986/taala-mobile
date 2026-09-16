import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/network/api_response_helper.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';

abstract class AppPublicInfoRepository {
  Future<Either<CustomException, AppPublicInfoModel>> getPublicInfo({
    bool forceRefresh = false,
  });

  void clearCache();
}

class AppPublicInfoRepositoryImpl extends Repository
    implements AppPublicInfoRepository {
  AppPublicInfoModel? _cache;

  @override
  void clearCache() => _cache = null;

  @override
  Future<Either<CustomException, AppPublicInfoModel>> getPublicInfo({
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _cache != null) {
      return Future.value(Right(_cache!));
    }

    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.appPublicInfo,
          method: RequestMethod.get,
          requestWithOutToken: true,
        ),
      );
      final model = AppPublicInfoModel.fromJson(
        ApiResponseHelper.unwrap(json),
      );
      _cache = model;
      return model;
    });
  }
}
