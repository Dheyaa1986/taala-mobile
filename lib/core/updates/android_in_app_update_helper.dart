import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

enum AndroidUpdateAttemptResult {
  notApplicable,
  notAvailable,
  started,
  fallbackToStore,
}

class AndroidInAppUpdateHelper {
  const AndroidInAppUpdateHelper._();

  static Future<AndroidUpdateAttemptResult> tryImmediateUpdate() async {
    if (!Platform.isAndroid || kIsWeb) {
      return AndroidUpdateAttemptResult.notApplicable;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return AndroidUpdateAttemptResult.notAvailable;
      }

      if (info.immediateUpdateAllowed) {
        final result = await InAppUpdate.performImmediateUpdate();
        if (result == AppUpdateResult.success) {
          return AndroidUpdateAttemptResult.started;
        }
      }

      return AndroidUpdateAttemptResult.fallbackToStore;
    } catch (_) {
      return AndroidUpdateAttemptResult.fallbackToStore;
    }
  }
}
