import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';

Future<bool> showWaylPaymentInstructionsSheet(
  BuildContext context, {
  String? providerPhone,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            16.height,
            Text(
              AppStrings.waylPaymentStepsTitle.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            16.height,
            _StepRow(
              number: '1',
              text: AppStrings.waylPaymentStepPhone.tr(),
            ),
            10.height,
            _StepRow(
              number: '2',
              text: AppStrings.waylPaymentStepMethod.tr(),
            ),
            10.height,
            _StepRow(
              number: '3',
              text: AppStrings.waylPaymentStepPay.tr(),
            ),
            if (providerPhone != null && providerPhone.trim().isNotEmpty) ...[
              16.height,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  AppStrings.waylPaymentRegisteredPhone.tr(
                    namedArgs: {'phone': providerPhone.trim()},
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
            20.height,
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppStrings.continueToPayment.tr()),
            ),
            8.height,
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppStrings.cancel.tr()),
            ),
          ],
        ),
      );
    },
  );

  return result ?? false;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14.r,
          backgroundColor: AppColors.primaryColor,
          child: Text(
            number,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        12.width,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: TextStyle(fontSize: 14.sp, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
