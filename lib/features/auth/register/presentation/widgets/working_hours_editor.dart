import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/provider_offering/working_hours_model.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class WorkingHoursEditor extends StatelessWidget {
  const WorkingHoursEditor({
    super.key,
    required this.hours,
    required this.onChanged,
  });

  final List<WorkingHoursDayModel> hours;
  final ValueChanged<List<WorkingHoursDayModel>> onChanged;

  static List<String> _dayLabels() => [
        AppStrings.providerOfferingDaySun.tr(),
        AppStrings.providerOfferingDayMon.tr(),
        AppStrings.providerOfferingDayTue.tr(),
        AppStrings.providerOfferingDayWed.tr(),
        AppStrings.providerOfferingDayThu.tr(),
        AppStrings.providerOfferingDayFri.tr(),
        AppStrings.providerOfferingDaySat.tr(),
      ];

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.providerWorkingHours.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: tokens.textPrimary,
          ),
        ),
        8.height,
        ...List.generate(hours.length, (index) {
          final day = hours[index];
          final labels = _dayLabels();
          final label = labels[day.day.clamp(0, labels.length - 1)];

          return Padding(
            padding: REdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 72.w,
                  child: Text(label, style: TextStyle(fontSize: 13.sp)),
                ),
                Switch(
                  value: day.isOpen,
                  onChanged: (value) {
                    final updated = [...hours];
                    updated[index] = day.copyWith(isOpen: value);
                    onChanged(updated);
                  },
                ),
                if (day.isOpen) ...[
                  Expanded(
                    child: TextFormField(
                      initialValue: day.openTime,
                      decoration: InputDecoration(
                        labelText: AppStrings.providerOpenTime.tr(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final updated = [...hours];
                        updated[index] = day.copyWith(openTime: value);
                        onChanged(updated);
                      },
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: TextFormField(
                      initialValue: day.closeTime,
                      decoration: InputDecoration(
                        labelText: AppStrings.providerCloseTime.tr(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final updated = [...hours];
                        updated[index] = day.copyWith(closeTime: value);
                        onChanged(updated);
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
