import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
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
    final tokens = TaalaTokens.of(context);
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
                        decoration: BoxDecoration(
                          color: tokens.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      6.width,
                    ],
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
                8.height,
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                        height: 1.45,
                      ),
                ),
                if (dateLabel != null) ...[
                  8.height,
                  Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: tokens.textSecondary,
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
    final tokens = TaalaTokens.of(context);

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: isRead ? tokens.surfaceMuted : tokens.primarySoft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        color: isRead ? tokens.textSecondary : tokens.primary,
        size: 22.sp,
      ),
    );
  }
}
