class AppStoreConfig {
  const AppStoreConfig._();

  static const String androidPackageId = 'com.mintops.taala';

  static const String defaultAndroidStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  static const String defaultIosStoreUrl =
      'https://apps.apple.com/app/id6782614751';

  static String resolveAndroidStoreUrl(String configured) {
    if (configured.trim().isNotEmpty) return configured.trim();
    return defaultAndroidStoreUrl;
  }

  static String resolveIosStoreUrl({
    required String configuredUrl,
    required String appStoreId,
    bool preferNativeScheme = true,
  }) {
    final trimmedId = appStoreId.trim();
    if (preferNativeScheme && trimmedId.isNotEmpty) {
      return 'itms-apps://itunes.apple.com/app/id$trimmedId';
    }

    if (configuredUrl.trim().isNotEmpty) {
      return _normalizeIosUrl(configuredUrl.trim(), preferNativeScheme);
    }

    if (trimmedId.isNotEmpty) {
      return preferNativeScheme
          ? 'itms-apps://itunes.apple.com/app/id$trimmedId'
          : 'https://apps.apple.com/app/id$trimmedId';
    }

    return defaultIosStoreUrl;
  }

  static String _normalizeIosUrl(String url, bool preferNativeScheme) {
    if (!preferNativeScheme) return url;

    final appIdMatch = RegExp(r'id(\d+)').firstMatch(url);
    if (appIdMatch != null) {
      return 'itms-apps://itunes.apple.com/app/id${appIdMatch.group(1)}';
    }

    if (url.startsWith('itms-apps://')) return url;
    return url;
  }
}
