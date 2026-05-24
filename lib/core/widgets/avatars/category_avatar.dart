import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_config/app_colors.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.icon,
  });

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43.w,
      height: 43.w,
      decoration: BoxDecoration(
        color: AppColors.lightImageBgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: SvgPicture.network(
          icon,
        ),
      ),
    );
  }
}
