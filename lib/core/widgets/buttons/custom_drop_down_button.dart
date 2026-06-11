import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/app_config/app_colors.dart';

class CustomDropdownButton extends StatelessWidget {
  final String? selectedOption;
  final Function(String?) onChanged;
  final List<String> options;
  final String iconPath;
  final double width;
  final double height;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final Gradient? gradient;

  const CustomDropdownButton({
    this.selectedOption,
    required this.onChanged,
    required this.options,
    this.iconPath = '',
    this.width = 130.0,
    this.height = 30.0,
    this.textStyle,
    this.backgroundColor = AppColors.lightBGColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(44)),
    super.key,
    this.padding,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 5).r,
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: borderRadius,
      ),
      child: DropdownButton<String>(
        value: selectedOption,
        icon: icon ??
            Padding(
              padding: EdgeInsetsDirectional.only(start: 12.w, end: 5.w),
              child: SvgPicture.asset(
                iconPath,
                width: 15.w,
                height: 15.h,
              ),
            ),
        underline: const SizedBox(),
        alignment: Alignment.center,
        style: textStyle ??
            TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option,
                      style: textStyle ??
                          TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Poppins',
                          ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
