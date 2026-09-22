import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/components/taala_button.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:taal/features/profile/presentation/cubit/provider_profile_cubit.dart';
import 'package:taal/features/profile/presentation/screens/add_portfolio_screen.dart';
import 'package:taal/features/profile/presentation/widgets/portfolio_list_section.dart';
import 'package:taal/features/profile/presentation/widgets/provider_profile_client_widgets.dart';

import '../../../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

class ProviderPortfolioScreen extends StatefulWidget {
  const ProviderPortfolioScreen({super.key});

  @override
  State<ProviderPortfolioScreen> createState() =>
      _ProviderPortfolioScreenState();
}

class _ProviderPortfolioScreenState extends State<ProviderPortfolioScreen> {
  late final ProviderProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProviderProfileCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    final isProvider =
        context.read<BottomNavigationCubit>().isProvider ?? false;
    String? currentUserId;

    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    } else {
      await context.read<ProfileCubit>().loadProfile();
      if (!mounted) return;
      final refreshed = context.read<ProfileCubit>().state;
      if (refreshed is ProfileLoaded) {
        currentUserId = refreshed.profile.id;
      }
    }

    await _cubit.load(
      currentUserId: currentUserId,
      isProviderAccount: isProvider,
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: CustomAppBar.langAppBar(
          showProfileIcon: true,
          title: AppStrings.portfolio.tr(),
          centerTitle: true,
        ),
        body: BlocBuilder<ProviderProfileCubit, ProviderProfileState>(
          builder: (context, state) {
            if (state is ProviderProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProviderProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: REdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    16.height,
                    TaalaButton(
                      onPressed: _loadProfile,
                      label: AppStrings.retry.tr(),
                    ),
                  ],
                ),
              );
            }

            if (state is! ProviderProfileLoaded &&
                state is! ProviderProfileRefreshing) {
              return const SizedBox.shrink();
            }

            final provider = state is ProviderProfileLoaded
                ? state.provider
                : (state as ProviderProfileRefreshing).provider;

            final tokens = TaalaTokens.of(context);

            return Padding(
              padding: REdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.providerPortfolioSubtitle.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.portfolio.tr(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                        ),
                      ),
                      TaalaButton(
                        label: AppStrings.addNew.tr(),
                        variant: TaalaButtonVariant.text,
                        expanded: false,
                        height: 40,
                        icon: Icon(Icons.add, color: tokens.primary, size: 20.r),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: _cubit,
                              child: const AddPortfolioScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  Expanded(
                    child: SingleChildScrollView(
                      child: PortfolioListSection(
                        portfolios: provider.portfolios,
                        canDelete: true,
                        onDelete: (portfolio) =>
                            confirmDeletePortfolio(context, portfolio),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
