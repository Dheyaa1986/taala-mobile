import 'package:equatable/equatable.dart';

class ProviderRatingsModel extends Equatable {
  final double totalRatings;
  final int totalReviews;
  final List<int> ratings;

  const ProviderRatingsModel({
    required this.totalRatings,
    required this.totalReviews,
    required this.ratings,
  });

  factory ProviderRatingsModel.fromRatingsDetails(Map<String, dynamic> json) {
    final breakdown =
        json['breakdown'] as Map<String, dynamic>? ?? const {};
    final counts = <int>[];
    for (var stars = 5; stars >= 1; stars--) {
      final raw = breakdown['$stars'] ?? 0;
      counts.add((raw as num).toInt());
    }

    return ProviderRatingsModel(
      totalRatings: (json['overallAverage'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['ratersCount'] as num?)?.toInt() ?? 0,
      ratings: counts,
    );
  }

  @override
  List<Object> get props => [totalRatings, totalReviews, ratings];
}
