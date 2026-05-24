import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';


class RatingRow extends StatelessWidget {
  final double rating;
  final int? totalRatings;
  final String? date;
  final double? size;
  const RatingRow({
    Key? key,
    required this.rating,
     this.totalRatings,
     this.date,
     this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) =>  const Icon(
            Icons.star,
            color: AppColors.rateIconColor,
          ),
          itemCount: 5,
          itemSize:size?? 10,
          direction: Axis.horizontal,
        ),
        if(totalRatings != null)
        Text(
          '($totalRatings)',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontSize: 8.sp,
              color: AppColors.rateCountColor,
              fontWeight: FontWeight.w400),
        ),

        if(date != null)
          Text(
            '$date',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                fontSize: 8.sp,
                color: AppColors.rateCountColor,
                fontWeight: FontWeight.w400),
          ),
      ],
    );
  }
}
