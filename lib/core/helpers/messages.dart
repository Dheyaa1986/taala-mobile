import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../app_config/app_colors.dart';

class AppMessages {
  static Future<dynamic> showLoading(BuildContext context) =>
      showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );

  static void showError(BuildContext context, String error,
      [SnackBarAction? action]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          side: const BorderSide(
            color: AppColors.borderColor,
          ),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.error_sharp,
              color: AppColors.errorColor,
            ),
            8.width,
            Flexible(
              child: Text(
                error,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message,
      [SnackBarAction? action]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          side: const BorderSide(
            color: AppColors.borderColor,
          ),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.green,
            ),
            8.width,
            Flexible(
              child: Text(
                message,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }
}
