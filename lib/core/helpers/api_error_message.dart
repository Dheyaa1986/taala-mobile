import 'package:easy_localization/easy_localization.dart';

import '../app_config/app_strings.dart';

class ApiErrorMessage {
  const ApiErrorMessage._();

  static String from(String? message) {
    if (message == null || message.trim().isEmpty) {
      return AppStrings.genericError.tr();
    }

    final text = message.trim();
    if (_hasArabic(text)) {
      return text;
    }

    return _mapEnglish(text);
  }

  static String validationOrGeneric(String? message) {
    final resolved = from(message);
    if (resolved != AppStrings.genericError.tr()) {
      return resolved;
    }
    return AppStrings.validationFailed.tr();
  }

  static bool _hasArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  static String _mapEnglish(String text) {
    switch (text) {
      case 'BadRequestException':
      case 'Bad Request':
      case 'Internal Server Error':
      case 'Internal server error':
      case 'Database query failed':
      case 'Forbidden':
      case 'Forbidden resource':
        return AppStrings.validationFailed.tr();
      case 'Unauthorized':
      case 'Unauthorized.':
        return AppStrings.validationFailed.tr();
      case 'Validation failed':
      case 'validation failed':
        return AppStrings.validationFailed.tr();
      case 'request_cancelled':
      case 'Something went wrong':
      case 'Something went wrong.':
      case 'Error During Communication':
      case 'Conflict Occurred':
      case 'Requested Info Not Found':
      case 'No Internet Connection':
        return AppStrings.genericError.tr();
      case 'Network Error':
        return AppStrings.networkError.tr();
      case 'ThrottlerException: Too Many Requests':
      case 'Too Many Requests':
      case 'Too many requests':
        return AppStrings.tooManyRequests.tr();
      default:
        if (text.startsWith('ThrottlerException') ||
            text.contains('Too Many Requests')) {
          return AppStrings.tooManyRequests.tr();
        }
        if (text.startsWith('Duplicate entry') ||
            text.contains('unique constraint')) {
          return AppStrings.duplicateEntryError.tr();
        }
        if (text.contains('invalid_otp') ||
            text.contains('Invalid or expired verification code') ||
            text.contains('OTP is required')) {
          return AppStrings.invalidOtp.tr();
        }
        if (text.contains('must be a UUID') ||
            text.contains('must be longer than or equal to 6') ||
            text.contains('should not exist') ||
            text.contains('must be a') ||
            text.contains('must not be')) {
          return AppStrings.validationFailed.tr();
        }
        if (text.contains('phone') || text.contains('Phone')) {
          return AppStrings.invalidPhone.tr();
        }
        return AppStrings.genericError.tr();
    }
  }
}
