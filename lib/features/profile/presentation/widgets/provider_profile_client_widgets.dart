import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/countries/presentation/widgets/countries_widget.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/presentation/widgets/rating_bar.dart';
import 'package:taal/features/profile/presentation/widgets/portfolio_card.dart';
import 'package:taal/features/profile/presentation/widgets/services_list.dart';
import 'package:taal/features/rating/client/presentation/widget/rate_provider_sheet.dart';

import '../../../../core/app_config/app_colors.dart';
import '../../../../core/app_config/app_icons.dart';
import '../../../../core/app_config/app_strings.dart';
import '../../../../core/custom_launcher/custom_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/buttons/custom_icon_button.dart';
import '../../data/models/portfolio_model.dart';

class ProviderProfileClientWidgets extends StatelessWidget {
  const ProviderProfileClientWidgets({super.key, required this.services});

  final List<String> services;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Providers Service',
          style: Theme.of(context)
              .textTheme
              .headlineLarge!
              .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400),
        ),
        8.height,
        RatingRow(
          rating: 4.5,
          totalRatings: 10,
          size: 14.r,
        ),
        16.height,
        Row(
          children: [
            Expanded(
              child: CustomButton.filled(
                radius: Radius.circular(12.r),
                text: AppStrings.rateProvider.tr(),
                onTap: () {
                  showRateProviderSheet(context);
                },
              ),
            ),
            16.width,
            Row(
              children: [
                CustomIconButton(
                  onTap: () async {
                     await getIt<CustomLauncher>().openWhatsApp('+20111111111');
                  },
                  iconSize: 24.r,
                  padding: 12.r,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.iconBorderColor),
                  bgColor: Theme.of(context).scaffoldBackgroundColor,
                  icon: AppIcons.whatsapp,
                ),
                14.width,
                CustomIconButton(
                  onTap: () async {
                    await getIt<CustomLauncher>().call('+20111111111', 'Provider Name');
                  },
                  iconSize: 24.r,
                  padding: 12.r,
                  border: Border.all(color: AppColors.iconBorderColor),
                  bgColor: Theme.of(context).scaffoldBackgroundColor,
                  icon: AppIcons.call,
                  shape: BoxShape.circle,
                ),
              ],
            )
          ],
        ),
        32.height,
        ServicesList(
          services: services,
        ),
        Row(
          children: [
            Text(
              AppStrings.portfolio.tr(),
              style: TextStyle(
                color: AppColors.greyTitle,
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        16.height,
        SizedBox(
          height: 239.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (_, index) => SizedBox(
              width: 280.w,
              child: PortfolioCard(
                portfolio: PortfolioModel(
                  id: "$index",
                  name: "Portfolio Item $index",
                  description:
                      "Etiam eu lorem lectus. Cras blandit at elit id blandit. Morbi fibus euismod tincidunt blandit at elit id.Etiam eu lorem lect.",
                  images: [
                    "https://picsum.photos/200/300?random=$index",
                  ],
                ),
              ),
            ),
            separatorBuilder: (_, __) => 8.height,
          ),
        ),
        30.height,
      ],
    );
  }
}
