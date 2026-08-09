class ServiceTypeModel {
  final String? id;
  final String? name;
  final String? image;
  final String? categoryId;
  final String? categoryCode;
  final String? categoryName;

  const ServiceTypeModel({
    this.id,
    this.name,
    this.image,
    this.categoryId,
    this.categoryCode,
    this.categoryName,
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
    );
  }
}
