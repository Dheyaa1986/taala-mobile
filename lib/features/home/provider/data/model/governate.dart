 import 'package:equatable/equatable.dart';

class GovernanceModel extends Equatable{
  final String? name;
  final int? id;

  GovernanceModel({required this.name, required this.id});


  factory GovernanceModel.fromJson(Map<String, dynamic> json) {
    return GovernanceModel(
      name: json['name'],
      id: json['id'],
    );
  }
  @override
  List<Object?> get props => [ id];
}

 class CityModel  extends Equatable{
  final String? name;
  final int? id;

  CityModel({required this.name, required this.id});


  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'],
      id: json['id'],
    );
  }

  @override
  List<Object?> get props => [ id];
}

class RegionModel extends Equatable{
  final String? name;
  final int? id;

  RegionModel({required this.name, required this.id});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      name: json['name'],
      id: json['id'],
    );
  }
  @override
  List<Object?> get props => [ id];
}
