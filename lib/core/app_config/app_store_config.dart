class AppStoreConfig {
  const AppStoreConfig._();

  static const String androidPackageId = 'com.mintops.taala';

  static const String defaultAndroidStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  static const String defaultIosStoreUrl =
      'https://apps.apple.com/search?term=taala';
}
