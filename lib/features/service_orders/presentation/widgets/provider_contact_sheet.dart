import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/custom_launcher/custom_launcher.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/cached_network_image/custom_cached_network_image.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/provider/presentation/widgets/sheet_header.dart';
import 'package:taal/features/service_orders/data/repository/service_order_repository.dart';

Future<void> showProviderContactSheet(
  BuildContext context, {
  required ServiceProviderModel provider,
  required String serviceTypeId,
  required String description,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => ProviderContactSheet(
      provider: provider,
      serviceTypeId: serviceTypeId,
      description: description,
    ),
  );
}

class ProviderContactSheet extends StatefulWidget {
  const ProviderContactSheet({
    super.key,
    required this.provider,
    required this.serviceTypeId,
    required this.description,
  });

  final ServiceProviderModel provider;
  final String serviceTypeId;
  final String description;

  @override
  State<ProviderContactSheet> createState() => _ProviderContactSheetState();
}

class _ProviderContactSheetState extends State<ProviderContactSheet> {
  final _ordersRepo = getIt<ServiceOrderRepository>();
  bool _creatingChat = false;

  Future<void> _openChat() async {
    if (_creatingChat) return;
    setState(() => _creatingChat = true);

    final prefs = getIt<SharedPref>();
    final address = await prefs.get(key: PrefsKeys.clientLocationAddress);
    final lat = await prefs.get(key: PrefsKeys.clientLocationLat);
    final lng = await prefs.get(key: PrefsKeys.clientLocationLng);

    final result = await _ordersRepo.createOrder(
      serviceTypeId: widget.serviceTypeId,
      description: widget.description,
      providerId: widget.provider.id,
      clientAddress: address is String ? address : null,
      clientLatitude: lat is String ? double.tryParse(lat) : null,
      clientLongitude: lng is String ? double.tryParse(lng) : null,
    );

    if (!mounted) return;
    setState(() => _creatingChat = false);

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      ),
      (order) {
        Navigator.of(context).pop();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        if (order.id != null) {
          context.pushNamed(
            Routes.serviceOrderDetail,
            pathParameters: {'id': order.id!},
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Padding(
      padding: REdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(title: provider.name ?? ''),
          16.height,
          Row(
            children: [
              CustomCachedNetworkImage(
                url: provider.image,
                radius: 100.r,
                width: 56.w,
                height: 56.h,
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.services.join(', '),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.commentColor,
                      ),
                    ),
                    if (provider.distanceKm != null) ...[
                      6.height,
                      Text(
                        '${provider.distanceKm!.toStringAsFixed(1)} ${AppStrings.distanceKm.tr()}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          20.height,
          Row(
            children: [
              Expanded(
                child: CustomButton.filled(
                  radius: Radius.circular(16.r),
                  text: AppStrings.callNow.tr(),
                  onTap: () => getIt<CustomLauncher>().call(
                    provider.phone ?? '',
                    provider.name ?? '',
                  ),
                ),
              ),
              8.width,
              Expanded(
                child: CustomButton.outlined(
                  radius: Radius.circular(16.r),
                  text: AppStrings.whatsapp.tr(),
                  onTap: () => getIt<CustomLauncher>().openWhatsApp(
                    provider.phone ?? '',
                  ),
                ),
              ),
            ],
          ),
          12.height,
          _creatingChat
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                )
              : CustomButton.filled(
                  text: AppStrings.openChat.tr(),
                  onTap: _openChat,
                  height: 48.h,
                ),
        ],
      ),
    );
  }
}
