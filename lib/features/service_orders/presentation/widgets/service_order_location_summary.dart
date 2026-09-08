import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
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

  String? get _areaLabel {
    final address = order.clientAddress?.trim();
    if (address == null || address.isEmpty) return null;
    return address;
  }

  @override
  Widget build(BuildContext context) {
    final distance = _distanceLabel;
    final area = _areaLabel;
    final eta = _etaMinutes;

    if (distance == null && area == null && eta == null) {
      return const SizedBox.shrink();
    }

    final textStyle = TextStyle(
      fontSize: compact ? 12.sp : 13.sp,
      color: AppColors.commentColor,
      height: 1.4,
    );
    final valueStyle = TextStyle(
      fontSize: compact ? 12.sp : 13.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.lightMainText,
      height: 1.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (area != null) ...[
          _SummaryRow(
            label: AppStrings.region.tr(),
            value: area,
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
            valueStyle: valueStyle.copyWith(color: AppColors.primaryColor),
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
