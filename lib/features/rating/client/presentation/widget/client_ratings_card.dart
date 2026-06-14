import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/custom_icon_button.dart';
import 'package:taal/features/rating/client/data/model/client_ratings.dart';
import 'package:taal/features/rating/client/presentation/widget/rate_provider_sheet.dart';
import 'package:taal/features/rating/client/presentation/widget/view_profile.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/custom_launcher/custom_launcher.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/cached_network_image/custom_cached_network_image.dart';
import '../../../../../core/widgets/shimmer/custom_shimmer_widget.dart';
import '../../../../home/client/presentation/widgets/rating_bar.dart';

class ClientRatingsCard extends StatelessWidget {
  const ClientRatingsCard({super.key, required this.model});
  final ClientRatingsModel model;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      elevation: 3,
      shadowColor: const Color(0x269A9A9A),
      child: Container(
          padding: REdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: AppColors.borderColorMain),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              CustomCachedNetworkImage(
                url: model.serviceProviderModel?.image ?? '',
                radius: 100.r,
                width: 64.w,
                height: 64.h,
              ),
              10.width,
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.serviceProviderModel?.name ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              )),
                      6.height,
                      RatingRow(
                        rating: model.rating ?? 0,
                        date: model.date,
                      ),
                    ]),
              ),
            ]),
            _divider(),
            Text(model.comment ?? '',
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.commentColor,
                    )),
            _divider(),
            8.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomIconButton(
                      onTap: () async {
                        await getIt<CustomLauncher>().call(
                          model.serviceProviderModel?.phone ?? '',
                          model.serviceProviderModel?.name ?? '',
                        );
                      },
                      iconSize: 24.r,
                      padding: 12.r,
                      border: Border.all(color: AppColors.iconBorderColor),
                      bgColor: Theme.of(context).scaffoldBackgroundColor,
                      icon: AppIcons.call,
                      shape: BoxShape.circle,
                    ),
                    14.width,
                    CustomIconButton(
                      onTap: () async {
                        await getIt<CustomLauncher>().openWhatsApp(
                          model.serviceProviderModel?.phone ?? '',
                        );
                      },
                      iconSize: 24.r,
                      padding: 12.r,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.iconBorderColor),
                      bgColor: Theme.of(context).scaffoldBackgroundColor,
                      icon: AppIcons.whatsapp,
                    ),
                  ],
                ),
                ViewProfileButton(
                  profileId: model.serviceProviderModel?.id,
                ),
              ],
            ),
          ])),
    );
  }

  _divider() {
    return const Divider(
      height: 32,
      thickness: 1,
      color: AppColors.dividerColor,
    );
  }
}

class ClientRatingsCardLoading extends StatelessWidget {
  const ClientRatingsCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomShimmerWidget(
                height: 64,
                width: 64,
                radius: 100,
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomShimmerWidget(
                      height: 16,
                      width: 120,
                      radius: 4,
                    ),
                    6.height,
                    const CustomShimmerWidget(
                      height: 14,
                      width: 100,
                      radius: 4,
                    ),
                  ],
                ),
              ),
              8.width,
              const CustomShimmerWidget(
                height: 14,
                width: 60,
                radius: 4,
              ),
            ],
          ),
          _divider(),
          const CustomShimmerWidget(
            height: 14,
            width: double.infinity,
            radius: 4,
          ),
          8.height,
          const CustomShimmerWidget(
            height: 14,
            width: double.infinity,
            radius: 4,
          ),
          _divider(),
          8.height,
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomShimmerWidget(
                    height: 32,
                    width: 32,
                    radius: 8,
                  ),
                  SizedBox(width: 14),
                  CustomShimmerWidget(
                    height: 32,
                    width: 32,
                    radius: 8,
                  ),
                ],
              ),
              CustomShimmerWidget(
                height: 32,
                width: 100,
                radius: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 32,
      thickness: 1,
      color: AppColors.dividerColor,
    );
  }
}
