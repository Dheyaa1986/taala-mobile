import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id, image, name, comment;
  final DateTime date;
  final int rating;

  const ReviewModel({
    required this.id,
    required this.image,
    required this.name,
    required this.comment,
    required this.date,
    required this.rating,
  });

  factory ReviewModel.fromRatingJson(Map<String, dynamic> json) {
    final rater = json['rater'] as Map<String, dynamic>? ?? const {};
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      name: rater['name']?.toString() ?? '',
      image: rater['imageUrl']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      rating: ((json['value'] as num?) ?? 0).round(),
      date: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object> get props => [id, image, name, comment, date, rating];
}
