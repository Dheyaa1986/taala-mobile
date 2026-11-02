import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../../core/app_config/app_urls.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/helpers/phone_helper.dart';
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

          await _persistSession(
            token: user.token,
            refreshToken: user.refreshToken,
            identifier: model.email,
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

  @override
  Future<Either<CustomException, LoginResponseModel>> loginClientByPhone(
    String phone,
  ) async {
    return exceptionHandler(() async {
      final normalizedPhone = PhoneFormatterHelper.normalizeForApi(phone);
      final user = await dioService.callApi(
        NetworkRequest(
          AppUrls.clientLoginPhone,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {'phone': normalizedPhone},
        ),
        mapper: (json) => LoginResponseModel.fromJson(json: json),
      );

      await _persistSession(
        token: user.token,
        refreshToken: user.refreshToken,
        identifier: normalizedPhone,
      );
      return user;
    });
  }

  @override
  Future<Either<CustomException, String?>> sendClientOtp(String phone) async {
    return exceptionHandler(() async {
      final json = await dioService.callApi(
        NetworkRequest(
          AppUrls.clientSendOtp,
          method: RequestMethod.post,
          requestWithOutToken: true,
          connectTimeout: NetworkRequest.otpRequestTimeout,
          receiveTimeout: NetworkRequest.otpRequestTimeout,
          body: {'phone': phone.trim()},
        ),
      );
      final response = json['response'] as Map<String, dynamic>? ?? json;
      return response['debugOtp']?.toString();
    });
  }

  @override
  Future<Either<CustomException, LoginResponseModel>> verifyClientOtp({
    required String phone,
    String? otp,
  }) async {
    return exceptionHandler(() async {
      final user = await dioService.callApi(
        NetworkRequest(
          AppUrls.clientVerifyOtp,
          method: RequestMethod.post,
          requestWithOutToken: true,
          body: {
            'phone': phone.trim(),
            if (otp != null && otp.trim().isNotEmpty) 'otp': otp.trim(),
          },
        ),
        mapper: (json) => LoginResponseModel.fromJson(json: json),
      );

      await _persistSession(
        token: user.token,
        refreshToken: user.refreshToken,
        identifier: phone.trim(),
      );
      return user;
    });
  }

  Future<void> _persistSession({
    required String token,
    required String refreshToken,
    required String identifier,
  }) async {
    await SecureLocalStorage.write(PrefsKeys.token, token);
    await SecureLocalStorage.write(PrefsKeys.refreshToken, refreshToken);
    await SecureLocalStorage.write(PrefsKeys.mailOrPhone, identifier);
    await SecureLocalStorage.delete(PrefsKeys.password);
    try {
      await SecureLocalStorage.write(
        PrefsKeys.user,
        jsonEncode(JwtDecoder.decode(token)),
      );
    } catch (_) {}
  }
}
