import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/profile/presentation/cubit/provider_profile_cubit.dart';

enum _PortfolioMediaType { photos, video }

class AddPortfolioScreen extends StatefulWidget {
  const AddPortfolioScreen({super.key});

  @override
  State<AddPortfolioScreen> createState() => _AddPortfolioScreenState();
}

class _AddPortfolioScreenState extends State<AddPortfolioScreen> {
  final _descController = TextEditingController();
  final List<File> _images = [];
  File? _video;
  _PortfolioMediaType _mediaType = _PortfolioMediaType.photos;

  Future<void> _pickImages() async {
    final remaining = 10 - _images.length;
    if (remaining <= 0) return;

    final List<XFile> picked = await ImagePicker().pickMultiImage(
      limit: remaining,
    );
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null || picked.path.isEmpty) return;
    setState(() {
      _video = File(picked.path);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _video = null;
    });
  }

  Future<void> _save() async {
    final description = _descController.text.trim();
    final isVideo = _mediaType == _PortfolioMediaType.video;

    if (description.isEmpty ||
        (isVideo ? _video == null : _images.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVideo
                ? AppStrings.portfolioVideoValidation.tr()
                : AppStrings.portfolioValidation.tr(),
          ),
        ),
      );
      return;
    }

    EasyLoading.show(status: AppStrings.loading.tr());
    final cubit = context.read<ProviderProfileCubit>();
    final error = isVideo
        ? await cubit.createPortfolioVideo(
            description: description,
            video: _video!,
          )
        : await cubit.createPortfolio(
            description: description,
            images: _images,
          );
    EasyLoading.dismiss();

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.portfolioSaved.tr())),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _mediaType == _PortfolioMediaType.video;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.addPortfolio.tr()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<_PortfolioMediaType>(
              segments: [
                ButtonSegment(
                  value: _PortfolioMediaType.photos,
                  label: Text(AppStrings.portfolioPhotos.tr()),
                  icon: const Icon(Icons.photo_library_outlined),
                ),
                ButtonSegment(
                  value: _PortfolioMediaType.video,
                  label: Text(AppStrings.portfolioVideo.tr()),
                  icon: const Icon(Icons.videocam_outlined),
                ),
              ],
              selected: {_mediaType},
              onSelectionChanged: (selection) {
                setState(() {
                  _mediaType = selection.first;
                });
              },
            ),
            24.verticalSpace,
            Text(
              AppStrings.description.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            8.verticalSpace,
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppStrings.portfolioDescriptionHint.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            24.verticalSpace,
            Text(
              isVideo ? AppStrings.portfolioVideo.tr() : AppStrings.images.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            8.verticalSpace,
            if (isVideo) _buildVideoPicker() else _buildImagePicker(),
            32.verticalSpace,
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  AppStrings.save.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPicker() {
    if (_video == null) {
      return GestureDetector(
        onTap: _pickVideo,
        child: Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_call_outlined,
                size: 40.r,
                color: AppColors.primaryColor,
              ),
              8.verticalSpace,
              Text(
                AppStrings.addPortfolioVideo.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.borderColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 48.r,
                color: AppColors.primaryColor,
              ),
              8.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  _video!.path.split(Platform.pathSeparator).last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _removeVideo,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: Colors.red,
              child: Icon(
                Icons.close,
                size: 14.r,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    if (_images.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40.r,
                color: AppColors.primaryColor,
              ),
              8.verticalSpace,
              Text(
                AppStrings.addPortfolioImages.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + (_images.length < 10 ? 1 : 0),
        separatorBuilder: (_, __) => 8.horizontalSpace,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: Icon(
                  Icons.add,
                  size: 40.r,
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  _images[index],
                  width: 120.w,
                  height: 120.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: CircleAvatar(
                    radius: 12.r,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.close,
                      size: 14.r,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
