import 'package:equatable/equatable.dart';

class PortfolioModel extends Equatable {
  final String id, name, description;
  final List<String> images;

  const PortfolioModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
  });

  @override
  List<Object?> get props => [id, name, description, images];
}
