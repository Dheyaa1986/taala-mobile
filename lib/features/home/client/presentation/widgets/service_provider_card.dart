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
import '../../../../rating/client/presentation/widget/view_profile.dart';
import '../../data/model/service_provider_model/service_provider_model.dart';

class ServiceProviderCard extends StatelessWidget {
  const ServiceProviderCard({super.key, required this.model});
  final ServiceProviderModel model;
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
                Text(model.services?.join(', ') ?? '',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        )),
                4.height,
                RatingRow(
                    rating: model.rate ?? 0,
                    totalRatings: model.totalRatings ?? 0),
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
                                    '${x.governance?.name}, ${x.city?.name}' ??
                                    '')
                                .join('- ') ??
                            '',
                        style:
                            Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                )),
                  ],
                ),
                10.height,
                ViewMapButton(
                  lat: model.lat,
                  long: model.lng,
                  name: '${model.address}',
                ),
              ]),
            ),
            8.width,
            ViewProfileButton(
              profileId: model.id,

            )
          ]),
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
        ]),
      ),
    );
  }
}
