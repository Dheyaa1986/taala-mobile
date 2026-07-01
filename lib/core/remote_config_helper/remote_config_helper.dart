import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:taal/core/app_config/app_store_config.dart';

const minimumAppBuild = 'minimum_app_build';
const recommendedAppBuild = 'recommended_app_build';
const currentAppBuild = 'current_app_build';
const androidStoreUrl = 'android_store_url';
const iosStoreUrl = 'ios_store_url';

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
      minimumAppBuild: 1,
      recommendedAppBuild: 1,
      currentAppBuild: 1,
      androidStoreUrl: AppStoreConfig.defaultAndroidStoreUrl,
      iosStoreUrl: AppStoreConfig.defaultIosStoreUrl,
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

  String getAndroidStoreUrl() => remoteConfig.getString(androidStoreUrl);

  String getIosStoreUrl() => remoteConfig.getString(iosStoreUrl);
}
