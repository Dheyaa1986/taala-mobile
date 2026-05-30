import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../svg_image/svg_image_widget.dart';

Widget reusableIcon({
  required String image,
}) {
  return Center(
    child: Container(
      width: 100.w,
      height: 100.h,
      decoration: const BoxDecoration(
        color: AppColors.textFieldFillColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgImageWidget(
          image: image,
        ),
      ),
    ),
  );
}