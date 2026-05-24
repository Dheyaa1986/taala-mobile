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

  @override
  List<Object> get props => [id, image, name, comment, date, rating];
}
