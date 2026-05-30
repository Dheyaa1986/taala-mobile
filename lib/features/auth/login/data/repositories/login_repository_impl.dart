import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/network/network_request.dart';
import '../model/request/login_request_options.dart';
import '../model/response/user_model.dart';
import 'login_repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  @override
  Future<Either<CustomException, LoginResponseModel>> login({
    required LoginOptions model,
    bool isProvider = false,
  }) async {
    final loginUrl =
        isProvider ? AppUrls.providerLogin : AppUrls.clientLogin;
    final result = await exceptionHandler(
      () async {
        try {
          LoginResponseModel user = await dioService.callApi(
            NetworkRequest(loginUrl,
                method: RequestMethod.post,
                body: model.toJson(),
                requestWithOutToken: true),
            mapper: (json) => LoginResponseModel.fromJson(
              json: json,
            ),
          );

          await SecureLocalStorage.write(PrefsKeys.token, user.token);
          await SecureLocalStorage.write(
            PrefsKeys.refreshToken,
            user.refreshToken,
          );
          await SecureLocalStorage.write(
            PrefsKeys.password,
            model.password,
          );
          await SecureLocalStorage.write(
            PrefsKeys.mailOrPhone,
            model.email,
          );

          await SecureLocalStorage.write(
            PrefsKeys.user,
            jsonEncode(
              JwtDecoder.decode(user.token),
            ),
          );
          return user;
        } on DioException {
          rethrow;
        } catch (e) {
          rethrow;
        }
      },
    );

    return result;
  }
}
