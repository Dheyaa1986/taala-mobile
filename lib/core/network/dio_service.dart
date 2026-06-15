import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/core/network/extensions.dart';
import '../app_config/app_urls.dart';
import '../app_config/constants.dart';
import '../app_config/prefs_keys.dart';
import 'package:taal/core/alerts/app_alert_monitor.dart';
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

    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

        return client;
      };
    }
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));
    }
    _dio.interceptors.add(CustomInterceptor(dio: _dio));
  }

  Future<void> logout() async {
    getIt<AppAlertMonitor>().stop();
    _dio.options.headers.clear();
    await AuthSessionHelper.logout();
  }

  Future<Map<String, dynamic>> _getDefaultHeaders(bool isWithoutToken) async {
    final locale =
        AppRouter.appNavigatorKey.currentContext?.locale.languageCode ?? 'ar';
    final Map<String, dynamic> headers = {};
    headers.addAll({
      HttpHeaders.acceptHeader: ContentType.json.mimeType,
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
              headers: await _getDefaultHeaders(
                  networkRequest.requestWithOutToken)));
      if (mapper != null &&
          (response.statusCode == 200 ||
              response.statusCode == 201 ||
              response.statusCode == 204)) {
        return mapper(response.data);
      } else {
        debugPrint('else: ${response.data}');
        return response.data;
      }
    } on DioException catch (e) {
      return ErrorsExceptionsHandler.handleError(e);
    }
  }
}
