import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/font_styles.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';

class ServiceOrderCard extends StatelessWidget {
  const ServiceOrderCard({
    super.key,
    required this.order,
    required this.isRead,
    required this.onTap,
    this.onDelete,
    this.showCounterpartyAsTitle = true,
  });

  final ServiceOrderModel order;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool showCounterpartyAsTitle;

  String _statusLabel(String? status) {
    switch (status) {
      case 'accepted':
        return AppStrings.orderStatusAccepted.tr();
      case 'en_route':
        return AppStrings.orderStatusEnRoute.tr();
      case 'arrived':
        return AppStrings.orderStatusArrived.tr();
      case 'completed':
        return AppStrings.orderStatusCompleted.tr();
      case 'cancelled':
        return AppStrings.orderStatusCancelled.tr();
      default:
        return AppStrings.orderStatusPending.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = showCounterpartyAsTitle
        ? (order.clientName ?? order.providerName ?? AppStrings.serviceOrder.tr())
        : (order.serviceType?.name ?? AppStrings.serviceOrder.tr());
    final subtitle = showCounterpartyAsTitle
        ? (order.serviceType?.name ?? order.description ?? '')
        : (order.description ?? '');

    return YellowHighlightCard(
      isHighlighted: !isRead,
      onTap: onTap,
      onDelete: onDelete,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderIcon(isRead: isRead),
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
                        title,
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
                if (subtitle.isNotEmpty) ...[
                  8.height,
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontStyles.fontFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.commentColor,
                      height: 1.45,
                    ),
                  ),
                ],
                6.height,
                Text(
                  _statusLabel(order.status),
                  style: TextStyle(
                    fontFamily: FontStyles.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderIcon extends StatelessWidget {
  const _OrderIcon({required this.isRead});

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
        Icons.assignment_outlined,
        color: isRead ? AppColors.greyText : AppColors.primaryColor,
        size: 22.sp,
      ),
    );
  }
}
