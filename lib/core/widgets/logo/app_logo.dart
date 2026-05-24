import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_icons.dart';
import '../svg_image/svg_image_widget.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.isSvg, this.width, this.height,this.imagePath,this.fit});
  final bool isSvg;
  final double? width, height;
  final String? imagePath;
  final BoxFit? fit;

  factory AppLogo.svg({double? width, double? height,String? imagePath,BoxFit? fit}) =>
      AppLogo(isSvg: true, width: width, height: height,imagePath: imagePath, fit: fit,);

  factory AppLogo.png({double? width, double? height,String? imagePath,BoxFit? fit}) =>
      AppLogo(isSvg: false, width: width, height: height,imagePath: imagePath, fit: fit,);

  @override
  Widget build(BuildContext context) {
    return isSvg
        ? SvgImageWidget(
            image:imagePath ??  AppIcons.logo,
            width: width ?? 111.w,
            height: height ?? 36.h,
          )
        : Image.asset(
            imagePath ?? AppIcons.logoPNG,
            width: width ?? 111.w,
            height: height ?? 36.h,
            fit:fit ,
          );
  }
}
