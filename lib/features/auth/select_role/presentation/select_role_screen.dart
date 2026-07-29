import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/features/auth/register/data/model/register_options.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/auth/register/presentation/cubit/register_cubit.dart';

import '../../../../core/app_config/app_icons.dart';
import '../../../../core/app_config/app_strings.dart';
import '../../../../core/app_config/prefs_keys.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/helpers/messages.dart';
import '../../../../core/helpers/shared_pref_local_storage.dart';
import '../../../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../../../../core/widgets/buttons/back_button.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/texts/clickable_text_widget.dart';
import '../../../../core/app_config/app_colors.dart';
import '../../widgets/auth_header_widget.dart';
import '../widgets/role_list_tile.dart';

class SelectRoleScreen extends StatefulWidget {
  final RegisterOptions? options;
  const SelectRoleScreen({
    super.key,
    this.options,
  });

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  UserRole? _role;

  void _goBack(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.goNamed(Routes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterCubit>(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goBack(context);
        },
        child: Scaffold(
        body: SafeArea(
          child: Builder(builder: (context) {
          return BlocListener<RegisterCubit, RegisterState>(
            listenWhen: (previous, current) =>
                current is RegisterLoadingState ||
                current is RegisterSuccessState ||
                current is RegisterErrorState,
            listener: (context, state) async {
              if (state is RegisterLoadingState) {
                AppMessages.showLoading(context);
                return;
              }

              if (Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              if (state is RegisterSuccessState) {
                final isProvider = _role == UserRole.provider;
                await getIt<SharedPref>().set(
                  key: PrefsKeys.isProviderAccount,
                  value: isProvider,
                );
                if (!state.response.requiresApproval) {
                  context.read<BottomNavigationCubit>().isProvider =
                      isProvider;
                }

                if (isProvider &&
                    state.response.requiresApproval &&
                    context.mounted) {
                  await showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title:
                          Text(AppStrings.providerPendingApprovalTitle.tr()),
                      content: Text(
                        state.response.message ??
                            AppStrings.providerPendingApprovalBody.tr(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(AppStrings.continueKey.tr()),
                        ),
                      ],
                    ),
                  );
                } else {
                  AppMessages.showSuccess(
                    context,
                    state.response.message ?? AppStrings.signUp.tr(),
                  );
                }

                if (context.mounted) {
                  context.goNamed(
                    Routes.login,
                    extra: isProvider,
                  );
                }
                return;
              }

              if (state is RegisterErrorState) {
                AppMessages.showError(
                  context,
                  state.error,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16).r,
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: CustomBackButton(
                      onPressed: () => _goBack(context),
                    ),
                  ),
                  24.height,
                  Center(
                    child: AuthHeaderWidget(
                      subTitle: AppStrings.chooseAccountType.tr(),
                      title: AppStrings.whoAreYou.tr(),
                    ),
                  ),
                  100.height,
                  RoleTile(
                    title: AppStrings.imProvider.tr(),
                    body: AppStrings.providerDescription.tr(),
                    icon: AppIcons.provider,
                    onTap: () {
                      if (_role == UserRole.provider) return;
                      setState(() {
                        _role = UserRole.provider;
                      });
                    },
                    role: UserRole.provider,
                    value: _role,
                  ),
                  16.height,
                  RoleTile(
                    title: AppStrings.imClient.tr(),
                    body: AppStrings.clientDescription.tr(),
                    icon: AppIcons.client,
                    onTap: () {
                      if (_role == UserRole.client) return;
                      setState(() {
                        _role = UserRole.client;
                      });
                    },
                    role: UserRole.client,
                    value: _role,
                  ),
                  const Spacer(
                    flex: 4,
                  ),
                  if (_role != null)
                    CustomButton.filled(
                      isBackgroundGradient: false,
                      text: AppStrings.continueKey.tr(),
                      onTap: () => _submit(context),
                    ),
                  16.height,
                  Center(
                    child: ClickableTextWidget(
                      textStyle: Theme.of(context).textTheme.labelSmall,
                      clickableTextStyle: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(
                            color: AppColors.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryColor,
                          ),
                      text: '  ${AppStrings.alreadyHaveAccount.tr()}  ',
                      clickableText: AppStrings.login.tr(),
                      onTap: () => context.goNamed(
                        Routes.login,
                        extra: _role == UserRole.provider,
                      ),
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  SizedBox(height: context.safeBottomInset),
                ],
              ),
            ),
          );
        }),
        ),
      ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_role == null || widget.options == null) return;

    if (_role == UserRole.client) {
      context.goNamed(Routes.guestMap);
      return;
    }

    if (_role == UserRole.provider) {
      context.pushNamed(
        Routes.providerRegisterSteps,
        extra: widget.options,
      );
    }
  }
}
