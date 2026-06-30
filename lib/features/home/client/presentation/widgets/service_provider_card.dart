import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:taal/features/home/client/presentation/widgets/rating_bar.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/custom_launcher/custom_launcher.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/buttons/view_map_button.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/features/rating/client/presentation/widget/rate_provider_sheet.dart';
import 'package:taal/features/rating/client/presentation/widget/view_profile.dart';
import '../../../../service_orders/presentation/utils/service_order_chat_launcher.dart';
import '../../data/model/service_provider_model/service_provider_model.dart';
import '../../data/model/service_provider_model/service_type_model.dart';

class ServiceProviderCard extends StatelessWidget {
  const ServiceProviderCard({
    super.key,
    required this.model,
    this.canStartOrder = true,
    this.showQuickActions = false,
    this.onRated,
  });
  final ServiceProviderModel model;
  final bool canStartOrder;
  final bool showQuickActions;
  final VoidCallback? onRated;

  Future<void> _openChat(BuildContext context) async {
    if (!canStartOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.activeOrderBlockingSearch.tr())),
      );
      return;
    }
    final types = model.serviceTypes
        .where((type) => type.id != null && type.id!.isNotEmpty)
        .toList();

    if (types.isEmpty) {
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

    if (!context.mounted) return;
    await ServiceOrderChatLauncher.startChat(
      provider: model,
      serviceTypeId: selected.id!,
      description: AppStrings.chatRequestDefault.tr(),
    );
  }

  void _openProfile(BuildContext context) {
    final profileId = model.id;
    if (profileId == null || profileId.isEmpty) return;
    context.pushNamed(Routes.menu, extra: profileId);
  }

  void _openRate(BuildContext context) {
    final providerId = model.id;
    if (providerId == null || providerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.noProvidersAvailable.tr())),
      );
      return;
    }
    showRateProviderSheet(
      context,
      providerId: providerId,
      providerName: model.name ?? '',
      onRated: onRated,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:  EdgeInsets.zero,
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      elevation: 3,
      shadowColor: const Color(0x269A9A9A),
      child: Container(

        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E5EA), width: 1),

        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomCachedNetworkImage(
              url: model.image,
              radius: 100.r,
              width: 64.w,
              height: 64.h,
            ),
            10.width,
            Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(model.name ?? '',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        )),
                6.height,
                Text(model.services.join(', '),
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        )),
                4.height,
                RatingRow(
                    rating: model.rate ?? 0,
                    totalRatings: model.totalRatings ?? 0),
                if (showQuickActions && model.portfolios.isNotEmpty) ...[
                  8.height,
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 14.r,
                        color: AppColors.primaryColor,
                      ),
                      4.width,
                      Text(
                        AppStrings.portfolioProjectsCount.tr(
                          namedArgs: {
                            'count': '${model.portfolios.length}',
                          },
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (model.distanceKm != null || model.etaMinutes != null) ...[
                  8.height,
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        size: 14.r,
                        color: AppColors.primaryColor,
                      ),
                      4.width,
                      Text(
                        [
                          if (model.distanceKm != null)
                            '${model.distanceKm!.toStringAsFixed(1)} كم',
                          if (model.etaMinutes != null)
                            '• ${model.etaMinutes} دقيقة',
                        ].join(' '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
                8.height,
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.dropDownIconColor,
                      size: 16,
                    ),
                    2.width,
                    Text(
                        model.locations
                            .map((x) =>
                                '${x.governance?.name ?? ''}, ${x.city?.name ?? ''}')
                            .join('- '),
                        style:
                            Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                )),
                  ],
                ),
                10.height,
                ViewMapButton(
                  mapUrl: model.locations.isNotEmpty
                      ? model.locations.first.mapLink
                      : null,
                  lat: model.lat,
                  long: model.lng,
                  name: model.address,
                ),
              ]),
            ),
            if (!showQuickActions) ...[
              8.width,
              ViewProfileButton(
                profileId: model.id,
              ),
            ],
          ]),
          if (showQuickActions) ...[
            12.height,
            Row(
              children: [
                Expanded(
                  child: CustomButton.outlined(
                    radius: Radius.circular(16.r),
                    text: AppStrings.viewProfile.tr(),
                    onTap: () => _openProfile(context),
                  ),
                ),
                8.width,
                Expanded(
                  child: CustomButton.filled(
                    radius: Radius.circular(16.r),
                    text: AppStrings.rateShort.tr(),
                    onTap: () => _openRate(context),
                  ),
                ),
              ],
            ),
          ],
          10.height,
          Row(
            children: [
              Expanded(
                child: CustomButton.filled(
      radius:  Radius.circular(16.r),
                    text: AppStrings.callNow.tr(),
                    onTap: () async {
                      await getIt<CustomLauncher>().call(model.phone??'', model.name??'');
                    }),
              ),
              8.width,
              Expanded(
                child: CustomButton.outlined(
                    radius:  Radius.circular(16.r),
                    text: AppStrings.whatsapp.tr(),
                    onTap: () async {
                      await getIt<CustomLauncher>().openWhatsApp(model.phone??'');
                    }),
              ),
            ],
          ),
          8.height,
          CustomButton.filled(
            radius: Radius.circular(16.r),
            text: AppStrings.openChat.tr(),
            onTap: canStartOrder ? () => _openChat(context) : null,
            enabled: canStartOrder,
          ),
        ]),
      ),
    );
  }
}
