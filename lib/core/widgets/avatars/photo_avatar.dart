import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taal/core/widgets/buttons/custom_icon_button.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/app_config/app_urls.dart';
import '../../app_config/app_icons.dart';

class PhotoAvatar extends StatefulWidget {
  final File? image;
  final String? url;
  final bool? isEditing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool? hasGradient;
  final double? size, borderWidth, padding;
  const PhotoAvatar({
    super.key,
    this.image,
    this.onTap,
    this.backgroundColor,
    this.hasGradient = true,
    this.url,
    this.size,
    this.borderWidth,
    this.padding,
    this.isEditing = false,
  });

  @override
  State<PhotoAvatar> createState() => _PhotoAvatarState();
}

class _PhotoAvatarState extends State<PhotoAvatar> {
  bool hasError = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: widget.size ?? 100.w,
            width: widget.size ?? 100.w,
            padding: REdgeInsets.all(widget.padding ?? 0),
            decoration: BoxDecoration(
              image: widget.image != null || widget.url != null
                  ? DecorationImage(
                      image: widget.image != null
                          ? FileImage(
                              widget.image!,
                            )
                          : CachedNetworkImageProvider(hasError
                              ? "https://ecointelligentgrowth.net/wp-content/uploads/2020/08/user-placeholder.jpg"
                              : widget.url!.contains("http")
                                  ? widget.url!
                                  : "${AppUrls.base}/${widget.url}"),
                      fit: BoxFit.cover,
                      onError: (_, __) => setState(() {
                        hasError = true;
                      }),
                    )
                  : null,
              color: widget.image != null || widget.url != null
                  ? null
                  : widget.backgroundColor ?? AppColors.textFieldFillColor,
              shape: BoxShape.circle,
            ),
            child: widget.image != null || widget.url != null
                ? null
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgImageWidget(image: AppIcons.userIcon),
                    ],
                  ),
          ),
          // if (widget.isEditing! && (widget.image != null || widget.url != null))
          //   Positioned(
          //     bottom: 5.h,
          //     right: 100.w,
          //     child: SvgImageWidget(image: AppIcons.editIcon),
          //
          //   ),
          Positioned(
            bottom: 5.h,
            right: 0,
            child: Container(
                padding: REdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const SvgImageWidget(image: AppIcons.editIcon)),
          ),
        ],
      ),
    );
  }
}
