import 'package:flutter/material.dart';

extension LangExtension on BuildContext {
  /// Returns the current language code ('ar' for Arabic, 'en' for English, etc.)
  String get lang {
    return Localizations.localeOf(this).languageCode;
  }

  /// Checks if the current language is Arabic
  bool get isArabic {
    return lang == 'ar';
  }

  /// Checks if the current language is English
  bool get isEnglish {
    return lang == 'en';
  }
}