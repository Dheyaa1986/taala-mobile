import 'package:flutter/material.dart';

import '../../core/models/theme_model.dart';
import '../../design_system/theme/taala_theme.dart';

class TariqyAppTheme {
  static ThemeModel? activeTheme;

  static ThemeData getLightTheme({ThemeModel? customTheme}) {
    final theme = customTheme ?? activeTheme;
    return TaalaTheme.light(occasionTheme: theme);
  }

  static ThemeData getDarkTheme({ThemeModel? customTheme}) {
    final theme = customTheme ?? activeTheme;
    return TaalaTheme.dark(occasionTheme: theme);
  }

  static Color splashBackgroundColor() {
    return TaalaTheme.splashBackground(occasionTheme: activeTheme);
  }

  static Color resolvePrimary([BuildContext? context]) {
    if (context != null) {
      return Theme.of(context).colorScheme.primary;
    }
    final primary = activeTheme?.colors?.primary;
    return _parseColor(primary) ?? const Color(0xFFFFC20F);
  }

  static Color resolveSecondary([BuildContext? context]) {
    if (context != null) {
      return Theme.of(context).colorScheme.secondary;
    }
    final secondary = activeTheme?.colors?.secondary;
    return _parseColor(secondary) ?? const Color(0xFFFFD633);
  }

  static LinearGradient primaryGradient([BuildContext? context]) {
    final primary = resolvePrimary(context);
    final secondary = resolveSecondary(context);
    return LinearGradient(
      colors: [primary, secondary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  static Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      final normalized = colorString.startsWith('#')
          ? colorString.replaceFirst('#', '0xFF')
          : colorString;
      return Color(int.parse(normalized));
    } catch (_) {
      return null;
    }
  }

  static ThemeData get lightTheme => getLightTheme();

  static ThemeData get darkTheme => getDarkTheme();

  ThemeData get lightMode => getLightTheme();

  ThemeData get darkMode => getDarkTheme();
}
