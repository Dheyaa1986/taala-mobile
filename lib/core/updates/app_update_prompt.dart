import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/config/routes/app_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/updates/app_update_service.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';

Future<void> showAppUpdatePrompt({
  required bool forceUpdate,
}) async {
  final context = AppRouter.appNavigatorKey.currentContext;
  if (context == null) return;

  final updateService = getIt<AppUpdateService>();
  if (!forceUpdate) {
    updateService.markRecommendedPromptShown();
  }

  await showDialog<void>(
    barrierDismissible: !forceUpdate,
    context: context,
    builder: (dialogContext) {
      return PopScope(
        canPop: !forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.r)),
          ),
          title: Text(
            forceUpdate
                ? AppStrings.updateIsRequiredTitle.tr()
                : AppStrings.updateRecommendedTitle.tr(),
            style: Theme.of(dialogContext).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                forceUpdate
                    ? AppStrings.updateIsRequiredSubtitle.tr()
                    : AppStrings.updateRecommendedSubtitle.tr(),
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: AppStrings.update.tr(),
                onTap: () => updateService.openStoreListing(),
                isBackgroundGradient: true,
              ),
              if (!forceUpdate) ...[
                SizedBox(height: 12.h),
                CustomButton(
                  text: AppStrings.updateLater.tr(),
                  onTap: () => Navigator.of(dialogContext).pop(),
                  isBackgroundGradient: false,
                  backgroundColor: Colors.transparent,
                  style: Theme.of(dialogContext)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 16.sp),
                ),
              ] else ...[
                SizedBox(height: 12.h),
                CustomButton(
                  text: AppStrings.exit.tr(),
                  onTap: () => exit(0),
                  isBackgroundGradient: false,
                  backgroundColor: Colors.transparent,
                  style: Theme.of(dialogContext)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 16.sp),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> handleAppUpdateCheck() async {
  final updateService = getIt<AppUpdateService>();
  await updateService.refreshConfig();

  final status = updateService.checkForUpdate();
  if (status == AppUpdateStatus.required) {
    await showAppUpdatePrompt(forceUpdate: true);
    return false;
  }

  if (updateService.shouldShowRecommendedPrompt()) {
    await showAppUpdatePrompt(forceUpdate: false);
  }

  return true;
}
