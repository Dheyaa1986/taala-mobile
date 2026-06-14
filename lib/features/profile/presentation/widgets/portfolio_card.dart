import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_urls.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/profile/data/models/portfolio_model.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioModel portfolio;
  const PortfolioCard({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12).r,
        side: const BorderSide(
          color: AppColors.borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              portfolio.description,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
            12.height,
            ClipRRect(
              borderRadius: BorderRadius.circular(8).r,
              child: CachedNetworkImage(
                imageUrl: _resolveImage(portfolio.images),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 167.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveImage(List<String> images) {
    if (images.isEmpty) return '';
    final image = images.first;
    if (image.startsWith('http')) return image;
    return AppUrls.imageLink(image);
  }
}
