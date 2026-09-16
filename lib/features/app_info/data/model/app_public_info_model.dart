class AppPublicInfoModel {
  const AppPublicInfoModel({
    this.termsAr = '',
    this.termsEn = '',
    this.privacyAr = '',
    this.privacyEn = '',
    this.legalUpdatedAt,
    this.supportWhatsApp,
    this.supportWhatsAppMessage = '',
  });

  final String termsAr;
  final String termsEn;
  final String privacyAr;
  final String privacyEn;
  final DateTime? legalUpdatedAt;
  final String? supportWhatsApp;
  final String supportWhatsAppMessage;

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
    );
  }
}

enum LegalDocumentType { terms, privacy }
