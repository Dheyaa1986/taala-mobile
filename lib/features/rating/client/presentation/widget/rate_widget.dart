import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';

class ProviderRatingBar extends StatelessWidget {
  final double rating;
  final double itemSize;
  final bool allowHalfRating;
  final void Function(double)? onRatingUpdate;

  const ProviderRatingBar({
    super.key,
    required this.rating,
    this.itemSize = 20.0,
    this.allowHalfRating = true,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: allowHalfRating,
      itemCount: 5,
      itemSize: itemSize.sp,
      itemPadding: EdgeInsets.symmetric(horizontal: 6.w),
      unratedColor: AppColors.borderColorMain,
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: AppColors.rateColor,
      ),
      ignoreGestures: onRatingUpdate == null,
      onRatingUpdate: onRatingUpdate ?? (_) {},
    );
  }
}
