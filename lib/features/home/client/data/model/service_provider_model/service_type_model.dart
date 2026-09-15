class ServiceTypeModel {
  final String? id;
  final String? name;
  final String? image;
  final String? categoryId;
  final String? categoryCode;
  final String? categoryName;
  final bool isEnabled;

  const ServiceTypeModel({
    this.id,
    this.name,
    this.image,
    this.categoryId,
    this.categoryCode,
    this.categoryName,
    this.isEnabled = true,
  });

  int? get profileId => int.tryParse(id ?? '');

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? json['nameAr']?.toString(),
      image: json['iconUrl']?.toString() ?? json['imageUrl']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryCode: json['categoryCode']?.toString(),
      categoryName: json['categoryName']?.toString() ??
          json['categoryNameAr']?.toString() ??
          json['categoryNameEn']?.toString(),
      isEnabled: _parseIsEnabled(json['isEnabled']),
    );
  }

  static bool _parseIsEnabled(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'false' || normalized == '0') return false;
    return true;
  }
}
