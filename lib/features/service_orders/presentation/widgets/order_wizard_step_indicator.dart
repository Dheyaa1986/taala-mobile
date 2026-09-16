import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';

class OrderWizardStepIndicator extends StatelessWidget {
  const OrderWizardStepIndicator({
    super.key,
    required this.currentStep,
  });

  final int currentStep;

  static const _stepLabels = [
    AppStrings.orderStepDeparture,
    AppStrings.orderStepDestination,
    AppStrings.orderStepService,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.wizardStepProgress.tr(
              namedArgs: {
                'current': '${currentStep + 1}',
                'total': '${_stepLabels.length}',
              },
            ),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.commentColor,
            ),
            textAlign: TextAlign.center,
          ),
          10.height,
          Row(
            children: [
              for (var i = 0; i < _stepLabels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3.h,
                      margin: REdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i <= currentStep
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                _StepDot(
                  index: i,
                  label: _stepLabels[i].tr(),
                  isActive: i == currentStep,
                  isCompleted: i < currentStep,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final color = isActive || isCompleted
        ? AppColors.primaryColor
        : AppColors.borderColor;
    final textColor = isActive
        ? AppColors.lightMainText
        : isCompleted
            ? AppColors.primaryColor
            : AppColors.commentColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryColor
                : isCompleted
                    ? AppColors.primaryColor.withValues(alpha: 0.15)
                    : AppColors.textFieldFillColor,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isActive ? 0 : 1.5),
          ),
          child: Center(
            child: isCompleted && !isActive
                ? Icon(Icons.check, size: 18.r, color: AppColors.primaryColor)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.black : textColor,
                    ),
                  ),
          ),
        ),
        6.height,
        SizedBox(
          width: 72.w,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
