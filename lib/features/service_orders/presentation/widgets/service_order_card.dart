import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/yellow_highlight_card.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';
import 'package:taal/features/service_orders/presentation/widgets/service_order_location_summary.dart';

class ServiceOrderCard extends StatelessWidget {
  const ServiceOrderCard({
    super.key,
    required this.order,
    required this.isRead,
    required this.onTap,
    this.onDelete,
    this.onAccept,
    this.showCounterpartyAsTitle = true,
    this.acceptEnabled = true,
  });

  final ServiceOrderModel order;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onAccept;
  final bool showCounterpartyAsTitle;
  final bool acceptEnabled;

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
    final tokens = TaalaTokens.of(context);
    final title = showCounterpartyAsTitle
        ? (order.clientName ?? order.providerName ?? AppStrings.serviceOrder.tr())
        : (order.serviceType?.name ?? AppStrings.serviceOrder.tr());
    final subtitle = showCounterpartyAsTitle
        ? (order.serviceType?.name ?? order.description ?? '')
        : (order.description ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YellowHighlightCard(
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
                            decoration: BoxDecoration(
                              color: tokens.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          6.width,
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tokens.textSecondary,
                              height: 1.45,
                            ),
                      ),
                    ],
                    6.height,
                    Text(
                      _statusLabel(order.status),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.primary,
                          ),
                    ),
                    if (order.status == 'pending' ||
                        order.distanceKm != null ||
                        (order.clientAddress?.isNotEmpty ?? false)) ...[
                      8.height,
                      ServiceOrderLocationSummary(
                        order: order,
                        compact: true,
                      ),
                    ],
                    if (order.agreedPrice != null) ...[
                      6.height,
                      Text(
                        '${AppStrings.proposedPrice.tr()}: ${order.agreedPrice}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (onAccept != null && order.status == 'pending') ...[
          8.height,
          TaalaButton(
            label: order.agreedPrice == null
                ? AppStrings.proposePrice.tr()
                : AppStrings.acceptAndChat.tr(),
            enabled: acceptEnabled,
            onPressed: onAccept,
          ),
        ],
      ],
    );
  }
}

class _OrderIcon extends StatelessWidget {
  const _OrderIcon({required this.isRead});

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
        Icons.assignment_outlined,
        color: isRead ? tokens.textSecondary : tokens.primary,
        size: 22.sp,
      ),
    );
  }
}
