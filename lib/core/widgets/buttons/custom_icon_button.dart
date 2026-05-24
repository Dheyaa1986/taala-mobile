import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../svg_image/svg_image_widget.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.iconSize,
    this.size,
    this.bgColor,
    this.bgRadius,
    this.isNetwork,
    this.onTap,
    this.padding,
    this.shape,
    this.iconColor,
    this.border,
  });
  final String icon;
  final double? iconSize, size, bgRadius, padding;
  final Color? bgColor, iconColor;
  final bool? isNetwork;
  final Function()? onTap;
  final BoxShape? shape;
  final BoxBorder? border;
  factory CustomIconButton.lightGreyBg(
          {required Function()? onTap,
            double? size,
            double? iconSize,
            double? padding,

          required String icon, bool? isNetwork}) =>
      CustomIconButton(
        padding:padding ,
iconSize: iconSize,
        size: size,
        bgRadius:  50.r,
        isNetwork: isNetwork,
        icon: icon,
        bgColor: AppColors.iconBgColor,
        onTap: onTap,
      );
  factory CustomIconButton.circle({
    required Function()? onTap,
    required String icon,
    required bool isNetwork,
    Color? bgColor,
    double? size,
    Color? iconColor,
  }) =>
      CustomIconButton(
        isNetwork: isNetwork,
        icon: icon,
        bgColor: bgColor ?? AppColors.primaryColor,
        onTap: onTap,
        shape: BoxShape.circle,
        size: size,
        iconColor: iconColor,
      );
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size?.h,
      width: size?.w,
      padding: EdgeInsets.all(padding ?? 8),
      decoration: BoxDecoration(
        border: border,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(bgRadius ?? 6.r),
        color: bgColor ?? AppColors.iconButtonBG,
        shape: shape ?? BoxShape.rectangle,
      ),
      child: SvgImageWidget(
          isNetwork: isNetwork,
          image: icon,
          onTap: onTap,
          width: iconSize?.h,
          height: iconSize?.w,
          colorFilter: iconColor == null
              ? null
              : ColorFilter.mode(iconColor ?? Colors.white, BlendMode.srcIn)),
    );
  }
}
