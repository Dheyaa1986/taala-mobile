import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_config/app_colors.dart';
import '../../core/app_config/font_styles.dart';

class TariqyAppTheme {
  static final ThemeData lightTheme = ThemeData(fontFamily: 'Cairo').copyWith(
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
      ));

  static final ThemeData darkTheme =
      ThemeData(fontFamily: 'Tajawal').copyWith();
  get lightMode {
    return lightTheme;
  }

  get darkMode {
    return darkTheme;
  }
}
