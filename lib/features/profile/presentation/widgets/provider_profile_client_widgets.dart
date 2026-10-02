import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/home/client/data/model/service_provider_model/service_provider_model.dart';
import 'package:taal/features/home/client/presentation/utils/start_provider_service_order.dart';
import 'package:taal/features/home/client/presentation/widgets/rating_bar.dart';
import 'package:taal/features/profile/data/models/portfolio_model.dart';
import 'package:taal/features/profile/presentation/cubit/provider_profile_cubit.dart';
import 'package:taal/features/profile/presentation/widgets/portfolio_list_section.dart';
import 'package:taal/features/profile/presentation/widgets/services_list.dart';
import 'package:taal/features/rating/client/presentation/widget/rate_provider_sheet.dart';

import '../../../../core/app_config/app_strings.dart';

class ProviderProfileClientWidgets extends StatelessWidget {
  const ProviderProfileClientWidgets({
    super.key,
    required this.provider,
  });

  final ServiceProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final services = provider.services;

    return Column(
      children: [
        if (services.isNotEmpty)
          Text(
            services.join(' • '),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textSecondary,
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
              child: TaalaButton(
                label: AppStrings.callNow.tr(),
                height: 44,
                onPressed: () => startProviderServiceOrder(
                  context,
                  provider,
                  silentIfGuest: true,
                ),
              ),
            ),
            8.width,
            Expanded(
              child: TaalaButton(
                label: AppStrings.whatsapp.tr(),
                variant: TaalaButtonVariant.secondary,
                height: 44,
                onPressed: () => startProviderServiceOrder(
                  context,
                  provider,
                  silentIfGuest: true,
                ),
              ),
            ),
          ],
        ),
        8.height,
        TaalaButton(
          label: AppStrings.openChat.tr(),
          height: 44,
          onPressed: () => startProviderServiceOrder(
            context,
            provider,
            silentIfGuest: true,
          ),
        ),
        12.height,
        TaalaButton(
          label: AppStrings.rateProvider.tr(),
          height: 44,
          onPressed: () {
            showRateProviderSheet(
              context,
              providerId: provider.id ?? '',
              providerName: provider.name ?? '',
              onRated: () =>
                  context.read<ProviderProfileCubit>().refresh(),
            );
          },
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
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
