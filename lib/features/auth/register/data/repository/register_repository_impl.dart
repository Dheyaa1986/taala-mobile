import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/models/base_response_model.dart';
import '../../../../../core/network/network_request.dart';
import '../model/register_options.dart';
import 'register_repository.dart';

class RegisterRepositoryImpl extends RegisterRepository {
  @override
  Future<Either<CustomException, BaseResponseModel>> registerClient(
      {required RegisterOptions model}) async {
    final result = await exceptionHandler(
      () async {
        final formData = await model.toFormData();
        log("DATA SENT: ${formData.fields}");
        BaseResponseModel response = await dioService.callApi(
          NetworkRequest(AppUrls.registerClient,
              method: RequestMethod.post,
              isFormData: true,
              formDataBody: formData,
              requestWithOutToken: true),
          mapper: (json) => BaseResponseModel.fromJson(json),
        );
        await SecureLocalStorage.write(
          PrefsKeys.password,
          model.password,
        );
        await SecureLocalStorage.write(
          PrefsKeys.mailOrPhone,
          model.email,
        );
        return response;
      },
    );
    return result;
  }
}
