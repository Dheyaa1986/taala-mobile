import 'dart:io';

import 'package:taal/core/app_config/app_store_config.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/package_info_helper/package_info_helper.dart';
import 'package:taal/core/updates/android_in_app_update_helper.dart';
import 'package:taal/core/updates/app_version_config_provider.dart';

enum AppUpdateStatus {
  none,
  recommended,
  required,
}

class AppUpdateService {
  AppUpdateService(this._configProvider);

  final AppVersionConfigProvider _configProvider;
  bool _recommendedPromptShown = false;

  Future<void> refreshConfig() async {
    await _configProvider.refresh();
  }

  AppUpdateStatus checkForUpdate() {
    final installedBuild = PackageInfoHelper.buildNumber;
    if (installedBuild <= 0) return AppUpdateStatus.none;

    final minimumBuild = _minimumBuildForPlatform();
    if (minimumBuild > 0 && installedBuild < minimumBuild) {
      return AppUpdateStatus.required;
    }

    final recommendedBuild = _recommendedBuildForPlatform();
    if (recommendedBuild > 0 && installedBuild < recommendedBuild) {
      return AppUpdateStatus.recommended;
    }

    return AppUpdateStatus.none;
  }

  int _minimumBuildForPlatform() {
    final requirements = _configProvider.requirements;
    if (Platform.isIOS) return requirements.iosMinimumBuild;
    if (Platform.isAndroid) return requirements.androidMinimumBuild;
    return 0;
  }

  int _recommendedBuildForPlatform() {
    final requirements = _configProvider.requirements;
    if (Platform.isIOS) return requirements.iosRecommendedBuild;
    if (Platform.isAndroid) return requirements.androidRecommendedBuild;
    return 0;
  }

  bool shouldShowRecommendedPrompt() {
    if (_recommendedPromptShown) return false;
    return checkForUpdate() == AppUpdateStatus.recommended;
  }

  void markRecommendedPromptShown() {
    _recommendedPromptShown = true;
  }

  Future<AndroidUpdateAttemptResult> tryAndroidImmediateUpdate() {
    return AndroidInAppUpdateHelper.tryImmediateUpdate();
  }

  Future<void> openStoreListing() async {
    final url = _resolveStoreUrl(preferNativeScheme: true);
    await getIt<CustomLauncher>().openUrl(url);
  }

  String _resolveStoreUrl({required bool preferNativeScheme}) {
    final requirements = _configProvider.requirements;

    if (Platform.isAndroid) {
      return AppStoreConfig.resolveAndroidStoreUrl(requirements.androidStoreUrl);
    }

    return AppStoreConfig.resolveIosStoreUrl(
      configuredUrl: requirements.iosStoreUrl,
      appStoreId: requirements.iosAppStoreId,
      preferNativeScheme: preferNativeScheme,
    );
  }
}
