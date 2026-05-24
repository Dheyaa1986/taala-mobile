import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';


class UploadPhotosCard extends StatelessWidget {
  final List<File> images;
  final ValueChanged<List<File>> onPick;
  final ValueChanged<File>? onPhotoRemoved;
  final bool hasError;
  const UploadPhotosCard({
    super.key,
    required this.images,
    required this.onPick,
    this.onPhotoRemoved,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116.h,
      child: images.isNotEmpty
          ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return _AddPhotoCard(
                    onPressed: _pickImages,
                  );
                }
                return _PhotoCard(
                  onRemove: onPhotoRemoved == null
                      ? null
                      : () => onPhotoRemoved?.call(images[index]),
                  image: images[index].path,
                );
              },
              separatorBuilder: (context, index) => 8.width,
              itemCount: images.length + 1,
            )
          : GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 57.5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color:
                        hasError ? AppColors.errorColor : AppColors.borderColor,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.upload,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    8.height,
                    Text(
                      AppStrings.addPhoto.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12.sp,
                          ),
                    ),
                    8.height,
                    Text(
                      AppStrings.addPhotosMessage.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 10.sp,
                            color: AppColors.lightGreyText,
                          ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) onPick(images.map((e) => File(e.path)).toList());
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.image,
    this.onRemove,
  });

  final String image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 116.w,
          height: 116.h,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: image.contains("http")
                  ? CachedNetworkImageProvider(image)
                  : FileImage(File(image)),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        if (onRemove != null)
          PositionedDirectional(
            child: IconButton.filled(
              onPressed: onRemove,
              style: IconButton.styleFrom(backgroundColor: Colors.white),
              icon: Icon(Icons.remove, color: AppColors.errorColor),
            ),
          ),
      ],
    );
  }
}

class _AddPhotoCard extends StatelessWidget {
  const _AddPhotoCard({
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 116.w,
        height: 116.h,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.borderColor,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 48.r,
            color: AppColors.borderColor,
          ),
        ),
      ),
    );
  }
}
