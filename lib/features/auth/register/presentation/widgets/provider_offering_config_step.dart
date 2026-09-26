import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/provider_offering/provider_offering_mode.dart';
import 'package:taal/core/provider_offering/provider_service_offering_model.dart';
import 'package:taal/core/provider_offering/working_hours_model.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/auth/register/presentation/widgets/working_hours_editor.dart';

class ProviderOfferingConfigStep extends StatelessWidget {
  const ProviderOfferingConfigStep({
    super.key,
    required this.offerings,
    required this.onChanged,
  });

  final List<ProviderServiceOfferingInput> offerings;
  final ValueChanged<List<ProviderServiceOfferingInput>> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    if (offerings.isEmpty) {
      return Padding(
        padding: REdgeInsets.symmetric(vertical: 24),
        child: Text(
          AppStrings.providerOfferingCraneOnlyHint.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(color: tokens.textSecondary, fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: offerings.length,
      separatorBuilder: (_, __) => 20.height,
      itemBuilder: (context, index) {
        final offering = offerings[index];
        return _OfferingCard(
          offering: offering,
          onModeChanged: (mode) {
            final updated = [...offerings];
            updated[index].mode = mode;
            onChanged(updated);
          },
          onHoursChanged: (hours) {
            final updated = [...offerings];
            updated[index].workingHours = hours;
            onChanged(updated);
          },
        );
      },
    );
  }
}

class _OfferingCard extends StatelessWidget {
  const _OfferingCard({
    required this.offering,
    required this.onModeChanged,
    required this.onHoursChanged,
  });

  final ProviderServiceOfferingInput offering;
  final ValueChanged<ProviderOfferingMode> onModeChanged;
  final ValueChanged<List<WorkingHoursDayModel>> onHoursChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return Container(
      padding: REdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            offering.serviceTypeName,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
          12.height,
          _ModeTile(
            mode: ProviderOfferingMode.fixed,
            selected: offering.mode == ProviderOfferingMode.fixed,
            title: AppStrings.providerOfferingFixed.tr(),
            subtitle: AppStrings.providerOfferingFixedHint.tr(),
            onTap: () => onModeChanged(ProviderOfferingMode.fixed),
          ),
          8.height,
          _ModeTile(
            mode: ProviderOfferingMode.mobile,
            selected: offering.mode == ProviderOfferingMode.mobile,
            title: AppStrings.providerOfferingMobile.tr(),
            subtitle: AppStrings.providerOfferingMobileHint.tr(),
            onTap: () => onModeChanged(ProviderOfferingMode.mobile),
          ),
          8.height,
          _ModeTile(
            mode: ProviderOfferingMode.both,
            selected: offering.mode == ProviderOfferingMode.both,
            title: AppStrings.providerOfferingBoth.tr(),
            subtitle: AppStrings.providerOfferingBothHint.tr(),
            onTap: () => onModeChanged(ProviderOfferingMode.both),
          ),
          if (offering.requiresShop) ...[
            16.height,
            WorkingHoursEditor(
              hours: offering.workingHours,
              onChanged: onHoursChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final ProviderOfferingMode mode;
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: REdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? tokens.primary : tokens.borderSubtle,
            width: selected ? 2 : 1,
          ),
          color: selected ? tokens.primary.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          children: [
            Icon(mode.icon, size: 28.sp, color: tokens.primary),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: tokens.primary),
          ],
        ),
      ),
    );
  }
}
