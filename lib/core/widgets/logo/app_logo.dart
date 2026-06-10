import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_icons.dart';
import '../../app_config/app_urls.dart';
import '../../../config/themes/theme.dart';
import '../cached_network_image/custom_cached_network_image.dart';
import '../svg_image/svg_image_widget.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    required this.isSvg,
    this.width,
    this.height,
    this.imagePath,
    this.fit,
  });
  final bool isSvg;
  final double? width, height;
  final String? imagePath;
  final BoxFit? fit;

  factory AppLogo.svg({
    double? width,
    double? height,
    String? imagePath,
    BoxFit? fit,
  }) =>
      AppLogo(
        isSvg: true,
        width: width,
        height: height,
        imagePath: imagePath,
        fit: fit,
      );

  factory AppLogo.png({
    double? width,
    double? height,
    String? imagePath,
    BoxFit? fit,
  }) =>
      AppLogo(
        isSvg: false,
        width: width,
        height: height,
        imagePath: imagePath,
        fit: fit,
      );

  String? _resolveLogoPath() {
    if (imagePath != null && imagePath!.isNotEmpty) return imagePath;
    final themeLogo = TariqyAppTheme.activeTheme?.logoUrl;
    if (themeLogo == null || themeLogo.isEmpty) return null;
    if (themeLogo.startsWith('http')) return themeLogo;
    return AppUrls.imageLink(themeLogo);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPath = _resolveLogoPath();
    final logoWidth = width ?? 111.w;
    final logoHeight = height ?? 36.h;

    if (resolvedPath != null && resolvedPath.startsWith('http')) {
      return CustomCachedNetworkImage(
        url: resolvedPath,
        width: logoWidth,
        height: logoHeight,
        radius: 0,
      );
    }

    return isSvg
        ? SvgImageWidget(
            image: resolvedPath ?? AppIcons.logo,
            width: logoWidth,
            height: logoHeight,
          )
        : Image.asset(
            resolvedPath ?? AppIcons.logoPNG,
            width: logoWidth,
            height: logoHeight,
            fit: fit,
          );
  }
}
