import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';


import '../../../config/routes/app_router.dart';
import '../../app_config/app_strings.dart';
import '../buttons/custom_button.dart';

void showMustUpdateDialog() {
  showDialog(
      barrierDismissible: false,
      context: AppRouter.appNavigatorKey.currentState!.context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14.0.r))),
            backgroundColor: Theme.of(context).canvasColor,
            title: Text(AppStrings.updateIsRequiredTitle.tr(),
                style: Theme.of(context).textTheme.headlineSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.updateIsRequiredSubtitle.tr(),
                    style: Theme.of(context).textTheme.labelSmall),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.update.tr(),
                        onTap: () {},
                        isBackgroundGradient: true,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.exit.tr(),
                        onTap: () => exit(0),
                        isBackgroundGradient: false,
                        backgroundColor: Colors.transparent,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
}
