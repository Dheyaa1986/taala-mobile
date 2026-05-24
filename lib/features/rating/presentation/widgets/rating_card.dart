import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/rating/data/models/provider_ratings_model.dart';
import 'package:taal/features/rating/presentation/widgets/rating_bar_widget.dart';
import 'package:taal/features/rating/presentation/widgets/rating_progress_bar.dart';

class RatingCard extends StatelessWidget {
  final ProviderRatingsModel ratings;
  const RatingCard({
    super.key,
    required this.ratings,
  });

  @override
  Widget build(BuildContext context) {
    final totalRatings = ratings.totalRatings.round();
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0).r,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              titleAlignment: ListTileTitleAlignment.top,
              dense: true,
              trailing: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: "${ratings.totalRatings} ",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: RatingBarWidget(totalRatings: totalRatings),
                  ),
                ]),
              ),
              title: Text(
                "Rating Summary",
                style: TextStyle(
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              subtitle: Text(
                "Total Reviews: ${ratings.totalReviews}",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            16.height,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final rate =
                    index < ratings.ratings.length ? ratings.ratings[index] : 0;
                return RatingProgressBar(
                  rate: rate,
                  totalReviews: ratings.totalReviews,
                  starNo: 5 - index,
                );
              },
              separatorBuilder: (_, __) => 16.height,
              itemCount: 5,
            )
          ],
        ),
      ),
    );
  }
}
