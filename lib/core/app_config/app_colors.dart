import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const Color secondaryColor = Color(0xffFFA62A);
  static const Color primaryColor = Color(0xffFFC20F);
  static const Color iconBgColor = Color(0xFFF6F6F6);
  static const Color lightBGColor = Color(0xffFFFFFF);
  static const Color lightMainText = Color(0xff272525);
  static const Color blackText = Color(0xff000000);
  static const Color commentColor = Color(0xff444444);
  static const Color greyText = Color(0xff8E8E93);
  static const Color dropDownIconColor = Color(0xff817E7E);
  static const Color rateIconColor = Color(0xFFFFA62A);
  static const Color rateCountColor = Color(0xFFACACAC);
  static const Color lightGrey = Color(0xff4D4D4D);
  static const Color greyBG = Color(0xffEEEEEE);
  static const Color textFieldFillColor = Color(0xffF6F6F6);
  static const Color cardBorderColor = Color(0xffF2F2F7);
  static const Color lightGreyText = Color(0xFF737373);
  static const Color lightSubTitleText = Color(0xFF989898);
  static const Color lightTText = Color(0xff1C1F1E);
  static const Color greyTitle = Color(0xff574E4E);
  static const Color greyBorder = Color(0xff939393);
  static const Color lightSecBGColor = Color(0xff7B7B7B);
  static const Color lightSecBGColor2 = Color(0xffD1D1D6);
  static const Color lightSecMainText = Color(0xff000000);
  static const Color iconButtonBG = Color(0xffF1F1F1);
  static const Color lightGreyDividerColor = Color(0xffEAE9EA);
  static const Color toggleBg = Color(0x2638ABFE);
  static const Color lightGreyTextField = Color(0xffEAE9EA);
  static const Color chatLightBgColor = Color(0xffF4F6F5);
  static const Color offerOptionsBorder = Color(0xffD7E4FF);
  static const Color whatsAppGreen = Color(0xff25D366);
  static const Color lightSecGreyText = Color(0xff919191);
  static const Color lightSecGreyText2 = Color(0xffEFEFEF);
  static const Color lightImageBgColor = Color(0xffE8EFFF);
  static const Color redColor = Color(0xffFF3B30);
  static const Color lightRedColor = Color(0xffEF3328);
  static const Color lightRedText = Color(0xffFF3B30);
  static const Color yellowColor = Color(0xffFBBC05);
  static const Color myChatBubbleColor = Color(0xff1166FB);
  static const Color dateColor = Color(0xffA7A6A5);
  static const Color subtitleGreyColor = Color(0xff555555);
  static const Color whiteColor = Color(0xffffffff);
  static const Color subColor = Color(0xfffEfEfE);
  static const Color bodyText = Color(0xffbababa);
  static const Color passwordEyeColor = Color(0xff9A9A9A);
  static const Color secondaryButton = Color(0xff17171c);
  static const Color borderColor = Color(0xffC0C0C0);
  static const Color rateColor = Color(0xffDFB300);
  static const Color borderColorMain = Color(0xffE5E5E5);
  static const Color errorColor = Colors.red;
  static const Color barColor = Color(0xff4C29FB);
  static const Color iconBorderColor = Color(0xffE4E4E4);
  static const Color iconColor = Color(0xff8100FF);
  static const Color hintColor = Color(0xffAAAAAA);
  static const Color bottomBarColor = Color(0xff1a1a1a);
  static const Color subTitleColor = Color(0xffBABABA);
  static const Color dividerColor = Color(0xffD6D6D6);
  static const Color profileDividerColor = Color(0xffC8C8C8);
  static const Color sheetDividerColor = Color(0xffDCDCDC);
  static const Color green = Color(0xff34C759);
  static const Color green2 = Color(0xff00F31C);
  static const Color lightGreenText = Color(0xff74DB0B);
  static const Color greenBorder = Color(0xff25D366);
  static const Color lightGreen = Color(0xffEAFFF4);
  static const Color sliderColor = Color(0xFF4E28FD);
  static const Color categoryColor = Color(0xFFE8EFFF);
  static const Color descriptionColor = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x26A5A5A5);
  static const RadialGradient editProfileGradient = RadialGradient(
    center: Alignment(0.0, -0.3844),
    radius: 0.8641,
    colors: [Color(0xFF8100FF), Color(0xFF323DFB)],
    stops: [0.0, 1.0],
  );
  static const LinearGradient borderGradient = LinearGradient(
    colors: [secondaryColor, primaryColor],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static LinearGradient priceGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [sliderColor, iconColor],
    stops: [0.0, 1.0],
  );
  static LinearGradient bottomNavBarGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4E28FD), Color(0xFF8100FF)],
    stops: [0.0, 1.0],
  );
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [secondaryColor, primaryColor],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static LinearGradient transparentGradient = const LinearGradient(
    colors: [Colors.transparent, Colors.transparent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static LinearGradient whiteGradient = const LinearGradient(
    colors: [Colors.white, Colors.white],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static LinearGradient buttonGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [sliderColor, secondaryColor],
    stops: [0.0, 1.0],
  );
  static LinearGradient sliderGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [sliderColor, secondaryColor],
    stops: [0.0, 1.0],
  );
  static RadialGradient iconButtonGradient = const RadialGradient(
    center: Alignment(0.0, -0.38),
    radius: 1.0,
    colors: [secondaryColor, primaryColor],
    stops: [0.0, 1.0],
  );
  static RadialGradient secondaryGradient = RadialGradient(
    colors: const [AppColors.primaryColor, AppColors.secondaryColor],
    radius: 4.r,
  );
}

