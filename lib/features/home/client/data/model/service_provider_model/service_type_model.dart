class ServiceTypeModel {
  final String? id;
  final String? name;
  final String? image;

  const ServiceTypeModel({this.id, this.name, this.image});

  int? get profileId => int.tryParse(id ?? '');
}
