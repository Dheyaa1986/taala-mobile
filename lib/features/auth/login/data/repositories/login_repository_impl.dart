import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    print("🔵 LOGIN REPOSITORY - Starting login request");
    print("🔵 URL: $loginUrl");
    print("🔵 BODY: ${model.toJson()}");

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

          print("🟢 LOGIN SUCCESS - Token: ${user.token}");

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
        } on DioException catch (e) {
          print("🔴 DIO ERROR");
          print("   Status Code: ${e.response?.statusCode}");
          print("   Response Data: ${e.response?.data}");
          print("   Message: ${e.message}");
          rethrow;
        } catch (e) {
          print("🔴 GENERAL ERROR: $e");
          rethrow;
        }
      },
    );

    return result;
  }
}
