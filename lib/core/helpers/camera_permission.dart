import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class CameraPermission {
  const CameraPermission._();

  static Future<bool> ensure() async {
    var status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) return true;

    status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      status = await Permission.camera.status;
      if (status.isGranted || status.isLimited) return true;
    }

    // iOS ImagePicker can still show the system camera prompt if Info.plist
    // has NSCameraUsageDescription, even when this plugin reports denied.
    return Platform.isIOS;
  }
}
