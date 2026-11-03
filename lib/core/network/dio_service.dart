import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/core/network/extensions.dart';
import '../app_config/app_urls.dart';
import '../app_config/constants.dart';
import '../app_config/prefs_keys.dart';
import 'package:taal/core/alerts/app_alert_monitor.dart';
import 'package:taal/core/alerts/push_notification_service.dart';
import 'package:taal/core/di/service_locator.dart';
import '../error/errors_exceptions_handler.dart';
import '../helpers/auth_session_helper.dart';
import '../helpers/secure_local_storage.dart';
import 'interceptors.dart';
import 'network_request.dart';
import 'network_service.dart';

class DioService implements NetworkService {
  late Dio _dio;

  DioService() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio()
      ..options.baseUrl = AppUrls.baseApi
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.validateStatus = (status) {
        if (status == 401) {
          return false;
        } else if (status == 500) {
          return false;
        }
        return status! < 400;
      }
      ..options.responseType = ResponseType.json;

    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: true,
      ));
    }
    _dio.interceptors.add(CustomInterceptor(dio: _dio));
  }

  Future<void> logout() async {
    getIt<AppAlertMonitor>().stop();
    try {
      await PushNotificationService.instance.clearTokenFromBackend();
    } catch (_) {}
    _dio.options.headers.clear();
    await AuthSessionHelper.logout();
  }

  Future<Map<String, dynamic>> _getDefaultHeaders(bool isWithoutToken) async {
    final locale =
        AppRouter.appNavigatorKey.currentContext?.locale.languageCode ?? 'ar';
    final Map<String, dynamic> headers = {};
    headers.addAll({
      'Accept': 'application/json',
      'accept-language': locale,
      'time-zone': 'Asia/Baghdad',
    });
    if (isWithoutToken != true) {
      final token = await SecureLocalStorage.read(PrefsKeys.token);
      if (token?.isNotEmpty == true) {
        headers[AppConstants.authorization] = '${AppConstants.bearer} $token';
      }
    }
    return headers;
  }

  Future<dynamic> _resolveRequestData(NetworkRequest networkRequest) async {
    if (!networkRequest.hasBodyAndProgress()) {
      return networkRequest.body;
    }
    if (networkRequest.formDataBody != null) {
      return networkRequest.formDataBody;
    }
    if (networkRequest.isFormData && networkRequest.body != null) {
      return FormData.fromMap(networkRequest.body!);
    }
    return networkRequest.body;
  }

  @override
  Future<Model> callApi<Model>(NetworkRequest networkRequest,
      {Model Function(Map<String, dynamic> json)? mapper}) async {
    try {
      await networkRequest.prepareRequestData();
      final response = await _dio.request(networkRequest.path,
          data: await _resolveRequestData(networkRequest),
          queryParameters: networkRequest.queryParameters,
          onSendProgress: networkRequest.hasBodyAndProgress()
              ? networkRequest.onSendProgress
              : null,
          onReceiveProgress: networkRequest.hasBodyAndProgress()
              ? networkRequest.onReceiveProgress
              : null,
          options: Options(
              method: networkRequest.asString(),
              connectTimeout: networkRequest.connectTimeout,
              receiveTimeout: networkRequest.receiveTimeout,
              headers: await _getDefaultHeaders(
                  networkRequest.requestWithOutToken)));
      if (mapper != null &&
          (response.statusCode == 200 ||
              response.statusCode == 201 ||
              response.statusCode == 204)) {
        return mapper(_asJsonMap(response.data, response.statusCode));
      } else {
        return response.data;
      }
    } on DioException catch (e) {
      return ErrorsExceptionsHandler.handleError(e);
    }
  }

  Map<String, dynamic> _asJsonMap(dynamic data, int? statusCode) {
    if (data == null || data == '') {
      return {'code': statusCode};
    }
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return {'code': statusCode};
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
      } catch (_) {}
    }
    return {'code': statusCode, 'response': data};
  }
}
