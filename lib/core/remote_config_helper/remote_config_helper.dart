import 'package:firebase_remote_config/firebase_remote_config.dart';

const minimumAppBuild = 'minimum_app_build';
const recommendedAppBuild = 'recommended_app_build';
const currentAppBuild = 'current_app_build';

class RemoteConfigHelper {
  final remoteConfig = FirebaseRemoteConfig.instance;

  // initialize remote config
  static Future<void> initialize() async {
    print('asdasdasd adasd');
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Set configuration
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // These will be used before the values are fetched from Firebase Remote Config.
    await remoteConfig.setDefaults(const {
      minimumAppBuild: 1,
      recommendedAppBuild: 1,
      currentAppBuild: 1,
    });

    // Fetch the values from Firebase Remote Config
    await remoteConfig.fetchAndActivate();
    print('asasdasdas asdd ${remoteConfig.getInt(minimumAppBuild)}');
    // Optional: listen for and activate changes to the Firebase Remote Config values
    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
    });
  }

  // Helper methods to simplify using the values in other parts of the code
  int getMinimumAppBuild() => remoteConfig.getInt(minimumAppBuild);
  int getRecommendedAppBuild() => remoteConfig.getInt(recommendedAppBuild);
  int getCurrentAppBuild() => remoteConfig.getInt(currentAppBuild);
}
