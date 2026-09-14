import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/features/profile/data/models/portfolio_model.dart';
import 'package:taal/features/profile/presentation/screens/portfolio_gallery_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioCard extends StatelessWidget {
  final PortfolioModel portfolio;
  final bool canDelete;
  final VoidCallback? onDelete;

  const PortfolioCard({
    super.key,
    required this.portfolio,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final coverImage = portfolio.coverImage;
    final extraCount = portfolio.images.length - 1;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    portfolio.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                if (canDelete && onDelete != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 20.r,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: coverImage.isEmpty
                  ? null
                  : () => _openPortfolio(context),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8).r,
                    child: coverImage.isEmpty
                        ? Container(
                            width: double.infinity,
                            height: 167.h,
                            color: AppColors.borderColor,
                            child: const Icon(Icons.image_not_supported),
                          )
                        : CachedNetworkImage(
                            imageUrl: coverImage,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 167.h,
                          ),
                  ),
                  if (portfolio.hasVideo)
                    Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32.r,
                      ),
                    ),
                  if (extraCount > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '+$extraCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Future<void> _openPortfolio(BuildContext context) async {
    final youtubeUrl = portfolio.youtubeUrl?.trim();
    if (portfolio.hasVideo && youtubeUrl != null && youtubeUrl.isNotEmpty) {
      final uri = Uri.parse(youtubeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if (portfolio.images.isEmpty) return;

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PortfolioGalleryScreen(
          images: portfolio.images,
          title: portfolio.description,
        ),
      ),
    );
  }
}
