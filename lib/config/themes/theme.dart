import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_config/app_colors.dart';
import '../../core/app_config/font_styles.dart';
import '../../core/models/theme_model.dart';

class TariqyAppTheme {
  static ThemeModel? activeTheme;

  static ThemeData getLightTheme({ThemeModel? customTheme}) {
    final theme = customTheme ?? activeTheme;

    if (theme != null && theme.colors != null) {
      return _buildDynamicTheme(theme);
    }

    return _getDefaultLightTheme();
  }

  static ThemeData _getDefaultLightTheme() {
    return ThemeData(fontFamily: 'Cairo').copyWith(
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
      ),
      hintColor: AppColors.borderColor,
      primaryColor: AppColors.primaryColor,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
      ),
      scaffoldBackgroundColor: AppColors.lightBGColor,
      dialogBackgroundColor: AppColors.lightBGColor,
      textTheme: TextTheme(
        labelLarge: FontStyles.label24.copyWith(
          color: AppColors.lightMainText,
        ),
        labelMedium: FontStyles.label16.copyWith(
          color: AppColors.lightMainText,
        ),
        labelSmall: FontStyles.label16.copyWith(
          color: AppColors.lightGreyText,
        ),
        headlineLarge: FontStyles.headline14.copyWith(
          color: AppColors.primaryColor,
        ),
        headlineMedium: FontStyles.headline16.copyWith(
          color: AppColors.whiteColor,
        ),
        headlineSmall: FontStyles.headline16.copyWith(
          color: AppColors.lightMainText,
        ),
        bodyLarge: FontStyles.body14W700.copyWith(
          color: AppColors.bodyText,
        ),
        bodyMedium: FontStyles.body14W500.copyWith(
          color: AppColors.lightMainText,
        ),
        bodySmall: FontStyles.body12W400.copyWith(
          color: AppColors.lightSubTitleText,
        ),
        titleLarge: FontStyles.body14W500.copyWith(
          color: AppColors.lightTText,
        ),
        displayLarge: FontStyles.body14W700.copyWith(
          color: AppColors.textFieldFillColor,
        ),
        titleSmall: FontStyles.body14W700.copyWith(
          color: AppColors.dateColor,
        ),
        titleMedium: FontStyles.body14W500.copyWith(
          color: AppColors.greyText,
        ),
        displayMedium: FontStyles.body14W500.copyWith(
          color: AppColors.blackText,
        ),
        displaySmall: FontStyles.body14W500.copyWith(
          color: AppColors.greyTitle,
        ),
      ),
    );
  }

  static ThemeData _buildDynamicTheme(ThemeModel theme) {
    final colors = theme.colors!;
    final primaryColor = _parseColor(colors.primary) ?? AppColors.primaryColor;
    final secondaryColor = _parseColor(colors.secondary) ?? AppColors.secondaryColor;
    final accentColor = _parseColor(colors.accent) ?? AppColors.primaryColor;
    final backgroundColor = _parseColor(colors.background) ?? AppColors.lightBGColor;
    final textColor = _parseColor(colors.text) ?? AppColors.lightMainText;

    return ThemeData(fontFamily: 'Cairo').copyWith(
      appBarTheme: const AppBarTheme(
        surfaceTintColor: Colors.transparent,
      ),
      hintColor: AppColors.borderColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
      ),
      scaffoldBackgroundColor: backgroundColor,
      dialogBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        labelLarge: FontStyles.label24.copyWith(
          color: textColor,
        ),
        labelMedium: FontStyles.label16.copyWith(
          color: textColor,
        ),
        labelSmall: FontStyles.label16.copyWith(
          color: AppColors.lightGreyText,
        ),
        headlineLarge: FontStyles.headline14.copyWith(
          color: primaryColor,
        ),
        headlineMedium: FontStyles.headline16.copyWith(
          color: AppColors.whiteColor,
        ),
        headlineSmall: FontStyles.headline16.copyWith(
          color: textColor,
        ),
        bodyLarge: FontStyles.body14W700.copyWith(
          color: textColor,
        ),
        bodyMedium: FontStyles.body14W500.copyWith(
          color: textColor,
        ),
        bodySmall: FontStyles.body12W400.copyWith(
          color: AppColors.lightSubTitleText,
        ),
        titleLarge: FontStyles.body14W500.copyWith(
          color: textColor,
        ),
        displayLarge: FontStyles.body14W700.copyWith(
          color: AppColors.textFieldFillColor,
        ),
        titleSmall: FontStyles.body14W700.copyWith(
          color: accentColor,
        ),
        titleMedium: FontStyles.body14W500.copyWith(
          color: AppColors.greyText,
        ),
        displayMedium: FontStyles.body14W500.copyWith(
          color: textColor,
        ),
        displaySmall: FontStyles.body14W500.copyWith(
          color: AppColors.greyTitle,
        ),
      ),
    );
  }

  static Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      return Color(int.parse(colorString.replace('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  static final ThemeData darkTheme =
      ThemeData(fontFamily: 'Tajawal').copyWith();

  get lightMode {
    return getLightTheme();
  }

  get darkMode {
    return darkTheme;
  }
}
