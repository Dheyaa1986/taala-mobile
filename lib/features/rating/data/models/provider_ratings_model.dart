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

  @override
  List<Object> get props => [totalRatings, totalReviews, ratings];
}
