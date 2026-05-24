import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class CustomOutlinedGradientChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const CustomOutlinedGradientChip({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            AppColors.primaryColor,
            AppColors.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(
        1.r,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            // begin: AlignmentDirectional.centerStart,
            // end: AlignmentDirectional.centerEnd,
            colors: [
              AppColors.secondaryColor,
              AppColors.primaryColor,
            ],
          ).createShader(rect),
          child: Text(
            label,
            textHeightBehavior: TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            strutStyle: StrutStyle(
              height: 1.0,
              forceStrutHeight: true,
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14.sp,
                  color: Colors.white,
                  // height: 1.h,
                ),
          ),
        ),
      ),
    );
  }
}
