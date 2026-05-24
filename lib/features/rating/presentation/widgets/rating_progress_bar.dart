import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';

class RatingProgressBar extends StatelessWidget {
  const RatingProgressBar({
    super.key,
    required this.rate,
    required this.totalReviews,
    required this.starNo,
  });

  final int rate, starNo, totalReviews;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: "$starNo ",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.star_rounded,
                size: 24.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ]),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        8.width,
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 6.h,
            borderRadius: BorderRadius.circular(24.0).r,
            value: rate / totalReviews,
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            color: AppColors.secondaryColor,
          ),
        ),
        8.width,
        Text(
          "$rate",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
