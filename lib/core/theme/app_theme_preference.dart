import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  light,
  dark;

  ThemeMode get themeMode => switch (this) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };

  static AppThemePreference fromStorage(String? value) {
    return AppThemePreference.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}
