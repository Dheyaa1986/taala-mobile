import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/provider_offering/provider_offering_mode.dart';
import 'package:taal/core/provider_offering/provider_service_offering_model.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_type_model.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';
import 'package:taal/features/service_orders/presentation/models/create_service_order_args.dart';

Future<void> showProviderVisitChoiceSheet(
  BuildContext context, {
  required ServiceProviderModel provider,
  required ServiceTypeModel serviceType,
  ProviderServiceOfferingModel? offering,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => ProviderVisitChoiceSheet(
      provider: provider,
      serviceType: serviceType,
      offering: offering,
    ),
  );
}

class ProviderVisitChoiceSheet extends StatefulWidget {
  const ProviderVisitChoiceSheet({
    super.key,
    required this.provider,
    required this.serviceType,
    this.offering,
  });

  final ServiceProviderModel provider;
  final ServiceTypeModel serviceType;
  final ProviderServiceOfferingModel? offering;

  @override
  State<ProviderVisitChoiceSheet> createState() =>
      _ProviderVisitChoiceSheetState();
}

class _ProviderVisitChoiceSheetState extends State<ProviderVisitChoiceSheet> {
  bool _submitting = false;

  ProviderServiceOfferingModel? get _offering {
    return widget.provider.offeringForServiceType(widget.serviceType.id);
  }

  bool get _supportsVisitShop => _offering?.supportsVisitShop ?? false;

  bool get _supportsMobile =>
      _offering?.supportsMobile ??
      isMobileOnlyServiceCategory(widget.serviceType.categoryCode);

  Future<void> _createVisitShopOrder() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final result = await getIt<ServiceOrderRepository>().createOrder(
      serviceTypeId: widget.serviceType.id!,
      description: AppStrings.visitShopOrderDescription.tr(),
      providerId: widget.provider.id,
      visitType: ServiceOrderVisitType.visitShop,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      },
      (order) {
        Navigator.of(context).pop();
        context.pushNamed(
          Routes.serviceOrderDetail,
          pathParameters: {'id': order.id!},
        );
      },
    );
  }

  void _openMobileOrder() {
    Navigator.of(context).pop();
    context.pushNamed(
      Routes.createServiceOrder,
      extra: CreateServiceOrderArgs(
        provider: widget.provider,
        serviceTypeId: widget.serviceType.id,
        visitType: ServiceOrderVisitType.mobileOnSite,
      ),
    );
  }

  void _openShopOnMap() {
    final shopUrl = _offering?.shopGoogleMapsUrl;
    if (shopUrl != null && shopUrl.isNotEmpty) {
      getIt<CustomLauncher>().openUrl(shopUrl);
      return;
    }
    if (_offering?.shopLatitude != null && _offering?.shopLongitude != null) {
      getIt<CustomLauncher>().openMaps(
        _offering!.shopLatitude!,
        _offering!.shopLongitude!,
        widget.provider.name ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final offering = _offering;

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(title: widget.provider.name ?? ''),
          8.height,
          Text(
            widget.serviceType.name ?? '',
            style: TextStyle(color: tokens.textSecondary, fontSize: 13.sp),
          ),
          16.height,
          if (_supportsVisitShop)
            _ChoiceTile(
              icon: ProviderOfferingMode.fixed.icon,
              title: AppStrings.clientVisitShop.tr(),
              subtitle: offering?.isOpenNow == true
                  ? AppStrings.shopOpenNow.tr()
                  : AppStrings.priceByAgreement.tr(),
              onTap: _submitting ? null : _createVisitShopOrder,
              trailing: IconButton(
                onPressed: _openShopOnMap,
                icon: const Icon(Icons.map_outlined),
              ),
            ),
          if (_supportsVisitShop && _supportsMobile) 12.height,
          if (_supportsMobile)
            _ChoiceTile(
              icon: ProviderOfferingMode.mobile.icon,
              title: AppStrings.clientRequestMobile.tr(),
              subtitle: AppStrings.priceByAgreement.tr(),
              onTap: _openMobileOrder,
            ),
          if (_submitting) ...[
            16.height,
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: REdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32.sp, color: tokens.primary),
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
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
