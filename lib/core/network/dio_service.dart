import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:taal/core/network/extensions.dart';

import '../../config/routes/app_router.dart';
import '../../config/routes/routes.dart';
import '../app_config/app_urls.dart';
import '../app_config/constants.dart';
import '../app_config/prefs_keys.dart';
import '../error/errors_exceptions_handler.dart';
import '../helpers/auth_session_helper.dart';
import '../helpers/secure_local_storage.dart';
import 'interceptors.dart';
import 'network_request.dart';
import 'network_service.dart';

class DioService implements NetworkService {
  late Dio _dio;
  static Alice alice = Alice(
      configuration: AliceConfiguration(
          showShareButton: true,
          navigatorKey: AppRouter.appNavigatorKey,
          showInspectorOnShake: true,
          showNotification: true));
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
      AliceDioAdapter aliceDioAdapter = AliceDioAdapter();

      alice.addAdapter(aliceDioAdapter);

      _dio.interceptors.add(aliceDioAdapter);
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ));
      _dio.interceptors.add(CustomInterceptor(dio: _dio));
    }
  }

  Future<void> logout() async {
    _dio.options.headers.clear();
    await AuthSessionHelper.logout();
  }

  Future<Map<String, dynamic>> _getDefaultHeaders(bool isWithoutToken) async {
    final Map<String, dynamic> headers = {};
    headers.addAll({
      HttpHeaders.acceptHeader: ContentType.json.mimeType,
      'accept-language': 'ar',
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

  @override
  Future<Model> callApi<Model>(NetworkRequest networkRequest,
      {Model Function(Map<String, dynamic> json)? mapper}) async {
    try {
      await networkRequest.prepareRequestData();
      final response = await _dio.request(networkRequest.path,
          data: networkRequest.hasBodyAndProgress()
              ? networkRequest.isFormData
                  ? networkRequest.formDataBody
                  : networkRequest.body
              : networkRequest.body,
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
