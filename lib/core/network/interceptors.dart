import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../config/routes/app_router.dart';
import '../app_config/app_urls.dart';
import '../app_config/prefs_keys.dart';
import '../helpers/auth_session_helper.dart';
import '../helpers/secure_local_storage.dart';

class CustomInterceptor extends Interceptor {
  final Dio dio;
  bool isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequests = [];
  CustomInterceptor({
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      HttpHeaders.acceptHeader: ContentType.json.mimeType,
      'Accept-Language':
          AppRouter.appNavigatorKey.currentContext?.locale.languageCode ??
              'ar',
      'time-zone': DateTime.now().timeZoneName,
    });

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _failedRequests.add({'err': err, 'handler': handler});

      if (!isRefreshing) {
        isRefreshing = true;
        final refreshSuccess = await _refreshToken(err, handler);
        if (!refreshSuccess) {
          handler.reject(err);
        }
      }
    } else {
      handler.next(err);
    }
  }

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

  Future<void> _saveTokens(String access, String refresh) async {
    await SecureLocalStorage.write(PrefsKeys.token, access);
    await SecureLocalStorage.write(PrefsKeys.refreshToken, refresh);
  }

  Future<void> _logout() async {
    dio.options.headers.clear();
    await AuthSessionHelper.logout();
  }
}
