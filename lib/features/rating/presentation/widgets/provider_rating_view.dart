import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/avatars/user_avatar.dart';
import 'package:taal/features/rating/data/models/provider_ratings_model.dart';
import 'package:taal/features/rating/data/models/review_model.dart';
import 'package:taal/features/rating/presentation/widgets/rating_bar_widget.dart';
import 'package:taal/features/rating/presentation/widgets/rating_card.dart';

class ProviderRatingView extends StatelessWidget {
  const ProviderRatingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: 24.height,
          ),
          const SliverToBoxAdapter(
            child: RatingCard(
              ratings: ProviderRatingsModel(
                totalRatings: 4.1,
                totalReviews: 120,
                ratings: [110, 10],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: 24.height,
          ),
          SliverList.separated(
            itemBuilder: (context, index) => UserReviewCard(
              review: ReviewModel(
                id: "$index",
                image: "https://cdn-icons-png.flaticon.com/512/219/219983.png",
                name: "User $index",
                rating: Random().nextInt(5),
                comment: "This is a review comment from user $index." * 8,
                date: DateTime.now().subtract(Duration(days: index)),
              ),
            ),
            separatorBuilder: (_, __) => 16.height,
            itemCount: 10,
          ),
          SliverToBoxAdapter(
            child: 16.height,
          ),
        ],
      ),
    );
  }
}

class UserReviewCard extends StatelessWidget {
  final ReviewModel review;
  const UserReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: AppColors.borderColor.withOpacity(0.5),
          width: 1.0.w,
        ),
        borderRadius: BorderRadius.circular(12.0).r,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0).r,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              radius: 32.r,
              useImageLink: false,
              url: review.image,
            ),
            13.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    titleAlignment: ListTileTitleAlignment.top,
                    dense: true,
                    trailing: RatingBarWidget(totalRatings: review.rating),
                    title: Text(
                      review.name,
                      style: TextStyle(
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat("dd/MM/yyyy").format(review.date),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  8.height,
                  Text(
                    review.comment,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
