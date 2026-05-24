import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_urls.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage(
      {super.key,
      this.height,
      this.width,
      this.borderRadius,
      this.radius,
      this.url,
      this.serverImage = true ,
      this.fit});
  final double? height, width, radius;
  final String? url;
  final bool? serverImage;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? double.maxFinite,
      width: width ?? double.maxFinite,
      decoration: BoxDecoration(

        borderRadius:borderRadius?? BorderRadius.circular(radius ?? 8.r),
      ),
      child: CachedNetworkImage(
        fit: fit??BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            borderRadius:borderRadius?? BorderRadius.circular(radius ?? 8.r),
            color: AppColors.descriptionColor,
          ),

          child: Icon(
            Icons.broken_image,
            color: AppColors.greyBG,
            size: (height ?? 50) / 2,
          ),
        ),
        imageUrl:/* serverImage ==true ? AppUrls.imageLink(url??''):*/(url??''),
        imageBuilder: (context, imageProvider) {
          return Container(
            width: width ?? double.maxFinite,
            height: height ?? double.maxFinite,
            decoration: BoxDecoration(

              borderRadius:borderRadius?? BorderRadius.circular(radius ?? 8.r),
              image: DecorationImage(image: imageProvider,  fit: fit??BoxFit.cover,),
            ),
          );
        },
      ),
    );
  }
}
