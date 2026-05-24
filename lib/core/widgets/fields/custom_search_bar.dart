import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';
import '../../app_config/font_styles.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final bool autoFocus, enabled;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? hint;
  final Color? borderColor, backgroundColor;
  final double? height;
  const CustomSearchBar({
    super.key,
    this.controller,
    this.autoFocus = false,
    this.onChanged,
    this.hint,
    this.borderColor,
    this.backgroundColor,
    this.height,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 38.h,
      child: SearchBar(
        enabled: enabled,
        onTap: onTap,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        onChanged: onChanged,
        controller: controller,
        hintText: hint ?? AppStrings.search.tr(),
        autoFocus: autoFocus,
        hintStyle: WidgetStatePropertyAll(
          FontStyles.textStyle14,
        ),
        leading: SvgPicture.asset(
          AppIcons.search,
          width: 14.w,
          height: 14.h,
        ),
        backgroundColor: WidgetStatePropertyAll(
          backgroundColor ?? Colors.white,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(color: borderColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
