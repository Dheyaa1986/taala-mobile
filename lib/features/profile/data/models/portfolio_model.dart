import 'package:equatable/equatable.dart';
import 'package:taal/core/app_config/app_urls.dart';

class PortfolioModel extends Equatable {
  final String id;
  final String description;
  final List<String> images;
  final String? youtubeVideoId;
  final String? youtubeUrl;

  const PortfolioModel({
    required this.id,
    required this.description,
    required this.images,
    this.youtubeVideoId,
    this.youtubeUrl,
  });

  bool get hasVideo =>
      (youtubeVideoId?.isNotEmpty ?? false) ||
      (youtubeUrl?.isNotEmpty ?? false);

  String get coverImage {
    if (images.isNotEmpty) {
      final image = images.first;
      return image.startsWith('http') ? image : AppUrls.imageLink(image);
    }
    final videoId = youtubeVideoId?.trim();
    if (videoId != null && videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return '';
  }

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
      youtubeVideoId: json['youtubeVideoId']?.toString(),
      youtubeUrl: json['youtubeUrl']?.toString(),
    );
  }

  @override
  List<Object?> get props =>
      [id, description, images, youtubeVideoId, youtubeUrl];
}
