import 'package:equatable/equatable.dart';

class CountryModel extends Equatable {
  final String? name;
  final String? id;

  const CountryModel({required this.name, required this.id});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name']?.toString() ?? json['nameEn']?.toString(),
      id: json['id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id];
}

class GovernanceModel extends Equatable {
  final String? name;
  final String? id;

  const GovernanceModel({required this.name, required this.id});

  factory GovernanceModel.fromJson(Map<String, dynamic> json) {
    return GovernanceModel(
      name: json['name']?.toString() ?? json['nameEn']?.toString(),
      id: json['id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id];
}

class CityModel extends Equatable {
  final String? name;
  final String? id;

  const CityModel({required this.name, required this.id});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name']?.toString() ?? json['nameEn']?.toString(),
      id: json['id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id];
}

class RegionModel extends Equatable {
  final String? name;
  final String? id;

  const RegionModel({required this.name, required this.id});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      name: json['name']?.toString(),
      id: json['id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id];
}
