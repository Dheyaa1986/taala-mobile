import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_config/app_colors.dart';

class RoundedIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String icon;
  const RoundedIconButton({
    super.key,
    this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        padding: const EdgeInsets.all(8).r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: AppColors.iconButtonBG,
        ),
        child: SvgPicture.asset(icon),
      ),
    );
  }
}
