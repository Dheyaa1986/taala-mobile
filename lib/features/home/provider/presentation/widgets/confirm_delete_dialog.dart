import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/back_button.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/buttons/custom_icon_button.dart';
Future showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required Color? buttonColor,
}) async {
  return await showDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
      buttonColor: buttonColor ,
      title: title,
      message: message,
      onConfirm: () => context.pop(true),
    ),
  );
}
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? buttonColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomBackButton(verticalPadding: 0,),
              Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              16.height,
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.dateColor,
                ),
              ),
              24.height,
              Row(
                children: [
                  Expanded(
                    child: CustomButton.filled(
                      padding:  EdgeInsets.symmetric(horizontal: 12.w),

                      height: 40.h,
                      text: AppStrings.confirm.tr(),
                      backgroundColor:buttonColor?? AppColors.primaryColor,
                      onTap: () {
                        // onConfirm();
                        context.pop(true);
                      },
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: CustomButton.outlined(
                      padding:  EdgeInsets.symmetric(horizontal: 12.w),
                      height: 40.h,
                      text: AppStrings.cancel.tr(),
                      borderColor: AppColors.primaryColor,
                      textColor: AppColors.primaryColor,
                      onTap: () {
                        onCancel?.call();
                        context.pop(false);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}