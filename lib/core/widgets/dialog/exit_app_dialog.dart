import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';
import '../buttons/custom_button.dart';

Future<bool> showExitAppDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      title: Text(AppStrings.exitTheApp.tr(),
          style: Theme.of(context).textTheme.headlineSmall),
      content: Text(AppStrings.exitConfirmMessage.tr(),
          style: Theme.of(context).textTheme.labelSmall),
      actions: <Widget>[
        CustomButton(
          onTap: () {
            Navigator.of(context).pop(true);
          },
          text: AppStrings.yesPlease.tr(),
          width: 120.w,
          backgroundColor: AppColors.primaryColor,
        ),
        CustomButton(
          onTap: () {
            Navigator.of(context).pop(false);
          },
          text: AppStrings.noThankYou.tr(),
          width: 120.w,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontSize: 16.sp),
          isBackgroundGradient: false,
          backgroundColor: Colors.transparent,
        ),
      ],
    ),
  );
}
