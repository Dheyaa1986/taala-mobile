import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/models/base_response_model.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/profile/data/models/user_profile_model.dart';

class ProfileRepository extends Repository {
  Future<Either<CustomException, UserProfileModel>> getMyProfile() {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(AppUrls.authMe, method: RequestMethod.get),
        mapper: (json) => UserProfileModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, BaseResponseModel>> updateClientProfile({
    required String userId,
    required String name,
    File? image,
  }) {
    return exceptionHandler(() async {
      final body = <String, dynamic>{'name': name};
      if (image != null) {
        body['profile'] = image;
      }

      return dioService.callApi(
        NetworkRequest(
          AppUrls.clientUpdateProfile(userId),
          method: RequestMethod.patch,
          body: body,
          isFormData: image != null,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, BaseResponseModel>> updateProviderAvailability({
    required bool isAvailable,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.providerUpdateProfile,
          method: RequestMethod.patch,
          body: {'providerStatus': isAvailable},
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, BaseResponseModel>> updateProviderLiveLocation({
    required double latitude,
    required double longitude,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.providerLiveLocation,
          method: RequestMethod.patch,
          body: {
            'latitude': latitude,
            'longitude': longitude,
          },
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, BaseResponseModel>> updateProviderProfile({
    required String name,
    File? image,
  }) {
    return exceptionHandler(() async {
      final body = <String, dynamic>{'name': name};
      if (image != null) {
        body['profile'] = image;
      }

      return dioService.callApi(
        NetworkRequest(
          AppUrls.providerUpdateProfile,
          method: RequestMethod.patch,
          body: body,
          isFormData: image != null,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }
}
