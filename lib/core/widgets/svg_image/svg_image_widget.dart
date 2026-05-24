import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_config/app_icons.dart';
import '../../app_config/app_urls.dart';

class SvgImageWidget extends StatelessWidget {
  const SvgImageWidget(
      {super.key,
      required this.image,
      this.width,
      this.matchTextDirection,
      this.height,
      this.isNetwork,
      this.fit,
      this.onTap,
      this.colorFilter});
  final String image;
  final double? height;
  final bool? matchTextDirection;
  final double? width;
  final BoxFit? fit;
  final bool? isNetwork;
  final ColorFilter? colorFilter;
  final Function()? onTap;
  factory SvgImageWidget.appLogo({double? width}) => SvgImageWidget(
        image: AppIcons.logo,
        width: width,
      );
  factory SvgImageWidget.network({String? icon}) => SvgImageWidget(
        isNetwork: true,
        image: icon ?? '',
      );
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: isNetwork == true
          ? SvgPicture.network(
        fit: fit?? BoxFit.contain,
              matchTextDirection: matchTextDirection ?? false,
              AppUrls.base + image,
              width: width,
              height: height,

            )
          : SvgPicture.asset(
        fit: fit?? BoxFit.contain,
              matchTextDirection: matchTextDirection ?? false,
              image,
              width: width,
              height: height,
          colorFilter: colorFilter ??
                  const ColorFilter.mode(Color(0xffFFC20F),
                   BlendMode.srcIn),
               ),    
    );
  }
}
