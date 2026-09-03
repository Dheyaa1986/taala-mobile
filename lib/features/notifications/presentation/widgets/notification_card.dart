import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/font_styles.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final createdAt = notification.createdAt;
    final dateLabel = createdAt != null
        ? DateFormat('dd/MM/yyyy • hh:mm a', context.locale.languageCode)
            .format(createdAt.toLocal())
        : null;

    return YellowHighlightCard(
      isHighlighted: !isRead,
      onTap: onTap,
      onDelete: onDelete,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MessageIcon(isRead: isRead),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!isRead) ...[
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      6.width,
                    ],
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: FontStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightMainText,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                8.height,
                Text(
                  notification.message,
                  style: TextStyle(
                    fontFamily: FontStyles.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.commentColor,
                    height: 1.45,
                  ),
                ),
                if (dateLabel != null) ...[
                  8.height,
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontFamily: FontStyles.fontFamily,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageIcon extends StatelessWidget {
  const _MessageIcon({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.iconButtonBG
            : AppColors.primaryColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        color: isRead ? AppColors.greyText : AppColors.primaryColor,
        size: 22.sp,
      ),
    );
  }
}
