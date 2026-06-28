import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/presentation/widgets/rating_bar.dart';
import 'package:taal/features/profile/data/models/portfolio_model.dart';
import 'package:taal/features/profile/presentation/cubit/provider_profile_cubit.dart';
import 'package:taal/features/profile/presentation/widgets/portfolio_list_section.dart';
import 'package:taal/features/profile/presentation/widgets/services_list.dart';
import 'package:taal/features/rating/client/presentation/widget/rate_provider_sheet.dart';

import '../../../../core/app_config/app_colors.dart';
import '../../../../core/app_config/app_icons.dart';
import '../../../../core/app_config/app_strings.dart';
import '../../../../core/custom_launcher/custom_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/buttons/custom_icon_button.dart';

class ProviderProfileClientWidgets extends StatelessWidget {
  const ProviderProfileClientWidgets({
    super.key,
    required this.provider,
  });

  final ServiceProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final services = provider.services;
    final phone = provider.phone ?? '';

    return Column(
      children: [
        if (services.isNotEmpty)
          Text(
            services.join(' • '),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
          ),
        8.height,
        RatingRow(
          rating: provider.rate ?? 0,
          totalRatings: provider.totalRatings ?? 0,
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
                  showRateProviderSheet(
                    context,
                    providerId: provider.id ?? '',
                    providerName: provider.name ?? '',
                    onRated: () =>
                        context.read<ProviderProfileCubit>().refresh(),
                  );
                },
              ),
            ),
            if (phone.isNotEmpty) ...[
              16.width,
              Row(
                children: [
                  CustomIconButton(
                    onTap: () async {
                      await getIt<CustomLauncher>().openWhatsApp(phone);
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
                      await getIt<CustomLauncher>().call(
                        phone,
                        provider.name ?? '',
                      );
                    },
                    iconSize: 24.r,
                    padding: 12.r,
                    border: Border.all(color: AppColors.iconBorderColor),
                    bgColor: Theme.of(context).scaffoldBackgroundColor,
                    icon: AppIcons.call,
                    shape: BoxShape.circle,
                  ),
                ],
              ),
            ],
          ],
        ),
        32.height,
        if (services.isNotEmpty) ...[
          ServicesList(services: services),
          16.height,
        ],
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
        PortfolioListSection(
          portfolios: provider.portfolios,
          horizontal: true,
        ),
        30.height,
      ],
    );
  }
}

Future<void> confirmDeletePortfolio(
  BuildContext context,
  PortfolioModel portfolio,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppStrings.deletePortfolio.tr()),
      content: Text(AppStrings.deletePortfolioConfirm.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(AppStrings.cancel.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            AppStrings.delete.tr(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  EasyLoading.show(status: AppStrings.loading.tr());
  final error = await context
      .read<ProviderProfileCubit>()
      .deletePortfolio(portfolio.id);
  EasyLoading.dismiss();

  if (!context.mounted) return;
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}
