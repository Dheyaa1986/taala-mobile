import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../app_config/app_strings.dart';
import '../helpers/api_error_message.dart';
import 'exceptions.dart';

class ErrorsExceptionsHandler {
  static String _resolveMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      return AppStrings.genericError.tr();
    }
    return ApiErrorMessage.from(message);
  }

  static String? _extractApiMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final topMessage = data['message'];
    if (topMessage is List && topMessage.isNotEmpty) {
      return topMessage.map((e) => e.toString()).join(' • ');
    }
    if (topMessage is String &&
        topMessage.isNotEmpty &&
        topMessage != 'Validation failed' &&
        topMessage != 'validation failed') {
      return topMessage;
    }

    final nested = data['response'];
    if (nested is Map<String, dynamic>) {
      final nestedMessage = nested['message'];
      if (nestedMessage is List && nestedMessage.isNotEmpty) {
        return nestedMessage.map((e) => e.toString()).join(' • ');
      }
      if (nestedMessage is String && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }
    }

    final details = data['details'];
    if (details is List && details.isNotEmpty) {
      return details
          .map((item) {
            if (item is Map) {
              final constraints = item['constraints'];
              if (constraints is Map) {
                return constraints.values.map((e) => e.toString()).join(' • ');
              }
              return item.values.map((e) => e.toString()).join(' • ');
            }
            return item.toString();
          })
          .where((value) => value.trim().isNotEmpty)
          .join(' • ');
    }

    if (topMessage is String && topMessage.isNotEmpty) {
      return topMessage;
    }

    return null;
  }

  static dynamic handleError(DioException error) {
    final errorMessage = _extractApiMessage(error.response?.data);

    if (error.error is SocketException) {
      throw CustomException(AppStrings.networkError.tr());
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw CustomException(AppStrings.networkError.tr());
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            throw BadRequestException(_resolveMessage(errorMessage));
          case 403:
            throw CustomException(
              _resolveMessage(errorMessage),
              code: 403,
            );
          case 401:
            throw UnauthorizedException(_resolveMessage(errorMessage));
          case 404:
            throw NotFoundException(_resolveMessage(errorMessage));
          case 409:
            throw ConflictException(_resolveMessage(errorMessage));
          case 429:
            throw CustomException(
              _resolveMessage(errorMessage),
              code: 429,
            );
          case 422:
            throw BadRequestException(_resolveMessage(errorMessage));
          case 500:
          case 501:
          case 502:
          case 503:
            throw InternalServerErrorException(_resolveMessage(errorMessage));
          default:
            throw CustomException(_resolveMessage(errorMessage));
        }
      case DioExceptionType.cancel:
        throw CustomException(AppStrings.requestCancelled.tr());
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          throw CustomException(AppStrings.networkError.tr());
        }
        throw CustomException(_resolveMessage(errorMessage));
      default:
        throw CustomException(_resolveMessage(errorMessage));
    }
  }
}
