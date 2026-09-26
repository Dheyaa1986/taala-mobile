import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:taal/core/app_config/app_store_config.dart';

const minimumAppBuild = 'minimum_app_build';
const recommendedAppBuild = 'recommended_app_build';
const currentAppBuild = 'current_app_build';
const androidMinimumAppBuild = 'android_minimum_app_build';
const iosMinimumAppBuild = 'ios_minimum_app_build';
const androidRecommendedAppBuild = 'android_recommended_app_build';
const iosRecommendedAppBuild = 'ios_recommended_app_build';
const androidStoreUrl = 'android_store_url';
const iosStoreUrl = 'ios_store_url';
const iosAppStoreId = 'ios_app_store_id';

class RemoteConfigHelper {
  RemoteConfigHelper();

  FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults({
      minimumAppBuild: 0,
      recommendedAppBuild: 0,
      currentAppBuild: 0,
      androidMinimumAppBuild: 0,
      iosMinimumAppBuild: 0,
      androidRecommendedAppBuild: 0,
      iosRecommendedAppBuild: 0,
      androidStoreUrl: AppStoreConfig.defaultAndroidStoreUrl,
      iosStoreUrl: AppStoreConfig.defaultIosStoreUrl,
      iosAppStoreId: '',
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep defaults/cached values when fetch fails offline.
    }

    remoteConfig.onConfigUpdated.listen((event) async {
      try {
        await remoteConfig.activate();
      } catch (_) {}
    });
  }

  Future<void> refresh() async {
    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {}
  }

  int getMinimumAppBuild() => remoteConfig.getInt(minimumAppBuild);

  int getRecommendedAppBuild() => remoteConfig.getInt(recommendedAppBuild);

  int getCurrentAppBuild() => remoteConfig.getInt(currentAppBuild);

  int getAndroidMinimumAppBuild() {
    final platformSpecific = remoteConfig.getInt(androidMinimumAppBuild);
    if (platformSpecific > 0) return platformSpecific;
    return getMinimumAppBuild();
  }

  int getIosMinimumAppBuild() {
    final platformSpecific = remoteConfig.getInt(iosMinimumAppBuild);
    if (platformSpecific > 0) return platformSpecific;
    return getMinimumAppBuild();
  }

  int getAndroidRecommendedAppBuild() {
    final platformSpecific = remoteConfig.getInt(androidRecommendedAppBuild);
    if (platformSpecific > 0) return platformSpecific;
    return getRecommendedAppBuild();
  }

  int getIosRecommendedAppBuild() {
    final platformSpecific = remoteConfig.getInt(iosRecommendedAppBuild);
    if (platformSpecific > 0) return platformSpecific;
    return getRecommendedAppBuild();
  }

  String getAndroidStoreUrl() => remoteConfig.getString(androidStoreUrl);

  String getIosStoreUrl() => remoteConfig.getString(iosStoreUrl);

  String getIosAppStoreId() => remoteConfig.getString(iosAppStoreId);
}
