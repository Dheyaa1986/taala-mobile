import 'package:equatable/equatable.dart';
import 'package:taal/core/app_config/app_urls.dart';

class PortfolioModel extends Equatable {
  final String id;
  final String description;
  final List<String> images;

  const PortfolioModel({
    required this.id,
    required this.description,
    required this.images,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>? ?? [];
    final images = imagesList
        .map((item) {
          if (item is! Map<String, dynamic>) return '';
          final url = item['url']?.toString() ?? '';
          if (url.isEmpty) return '';
          return url.startsWith('http') ? url : AppUrls.imageLink(url);
        })
        .where((url) => url.isNotEmpty)
        .toList();

    return PortfolioModel(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: images,
    );
  }

  @override
  List<Object?> get props => [id, description, images];
}
