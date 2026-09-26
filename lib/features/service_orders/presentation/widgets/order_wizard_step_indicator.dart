import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class OrderWizardStepIndicator extends StatelessWidget {
  const OrderWizardStepIndicator({
    super.key,
    required this.currentStep,
    this.skipDestination = false,
  });

  final int currentStep;
  final bool skipDestination;

  static const _stepLabels = [
    AppStrings.orderStepDeparture,
    AppStrings.orderStepDestination,
    AppStrings.orderStepService,
  ];

  List<String> get _visibleLabels => skipDestination
      ? [AppStrings.orderStepDeparture, AppStrings.orderStepService]
      : _stepLabels;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final labels = _visibleLabels;

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.wizardStepProgress.tr(
              namedArgs: {
                'current': '${currentStep + 1}',
                'total': '${labels.length}',
              },
            ),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          10.height,
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3.h,
                      margin: REdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i <= currentStep
                            ? tokens.primary
                            : tokens.borderSubtle,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                _StepDot(
                  index: i,
                  label: labels[i].tr(),
                  isActive: i == currentStep,
                  isCompleted: i < currentStep,
                  tokens: tokens,
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
    required this.tokens,
  });

  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final TaalaTokens tokens;

  @override
  Widget build(BuildContext context) {
    final textColor = isActive
        ? tokens.textPrimary
        : isCompleted
            ? tokens.primary
            : tokens.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isActive
                ? tokens.primary
                : isCompleted
                    ? tokens.primarySoft
                    : tokens.surfaceMuted,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive || isCompleted
                  ? tokens.primary
                  : tokens.borderSubtle,
              width: isActive ? 0 : 1.5,
            ),
          ),
          child: Center(
            child: isCompleted && !isActive
                ? Icon(Icons.check, size: 18.r, color: tokens.primary)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isActive ? tokens.onPrimary : textColor,
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
