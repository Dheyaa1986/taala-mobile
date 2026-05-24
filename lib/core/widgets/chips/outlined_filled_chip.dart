import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class OutlinedFilledChip extends StatelessWidget {
  const OutlinedFilledChip({
    super.key,
    required this.onTap,
    required this.isSelected,
    required this.name,
    this.borderColor,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });
  final bool isSelected;
  final Color? borderColor;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  final Function(bool)? onTap;
  final String name;
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      visualDensity: VisualDensity.compact,
      labelPadding: EdgeInsets.zero,
      showCheckmark: false,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: BorderSide(
            color: borderColor ??
                (isSelected
                    ? Colors.transparent
                    : Theme.of(context).primaryColor),
          )),
      disabledColor: backgroundColor,
      shadowColor: Colors.transparent,

      label: Text(name),
      selected: isSelected,
      onSelected: onTap,
      selectedColor: Colors.blue,

      backgroundColor: backgroundColor ??
          (isSelected
              ? Theme.of(context).primaryColor
              : const Color(0x1438ABFE)),
      labelStyle: TextStyle(
          fontSize: fontSize ?? 16.sp,
          fontWeight: FontWeight.w600,
          color: textColor ??
              (isSelected
                  ? AppColors.whiteColor
                  : Theme.of(context).primaryColor)),
    );
  }
}
