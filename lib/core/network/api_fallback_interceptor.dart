import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:taal/core/app_config/api_base_config.dart';

/// Retries once on Railway when the primary API host is unreachable.
class ApiFallbackInterceptor extends Interceptor {
  ApiFallbackInterceptor(this._dio);

  final Dio _dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_isRecoverable(err) || ApiBaseConfig.activateFallback() == null) {
      handler.next(err);
      return;
    }

    final fallbackBase = ApiBaseConfig.activeBase;
    _dio.options.baseUrl = fallbackBase;

    final request = err.requestOptions;
    request.baseUrl = fallbackBase;
    request.path = ApiBaseConfig.absolutePath(request.path);

    if (kDebugMode) {
      debugPrint('API fallback activated: $fallbackBase');
    }

    try {
      final response = await _dio.fetch(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (error) {
      handler.next(err);
    }
  }

  bool _isRecoverable(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        final inner = error.error;
        return inner is SocketException ||
            inner is HandshakeException ||
            inner is TlsException ||
            (error.message?.isNotEmpty ?? false);
      default:
        return false;
    }
  }
}
