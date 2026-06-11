import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/font_styles.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/notifications/data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return Material(
      color: isRead ? AppColors.lightBGColor : AppColors.greyBG,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                              color: AppColors.whatsAppGreen,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageIcon extends StatelessWidget {
  const _MessageIcon({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final iconColor = isRead
        ? AppColors.greyText
        : AppColors.primaryColor.withValues(alpha: 0.85);

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.iconButtonBG
            : AppColors.lightImageBgColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: isRead
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        color: iconColor,
        size: 22.sp,
      ),
    );
  }
}
