import 'package:flutter/material.dart';

extension LangExtension on BuildContext {
  String get lang {
    return Localizations.localeOf(this).languageCode;
  }

  bool get isArabic {
    return lang == 'ar';
  }

  bool get isEnglish {
    return lang == 'en';
  }
}
