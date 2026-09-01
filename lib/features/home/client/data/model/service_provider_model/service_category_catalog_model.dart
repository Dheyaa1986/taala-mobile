import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';

class ServiceCategoryCatalogModel {
  final String? id;
  final String? code;
  final String? name;
  final int sortOrder;
  final List<ServiceTypeModel> serviceTypes;

  const ServiceCategoryCatalogModel({
    this.id,
    this.code,
    this.name,
    this.sortOrder = 99,
    this.serviceTypes = const [],
  });

  factory ServiceCategoryCatalogModel.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['serviceTypes'];
    final types = rawTypes is List
        ? rawTypes
            .map(
              (e) => ServiceTypeModel.fromJson(e as Map<String, dynamic>),
            )
            .toList()
        : <ServiceTypeModel>[];

    return ServiceCategoryCatalogModel(
      id: json['id']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString() ??
          json['nameAr']?.toString() ??
          json['nameEn']?.toString(),
      sortOrder: json['sortOrder'] is num
          ? (json['sortOrder'] as num).toInt()
          : int.tryParse(json['sortOrder']?.toString() ?? '') ?? 99,
      serviceTypes: types,
    );
  }
}
