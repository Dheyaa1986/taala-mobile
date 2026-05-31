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

  ThemeModel({
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
    return ThemeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      colors: json['colors'] != null 
          ? ThemeColors.fromJson(json['colors'] as Map<String, dynamic>)
          : null,
      logoUrl: json['logoUrl'] as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      occasion: json['occasion'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'colors': colors?.toJson(),
      'logoUrl': logoUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'isActive': isActive,
      'occasion': occasion,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class ThemeColors {
  final String? primary;
  final String? secondary;
  final String? accent;
  final String? background;
  final String? text;

  ThemeColors({
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

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'background': background,
      'text': text,
    };
  }
}
