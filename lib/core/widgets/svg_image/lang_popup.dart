import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/helpers/locale_helper.dart';
import 'package:taal/core/widgets/buttons/custom_drop_down_icon_button.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

class LangPopup extends StatelessWidget {
  const LangPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 8.w),
      child: CustomMenuButton(
        menuItems: [
          PopMenuModel(title: AppStrings.arabic),
          PopMenuModel(title: AppStrings.english),
          PopMenuModel(title: AppStrings.kurdish),
        ],
        onSelected: (PopMenuModel? value) {
          if (value?.title == AppStrings.arabic) {
            LocaleHelper.apply(context, 'ar');
          } else if (value?.title == AppStrings.english) {
            LocaleHelper.apply(context, 'en');
          } else if (value?.title == AppStrings.kurdish) {
            LocaleHelper.apply(context, 'fa');
          }
        },
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgImageWidget(
              image: AppIcons.lang,
              width: 20,
              height: 20,
            ),
            2.height,
            Text(
              AppStrings.changeLanguage.tr(),
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.lightTText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
