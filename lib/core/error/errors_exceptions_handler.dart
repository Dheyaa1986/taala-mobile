import 'dart:io';


import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import 'exceptions.dart';

class ErrorsExceptionsHandler {
  static dynamic handleError(DioException error) {
    print("STATUS CODE: ${error.response?.statusCode}");
    print("REQUEST URL: ${error.requestOptions.uri}");
    print("FULL RESPONSE: ${error.response?.data}");

    final data = error.response?.data;

    String? errorMessage;

    if (data is Map<String, dynamic>) {
      errorMessage = data['message']?.toString();
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        throw CustomException(errorMessage ?? 'BadRequestException');
      case DioExceptionType.sendTimeout:
        throw CustomException(errorMessage ?? 'BadRequestException');
      case DioExceptionType.receiveTimeout:
        throw CustomException(errorMessage ?? 'BadRequestException');
      case DioExceptionType.badResponse:
        switch (error.response!.statusCode) {
          case 400:
            throw BadRequestException(errorMessage ?? 'BadRequestException');
          case 403:
            throw CustomException(errorMessage ?? 'BadRequestException',code: 403);
          case 401:
            throw UnauthorizedException(errorMessage ?? 'BadRequestException');
          case 404:
             throw  NotFoundException(errorMessage ?? 'BadRequestException');
          case 409:
            throw ConflictException(
                errorMessage ?? 'BadRequestException');
          case 500:
            throw InternalServerErrorException(
                errorMessage ?? 'BadRequestException');
          case 501:
            throw InternalServerErrorException(
                errorMessage ?? 'BadRequestException');
          case 502:
            throw InternalServerErrorException(
                errorMessage ?? 'BadRequestException');
          case 503:
            throw InternalServerErrorException(
                errorMessage ?? 'BadRequestException');
          default:
            throw CustomException(errorMessage ?? 'BadRequestException');
        }
      case DioExceptionType.cancel:
        throw const CustomException('request_cancelled');
    case DioExceptionType.unknown:
        print("UNKNOWN ERROR: ${error.error}");
        print("UNKNOWN MESSAGE: ${error.message}");

        throw CustomException(errorMessage ?? 'BadRequestException');
      default:
        throw CustomException(
            errorMessage ?? 'BadRequestException');
    }
  }
}
