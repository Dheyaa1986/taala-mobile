import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_urls.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.radius,
    required this.url,
    this.fileImage,
    this.onTap,
    this.backgroundColor,
    this.useImageLink = true,
  });

  final double? radius;
  final String url;
  final File? fileImage;
  final Function()? onTap;
  final Color? backgroundColor;
  final bool useImageLink;

  double get _radius => 24.r;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        radius: radius ?? _radius,
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          radius: (radius ?? _radius) - 2.r,
          foregroundImage: fileImage != null
              ? FileImage(fileImage!)
              : CachedNetworkImageProvider(
                  !useImageLink ? url : AppUrls.imageLink(url),
                ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(
              Icons.person,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
              size: (radius ?? _radius) * (1.5).r,
            ),
          ),
        ),
      ),
    );
  }
}
