import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  dark;

  ThemeMode get themeMode => switch (this) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.dark => ThemeMode.dark,
      };

  static AppThemePreference fromStorage(String? value) {
    if (value == 'light') {
      return AppThemePreference.system;
    }
    return AppThemePreference.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}
