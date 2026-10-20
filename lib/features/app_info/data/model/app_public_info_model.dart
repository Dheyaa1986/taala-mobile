class AppPublicInfoModel {
  const AppPublicInfoModel({
    this.termsAr = '',
    this.termsEn = '',
    this.privacyAr = '',
    this.privacyEn = '',
    this.legalUpdatedAt,
    this.supportWhatsApp,
    this.supportWhatsAppMessage = '',
    this.androidMinimumBuild = 0,
    this.iosMinimumBuild = 0,
    this.androidRecommendedBuild = 0,
    this.iosRecommendedBuild = 0,
    this.androidStoreUrl = '',
    this.iosStoreUrl = '',
    this.iosAppStoreId = '',
  });

  final String termsAr;
  final String termsEn;
  final String privacyAr;
  final String privacyEn;
  final DateTime? legalUpdatedAt;
  final String? supportWhatsApp;
  final String supportWhatsAppMessage;
  final int androidMinimumBuild;
  final int iosMinimumBuild;
  final int androidRecommendedBuild;
  final int iosRecommendedBuild;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final String iosAppStoreId;

  bool get hasSupportWhatsApp =>
      supportWhatsApp != null && supportWhatsApp!.trim().isNotEmpty;

  String termsForLocale(String languageCode) =>
      languageCode.startsWith('ar') ? termsAr : termsEn;

  String privacyForLocale(String languageCode) =>
      languageCode.startsWith('ar') ? privacyAr : privacyEn;

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }

  static int _readInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  factory AppPublicInfoModel.fromJson(Map<String, dynamic> json) {
    return AppPublicInfoModel(
      termsAr: json['termsAr']?.toString() ?? '',
      termsEn: json['termsEn']?.toString() ?? '',
      privacyAr: json['privacyAr']?.toString() ?? '',
      privacyEn: json['privacyEn']?.toString() ?? '',
      legalUpdatedAt: json['legalUpdatedAt'] != null
          ? DateTime.tryParse(json['legalUpdatedAt'].toString())
          : null,
      supportWhatsApp: _nullableString(json['supportWhatsApp']),
      supportWhatsAppMessage: json['supportWhatsAppMessage']?.toString() ?? '',
      androidMinimumBuild: _readInt(json['androidMinimumBuild']),
      iosMinimumBuild: _readInt(json['iosMinimumBuild']),
      androidRecommendedBuild: _readInt(json['androidRecommendedBuild']),
      iosRecommendedBuild: _readInt(json['iosRecommendedBuild']),
      androidStoreUrl: json['androidStoreUrl']?.toString() ?? '',
      iosStoreUrl: json['iosStoreUrl']?.toString() ?? '',
      iosAppStoreId: json['iosAppStoreId']?.toString() ?? '',
    );
  }
}

enum LegalDocumentType { terms, privacy }
