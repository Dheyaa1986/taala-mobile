class ThemeModel {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final ThemeColors? colors;
  final String? logoUrl;
  final String? backgroundImageUrl;
  final bool isActive;
  final String? occasion;
  final String? startDate;
  final String? endDate;

  const ThemeModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.colors,
    this.logoUrl,
    this.backgroundImageUrl,
    required this.isActive,
    this.occasion,
    this.startDate,
    this.endDate,
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    final data = json['response'] as Map<String, dynamic>? ?? json;
    return ThemeModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      nameAr: data['nameAr'] as String?,
      nameEn: data['nameEn'] as String?,
      colors: data['colors'] != null
          ? ThemeColors.fromJson(data['colors'] as Map<String, dynamic>)
          : null,
      logoUrl: data['logoUrl'] as String?,
      backgroundImageUrl: data['backgroundImageUrl'] as String?,
      isActive: data['isActive'] as bool? ?? false,
      occasion: data['occasion'] as String?,
      startDate: data['startDate']?.toString(),
      endDate: data['endDate']?.toString(),
    );
  }
}

class ThemeColors {
  final String? primary;
  final String? secondary;
  final String? accent;
  final String? background;
  final String? text;

  const ThemeColors({
    this.primary,
    this.secondary,
    this.accent,
    this.background,
    this.text,
  });

  factory ThemeColors.fromJson(Map<String, dynamic> json) {
    return ThemeColors(
      primary: json['primary'] as String?,
      secondary: json['secondary'] as String?,
      accent: json['accent'] as String?,
      background: json['background'] as String?,
      text: json['text'] as String?,
    );
  }
}
