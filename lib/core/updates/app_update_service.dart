import 'dart:io';

import 'package:taal/core/app_config/app_store_config.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/package_info_helper/package_info_helper.dart';
import 'package:taal/core/remote_config_helper/remote_config_helper.dart';

enum AppUpdateStatus {
  none,
  recommended,
  required,
}

class AppUpdateService {
  AppUpdateService(this._remoteConfigHelper);

  final RemoteConfigHelper _remoteConfigHelper;
  bool _recommendedPromptShown = false;

  Future<void> refreshConfig() async {
    await _remoteConfigHelper.refresh();
  }

  AppUpdateStatus checkForUpdate() {
    final installedBuild = PackageInfoHelper.buildNumber;
    if (installedBuild <= 0) return AppUpdateStatus.none;

    final minimumBuild = _remoteConfigHelper.getMinimumAppBuild();
    if (minimumBuild > 0 && installedBuild < minimumBuild) {
      return AppUpdateStatus.required;
    }

    final recommendedBuild = _remoteConfigHelper.getRecommendedAppBuild();
    if (recommendedBuild > 0 && installedBuild < recommendedBuild) {
      return AppUpdateStatus.recommended;
    }

    return AppUpdateStatus.none;
  }

  bool shouldShowRecommendedPrompt() {
    if (_recommendedPromptShown) return false;
    return checkForUpdate() == AppUpdateStatus.recommended;
  }

  void markRecommendedPromptShown() {
    _recommendedPromptShown = true;
  }

  Future<void> openStoreListing() async {
    final url = _resolveStoreUrl();
    await getIt<CustomLauncher>().openUrl(url);
  }

  String _resolveStoreUrl() {
    if (Platform.isAndroid) {
      final configured = _remoteConfigHelper.getAndroidStoreUrl().trim();
      if (configured.isNotEmpty) return configured;
      return AppStoreConfig.defaultAndroidStoreUrl;
    }

    final configured = _remoteConfigHelper.getIosStoreUrl().trim();
    if (configured.isNotEmpty) return configured;
    return AppStoreConfig.defaultIosStoreUrl;
  }
}
