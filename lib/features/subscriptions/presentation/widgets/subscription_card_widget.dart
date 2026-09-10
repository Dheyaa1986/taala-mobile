import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';

class SubscriptionCardWidget extends StatelessWidget {
  const SubscriptionCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.cardColor,
    required this.cardStyle,
    required this.isCurrent,
    required this.currentLabel,
  });

  final String title;
  final String subtitle;
  final String priceLabel;
  final Color cardColor;
  final String cardStyle;
  final bool isCurrent;
  final String currentLabel;

  bool get _isFill => cardStyle == 'fill';

  Color get _primaryTextColor =>
      _isFill ? _contrastOn(cardColor) : AppColors.lightMainText;

  Color get _secondaryTextColor => _isFill
      ? _contrastOn(cardColor).withValues(alpha: 0.85)
      : Colors.grey.shade700;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: REdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _isFill ? cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: cardColor,
          width: _isFill ? 0 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: REdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: _primaryTextColor,
                      height: 1.25,
                    ),
                  ),
                ),
                if (isCurrent) ...[
                  SizedBox(width: 10.w),
                  _CurrentPlanBadge(
                    label: currentLabel,
                    cardColor: cardColor,
                    isFill: _isFill,
                  ),
                ],
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: _secondaryTextColor,
                height: 1.35,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              priceLabel,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: _isFill ? _contrastOn(cardColor) : cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color parseHexColor(String? hex, {Color fallback = AppColors.primaryColor}) {
    if (hex == null || hex.isEmpty) return fallback;
    final normalized = hex.replaceFirst('#', '').trim();
    if (normalized.length != 6) return fallback;
    final value = int.tryParse('FF$normalized', radix: 16);
    if (value == null) return fallback;
    return Color(value);
  }

  static Color _contrastOn(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.55 ? AppColors.lightMainText : Colors.white;
  }
}

class _CurrentPlanBadge extends StatelessWidget {
  const _CurrentPlanBadge({
    required this.label,
    required this.cardColor,
    required this.isFill,
  });

  final String label;
  final Color cardColor;
  final bool isFill;

  Color get _accent =>
      isFill ? SubscriptionCardWidget._contrastOn(cardColor) : cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFill
            ? _accent.withValues(alpha: 0.18)
            : cardColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16.sp,
            color: _accent,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }
}
