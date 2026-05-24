import 'package:equatable/equatable.dart';

class ServiceTypeModel extends Equatable{
 final int? id;
 final String? name;
 final String? image;

 const ServiceTypeModel({this.id, this.name, this.image});

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }

  @override
  List<Object?> get props => [id,];
}