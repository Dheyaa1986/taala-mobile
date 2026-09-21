import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/widgets/bottom_sheets/custom_bottom_sheet.dart';

class DocumentImagePicker {
  DocumentImagePicker._();

  static Future<File?> pickAndCrop(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.hardEdge,
      builder: (_) {
        return CustomBottomSheet(
          isScrollControlled: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  AppStrings.camera.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.image_outlined,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  AppStrings.gallery.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !context.mounted) return null;

    if (source == ImageSource.camera) {
      final granted = await _ensureCameraPermission();
      if (!granted) return null;
    }

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (picked == null || !context.mounted) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppStrings.cropDocument.tr(),
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: AppStrings.cropDocument.tr(),
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
        ),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }

  static Future<bool> _ensureCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return !status.isDenied && !status.isPermanentlyDenied;
  }
}
