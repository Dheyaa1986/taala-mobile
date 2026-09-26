class AppVersionRequirements {
  const AppVersionRequirements({
    this.androidMinimumBuild = 0,
    this.iosMinimumBuild = 0,
    this.androidRecommendedBuild = 0,
    this.iosRecommendedBuild = 0,
    this.androidStoreUrl = '',
    this.iosStoreUrl = '',
    this.iosAppStoreId = '',
  });

  final int androidMinimumBuild;
  final int iosMinimumBuild;
  final int androidRecommendedBuild;
  final int iosRecommendedBuild;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final String iosAppStoreId;

  static const empty = AppVersionRequirements();

  AppVersionRequirements merge(AppVersionRequirements other) {
    return AppVersionRequirements(
      androidMinimumBuild: _max(androidMinimumBuild, other.androidMinimumBuild),
      iosMinimumBuild: _max(iosMinimumBuild, other.iosMinimumBuild),
      androidRecommendedBuild:
          _max(androidRecommendedBuild, other.androidRecommendedBuild),
      iosRecommendedBuild: _max(iosRecommendedBuild, other.iosRecommendedBuild),
      androidStoreUrl: _prefer(androidStoreUrl, other.androidStoreUrl),
      iosStoreUrl: _prefer(iosStoreUrl, other.iosStoreUrl),
      iosAppStoreId: _prefer(iosAppStoreId, other.iosAppStoreId),
    );
  }

  factory AppVersionRequirements.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    String readString(dynamic value) => value?.toString().trim() ?? '';

    return AppVersionRequirements(
      androidMinimumBuild: readInt(json['androidMinimumBuild']),
      iosMinimumBuild: readInt(json['iosMinimumBuild']),
      androidRecommendedBuild: readInt(json['androidRecommendedBuild']),
      iosRecommendedBuild: readInt(json['iosRecommendedBuild']),
      androidStoreUrl: readString(json['androidStoreUrl']),
      iosStoreUrl: readString(json['iosStoreUrl']),
      iosAppStoreId: readString(json['iosAppStoreId']),
    );
  }

  static int _max(int a, int b) => a > b ? a : b;

  static String _prefer(String primary, String fallback) {
    if (primary.isNotEmpty) return primary;
    return fallback;
  }
}
