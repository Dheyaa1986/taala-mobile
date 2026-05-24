import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';
import 'custom_bottom_sheet.dart';

class ImagePickerHelper {
  selectImage(context, Function(File? image) onPick) {
    showModalBottomSheet<ImageSource>(
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
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.camera,
                ),
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
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.gallery,
                ),
              ),
            ],
          ),
        );
      },
    ).then((source) {
      if (source == null) return;
      _pickImage(source, onPick);
    });
  }

  Future<bool> _checkPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    if (cameraStatus == PermissionStatus.denied) {
      cameraStatus = await Permission.camera.request();
      if (cameraStatus == PermissionStatus.denied) return false;
    }
    PermissionStatus galleryStatus = await Permission.storage.request();
    if (galleryStatus == PermissionStatus.denied) {
      galleryStatus = await Permission.camera.request();
      if (galleryStatus == PermissionStatus.denied) return false;
    }

    return true;
  }

  void _pickImage(ImageSource source, Function(File? image) onPick) async {
    final bool status = await _checkPermissions();
    if (!status) return;
    try {
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      onPick(File(image.path));
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  pickCameraImage( Function(File? image) onPick) => _pickImage(ImageSource.camera, onPick);


}
