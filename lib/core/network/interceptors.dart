import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';


import '../../config/routes/app_router.dart';
import '../../config/routes/routes.dart';
import '../app_config/app_urls.dart';
import '../app_config/constants.dart';
import '../app_config/prefs_keys.dart';
import '../helpers/secure_local_storage.dart';
import '../helpers/user_helper.dart';

class CustomInterceptor extends Interceptor {
  final Dio dio;
  bool isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequests = [];
  CustomInterceptor({
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // add lang and time zone to each request headers
    // we can add the token here if needed but cuz we might send requests without the token .. so let the method call decides this
    options.headers.addAll({
      HttpHeaders.acceptHeader: ContentType.json,
      'Accept-Language':
          AppRouter.appNavigatorKey.currentContext!.locale.languageCode,
      'time-zone': DateTime.now().timeZoneName,
    });

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Pass through successful responses
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Token is expired, try refreshing it
    if (err.response?.statusCode == 401) {
      _failedRequests.add({'err': err, 'handler': handler});

      if (!isRefreshing) {
        isRefreshing = true;
        // refresh method
        final refreshSuccess = await _refreshToken(err, handler);
        if (!refreshSuccess) {
          handler.reject(err);
        }
      }
    } else {
      handler.next(err);
    }
  }

/*  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token is expired, try refreshing it
      String? accessToken = await SecureLocalStorage.read(PrefsKeys.token);
      String? refreshToken =
          await SecureLocalStorage.read(PrefsKeys.refreshToken);
      try {
        final newTokens = await refreshTokens(
            access: accessToken ?? '', refresh: refreshToken ?? '');
        accessToken = newTokens['accessToken'];
        refreshToken = newTokens['refreshToken'];

        // Retry the original request with the new token
        final retryResponse = await dio.request(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: {
              ...err.requestOptions.headers,
              AppConstants.authorization : '${AppConstants.bearer} $accessToken',
            },
          ),
        );

        handler.resolve(retryResponse);
      } catch (e) {
        // If refreshing tokens fails, pass the error
        _logout();
        super.onError(err, handler);
      }
    } else {
      // For other errors, pass them through
      super.onError(err, handler);
    }
  }*/
  Future<void> _retryFailedRequests(String newToken) async {
    for (var failed in _failedRequests) {
      final RequestOptions requestOptions = failed['err'].requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newToken';

      try {
        final response = await dio.fetch(requestOptions);
        failed['handler'].resolve(response);
      } catch (error) {
        failed['handler'].reject(error);
      }
    }

    _failedRequests.clear();
    isRefreshing = false;
  }

  Future<bool> _refreshToken(
      DioException err, ErrorInterceptorHandler handler) async {
    try {
      final refreshToken =
          await SecureLocalStorage.read(PrefsKeys.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) {
        _logout();
        return false;
      }
      final accessToken = await SecureLocalStorage.read(PrefsKeys.token);
      dio.options.headers = {};
      final response = await dio.post(AppUrls.refreshToken, data: {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final String access = response.data['accessToken'];
        final String refresh = response.data['refreshToken'];

        await _saveTokens(access, refresh);

        await _retryFailedRequests(access);
        return true;
      } else {
        _logout();
        return false;
      }
    } catch (e) {
      _logout();
      return false;
    }
  }

  _saveTokens(String access, String refresh) async {
    await SecureLocalStorage.write(PrefsKeys.token, access);
    await SecureLocalStorage.write(PrefsKeys.refreshToken, refresh);
  }
/*  Future<Map<String, String>> refreshTokens(
      {required String access, required String refresh}) async {
    // Call the refresh endpoint

    dio.options.headers = {};
    final response = await dio.post(AppUrls.refreshToken, data: {
      'accessToken': access,
      'refreshToken': refresh,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    } else {
      _logout();
      throw DioError(
        requestOptions: RequestOptions(path: AppUrls.refreshToken),
        error: 'Failed to refresh tokens',
      );
    }
  }*/

  Future<void> _logout() async {
    await SecureLocalStorage.delete(PrefsKeys.token);
    await SecureLocalStorage.delete(PrefsKeys.refreshToken);
     // UserHelper.clear();
    dio.options.headers.clear();
    GoRouter.of(AppRouter.appNavigatorKey.currentContext!)
        .pushReplacementNamed(Routes.login);
  }
}
