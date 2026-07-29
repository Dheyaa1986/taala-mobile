import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/error/exceptions.dart';
import 'package:taal/core/models/base_response_model.dart';
import 'package:taal/core/network/extensions.dart';
import 'package:taal/core/network/network_request.dart';
import 'package:taal/core/repository/repository.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/profile/data/models/user_profile_model.dart';
import 'package:taal/features/rating/data/models/provider_ratings_page_model.dart';

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
    bool completeProfile = false,
  }) {
    return exceptionHandler(() async {
      final body = <String, dynamic>{
        'name': name,
        if (completeProfile) 'completeProfile': true,
      };
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

  Future<Either<CustomException, BaseResponseModel>> deleteMyAccount() {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.deleteAccount,
          method: RequestMethod.delete,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, ServiceProviderModel>> getProviderProfile(
    String providerId,
  ) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.providerProfile(providerId),
          method: RequestMethod.get,
        ),
        mapper: (json) {
          final response = json['response'] as Map<String, dynamic>? ?? json;
          return ServiceProviderModel.fromJson(response);
        },
      );
    });
  }

  Future<Either<CustomException, BaseResponseModel>> createPortfolio({
    required String description,
    required List<File> images,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.providerPortfolioCreate,
          method: RequestMethod.post,
          formDataBody: await _portfolioFormData(description, images),
          isFormData: true,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, void>> deletePortfolio(String portfolioId) {
    return exceptionHandler(() async {
      await dioService.callApi(
        NetworkRequest(
          AppUrls.providerPortfolioDelete(portfolioId),
          method: RequestMethod.delete,
        ),
      );
    });
  }

  Future<Either<CustomException, BaseResponseModel>> rateProvider({
    required String providerId,
    required double value,
    String? comment,
  }) {
    return exceptionHandler(() async {
      final body = <String, dynamic>{
        'value': value,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      };

      return dioService.callApi(
        NetworkRequest(
          AppUrls.providerRate(providerId),
          method: RequestMethod.post,
          body: body,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, BaseResponseModel>> rateApp({
    required double value,
    String? comment,
  }) {
    return exceptionHandler(() async {
      final body = <String, dynamic>{
        'value': value,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      };

      return dioService.callApi(
        NetworkRequest(
          AppUrls.rateApp,
          method: RequestMethod.post,
          body: body,
        ),
        mapper: (json) => BaseResponseModel.fromJson(json),
      );
    });
  }

  Future<Either<CustomException, ProviderRatingsPageModel>>
      getMyProviderRatings({
    int page = 1,
    int limit = 10,
  }) {
    return exceptionHandler(() async {
      return dioService.callApi(
        NetworkRequest(
          AppUrls.providerRatingsMe,
          method: RequestMethod.get,
          queryParameters: {'page': page, 'limit': limit},
        ),
        mapper: (json) => ProviderRatingsPageModel.fromJson(json),
      );
    });
  }

  Future<FormData> _portfolioFormData(
    String description,
    List<File> images,
  ) async {
    final formData = FormData.fromMap({'description': description});
    for (final file in images) {
      formData.files.add(
        MapEntry(
          'portofolio',
          await fileToMultipartFile(file),
        ),
      );
    }
    return formData;
  }
}
