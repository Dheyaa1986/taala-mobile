import 'package:taal/features/rating/data/models/provider_ratings_model.dart';
import 'package:taal/features/rating/data/models/review_model.dart';

class ProviderRatingsPageModel {
  ProviderRatingsPageModel({
    required this.summary,
    required this.reviews,
    required this.totalPages,
    required this.currentPage,
  });

  final ProviderRatingsModel summary;
  final List<ReviewModel> reviews;
  final int totalPages;
  final int currentPage;

  factory ProviderRatingsPageModel.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? json;
    final details =
        response['ratingsDetails'] as Map<String, dynamic>? ?? const {};
    final data = response['data'] as List<dynamic>? ?? [];

    return ProviderRatingsPageModel(
      summary: ProviderRatingsModel.fromRatingsDetails(details),
      reviews: data
          .map((item) => ReviewModel.fromRatingJson(item as Map<String, dynamic>))
          .toList(),
      totalPages: response['totalPages'] as int? ?? 1,
      currentPage: response['currentPage'] as int? ?? 1,
    );
  }
}
