import 'package:firebase_remote_config/firebase_remote_config.dart';

const minimumAppBuild = 'minimum_app_build';
const recommendedAppBuild = 'recommended_app_build';
const currentAppBuild = 'current_app_build';

class RemoteConfigHelper {
  final remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults(const {
      minimumAppBuild: 1,
      recommendedAppBuild: 1,
      currentAppBuild: 1,
    });

    await remoteConfig.fetchAndActivate();
    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
    });
  }

  int getMinimumAppBuild() => remoteConfig.getInt(minimumAppBuild);
  int getRecommendedAppBuild() => remoteConfig.getInt(recommendedAppBuild);
  int getCurrentAppBuild() => remoteConfig.getInt(currentAppBuild);
}
