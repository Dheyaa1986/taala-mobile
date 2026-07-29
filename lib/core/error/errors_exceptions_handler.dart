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

  static dynamic handleError(DioException error) {
    final data = error.response?.data;

    String? errorMessage;

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is List) {
        errorMessage = message.map((e) => e.toString()).join(' • ');
      } else {
        errorMessage = message?.toString();
      }
    }

    if (error.error is SocketException) {
      throw CustomException(AppStrings.networkError.tr());
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw CustomException(AppStrings.networkError.tr());
      case DioExceptionType.badResponse:
        switch (error.response!.statusCode) {
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
