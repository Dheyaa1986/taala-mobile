class ServiceTypeModel {
  final String? id;
  final String? name;
  final String? image;

  const ServiceTypeModel({this.id, this.name, this.image});

  int? get profileId => int.tryParse(id ?? '');

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? json['nameAr']?.toString(),
      image: json['imageUrl']?.toString(),
    );
  }
}
