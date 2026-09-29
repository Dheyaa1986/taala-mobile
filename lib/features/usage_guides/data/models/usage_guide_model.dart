class UsageGuideModel {
  const UsageGuideModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.bodyAr,
    this.bodyEn,
    this.videoUrl,
    this.thumbnailUrl,
    required this.audience,
    required this.sortOrder,
    required this.isPublished,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String? bodyAr;
  final String? bodyEn;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String audience;
  final int sortOrder;
  final bool isPublished;

  String titleForLocale(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;

  String? bodyForLocale(String languageCode) {
    final text = languageCode == 'ar' ? bodyAr : bodyEn;
    if (text == null || text.trim().isEmpty) return null;
    return text.trim();
  }

  String? get youtubeVideoId {
    final url = videoUrl?.trim();
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    return null;
  }

  String? get thumbnailImageUrl {
    final custom = thumbnailUrl?.trim();
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    final videoId = youtubeVideoId;
    if (videoId != null) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return null;
  }

  factory UsageGuideModel.fromJson(Map<String, dynamic> json) {
    return UsageGuideModel(
      id: json['id']?.toString() ?? '',
      titleAr: json['titleAr']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      bodyAr: json['bodyAr']?.toString(),
      bodyEn: json['bodyEn']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      audience: json['audience']?.toString() ?? 'all',
      sortOrder: int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      isPublished: json['isPublished'] == true || json['isPublished'] == 'true',
    );
  }
}

class UsageGuidesResponse {
  const UsageGuidesResponse({
    required this.revision,
    required this.items,
  });

  final int revision;
  final List<UsageGuideModel> items;

  factory UsageGuidesResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final list = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => UsageGuideModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <UsageGuideModel>[];
    return UsageGuidesResponse(
      revision: int.tryParse(json['revision']?.toString() ?? '') ?? 0,
      items: list,
    );
  }
}
