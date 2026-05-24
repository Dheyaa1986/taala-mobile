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
        // surface: AppColors.lightBGColor,
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
        // TextStyle(
        //     color: AppColors.lightMainText,
        //     fontSize: 24.sp,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'Tajawal'),
        // field label style
        labelMedium: FontStyles.label16.copyWith(
          color: AppColors.lightMainText,
        ),
        // TextStyle(
        //     color: AppColors.lightSecMainText,
        //     fontSize: 16.sp,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'Tajawal'),
        // text button style
        labelSmall: FontStyles.label16.copyWith(
          color: AppColors.lightGreyText,
        ),
        // TextStyle(
        //     color: AppColors.lightGreyText,
        //     fontSize: 16.sp,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'Tajawal'),
        //primary text style
        headlineLarge: FontStyles.headline14.copyWith(
          color: AppColors.primaryColor,
        ),
        //  TextStyle(
        //     color: AppColors.primaryColor,
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'Tajawal'),
        //button white  text style
        headlineMedium: FontStyles.headline16.copyWith(
          color: AppColors.whiteColor,
        ),
        // TextStyle(
        //     color: AppColors.whiteColor,
        //     fontSize: 16.sp,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'Tajawal'),
        //button black  text style
        headlineSmall: FontStyles.headline16.copyWith(
          color: AppColors.lightMainText,
        ),
        //  TextStyle(
        //     color: AppColors.lightMainText,
        //     fontSize: 16.sp,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'Tajawal'),

        // body text
        bodyLarge: FontStyles.body14W700.copyWith(
          color: AppColors.bodyText,
        ),
        //  TextStyle(
        //     color: AppColors.bodyText,
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w700,
        //     fontFamily: 'Tajawal'),
        bodyMedium: FontStyles.body14W500.copyWith(
          color: AppColors.lightMainText,
        ),
        // TextStyle(
        //     color: AppColors.lightSecMainText,
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w500,
        //     fontFamily: 'Tajawal'),
        bodySmall: FontStyles.body12W400.copyWith(
          color: AppColors.lightSubTitleText,
        ),
        // TextStyle(
        //     color: AppColors.greyText,
        //     fontSize: 12.sp,
        //     fontWeight: FontWeight.w400,
        //     fontFamily: 'Tajawal'),

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
