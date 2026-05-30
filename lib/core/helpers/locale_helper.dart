import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../app_config/prefs_keys.dart';
import '../di/service_locator.dart';
import 'shared_pref_local_storage.dart';

class LocaleHelper {
  const LocaleHelper._();

  static Locale? savedLocale() {
    final code = getIt<SharedPref>().get(key: PrefsKeys.selectedLanguage);
    if (code is String && code.isNotEmpty) {
      return Locale(code);
    }
    return null;
  }

  static Future<void> apply(BuildContext context, String languageCode) async {
    await context.setLocale(Locale(languageCode));
    await getIt<SharedPref>().set(
      key: PrefsKeys.selectedLanguage,
      value: languageCode,
    );
  }
}
