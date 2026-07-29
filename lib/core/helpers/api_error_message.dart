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

  static bool _hasArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  static String _mapEnglish(String text) {
    switch (text) {
      case 'BadRequestException':
      case 'Bad Request':
      case 'Internal Server Error':
      case 'Internal server error':
      case 'Database query failed':
      case 'Unauthorized':
      case 'Unauthorized.':
      case 'request_cancelled':
      case 'Something went wrong':
      case 'Something went wrong.':
        return AppStrings.genericError.tr();
      case 'Network Error':
        return AppStrings.networkError.tr();
      default:
        if (text.startsWith('Duplicate entry')) {
          return AppStrings.duplicateEntryError.tr();
        }
        return text;
    }
  }
}
