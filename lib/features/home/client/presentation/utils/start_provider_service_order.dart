import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/guest/guest_action_guard.dart';
import 'package:taal/core/helpers/guest_session_helper.dart';
import 'package:taal/core/provider_offering/provider_offering_mode.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/service_orders/presentation/models/create_service_order_args.dart';
import 'package:taal/features/service_orders/presentation/widgets/provider_visit_choice_sheet.dart';

Future<void> startProviderServiceOrder(
  BuildContext context,
  ServiceProviderModel model, {
  bool canStartOrder = true,
  bool silentIfGuest = false,
}) async {
  if (silentIfGuest && await GuestSessionHelper.isGuestBrowsing()) {
    return;
  }
  if (!await GuestActionGuard.ensureRegistered(context)) return;
  if (!canStartOrder) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.activeOrderBlockingSearch.tr())),
    );
    return;
  }
  final types = model.serviceTypes
      .where((type) => type.id != null && type.id!.isNotEmpty)
      .toList();

  if (types.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.noServiceTypesAvailable.tr())),
    );
    return;
  }

  ServiceTypeModel selected = types.first;
  if (types.length > 1) {
    final picked = await showModalBottomSheet<ServiceTypeModel>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: REdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.selectServiceType.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              12.height,
              ...types.map(
                (type) => ListTile(
                  title: Text(type.name ?? ''),
                  onTap: () => Navigator.of(sheetContext).pop(type),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    selected = picked;
  }

  if (!selected.isEnabled) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.serviceUnavailable.tr())),
    );
    return;
  }

  if (!context.mounted) return;

  final offering = model.offeringForServiceType(selected.id);
  final isCrane = isMobileOnlyServiceCategory(selected.categoryCode);

  if (isCrane || offering?.offeringMode == ProviderOfferingMode.mobile) {
    context.pushNamed(
      Routes.createServiceOrder,
      extra: CreateServiceOrderArgs(
        provider: model,
        serviceTypeId: selected.id,
        visitType: ServiceOrderVisitType.mobileOnSite,
      ),
    );
    return;
  }

  await showProviderVisitChoiceSheet(
    context,
    provider: model,
    serviceType: selected,
    offering: offering,
  );
}
