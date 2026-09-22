import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/service_orders/data/model/service_order_model.dart';

class ServiceOrderLocationSummary extends StatelessWidget {
  const ServiceOrderLocationSummary({
    super.key,
    required this.order,
    this.tracking,
    this.compact = false,
  });

  final ServiceOrderModel order;
  final ServiceOrderTrackingModel? tracking;
  final bool compact;

  String? get _distanceLabel {
    final km = tracking?.distanceKm ?? order.distanceKm;
    if (km == null) return null;
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} ${AppStrings.meters.tr()}';
    }
    return '${km.toStringAsFixed(2)} ${AppStrings.distanceKm.tr()}';
  }

  int? get _etaMinutes => tracking?.etaMinutes ?? order.etaMinutes;

  String? get _breakdownAddress {
    final address = order.clientAddress?.trim();
    if (address == null || address.isEmpty) return null;
    return address;
  }

  String? get _destinationAddress {
    final address = order.destinationAddress?.trim();
    if (address == null || address.isEmpty) return null;
    return address;
  }

  bool get _hasTowingDestination =>
      order.destinationLatitude != null &&
      order.destinationLongitude != null &&
      _destinationAddress != null;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final distance = _distanceLabel;
    final breakdown = _breakdownAddress;
    final destination = _hasTowingDestination ? _destinationAddress : null;
    final eta = _etaMinutes;

    if (distance == null &&
        breakdown == null &&
        destination == null &&
        eta == null) {
      return const SizedBox.shrink();
    }

    final textStyle = (Theme.of(context).textTheme.bodySmall ??
            const TextStyle())
        .copyWith(
          fontSize: compact ? 12.sp : 13.sp,
          color: tokens.textSecondary,
          height: 1.4,
        );
    final valueStyle = (Theme.of(context).textTheme.bodySmall ??
            const TextStyle())
        .copyWith(
          fontSize: compact ? 12.sp : 13.sp,
          fontWeight: FontWeight.w600,
          color: tokens.textPrimary,
          height: 1.4,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (breakdown != null) ...[
          _SummaryRow(
            label: _hasTowingDestination
                ? AppStrings.breakdownLocation.tr()
                : AppStrings.region.tr(),
            value: breakdown,
            labelStyle: textStyle,
            valueStyle: valueStyle,
          ),
          if (destination != null || distance != null || eta != null)
            (compact ? 4 : 6).height,
        ],
        if (destination != null) ...[
          _SummaryRow(
            label: AppStrings.destinationLocation.tr(),
            value: destination,
            labelStyle: textStyle,
            valueStyle: valueStyle,
          ),
          if (distance != null || eta != null) (compact ? 4 : 6).height,
        ],
        if (distance != null)
          _SummaryRow(
            label: AppStrings.orderDistance.tr(),
            value: distance,
            labelStyle: textStyle,
            valueStyle: valueStyle.copyWith(color: tokens.primary),
          ),
        if (eta != null) ...[
          (compact ? 4 : 6).height,
          _SummaryRow(
            label: AppStrings.estimatedArrival.tr(),
            value: '$eta ${AppStrings.minutes.tr()}',
            labelStyle: textStyle,
            valueStyle: valueStyle,
          ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: labelStyle,
        children: [
          TextSpan(text: '$label: '),
          TextSpan(text: value, style: valueStyle),
        ],
      ),
    );
  }
}
