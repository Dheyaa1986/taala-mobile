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
import '../../../../core/di/service_locator.dart';
import '../../../../core/helpers/auth_session_helper.dart';
import '../../../../core/helpers/messages.dart';
import '../../../../core/widgets/buttons/back_button.dart';
import '../../../../design_system/components/taala_button.dart';
import '../../../../design_system/theme/taala_tokens.dart';
import '../../../../core/widgets/texts/clickable_text_widget.dart';
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
                return;
              }

              AppMessages.hideLoading();

              if (state is RegisterSuccessState) {
                await AuthSessionHelper.goToLoginAfterRegistration(
                  isProvider: _role == UserRole.provider,
                  loginIdentifier: widget.options?.phone,
                );
                return;
              }

              if (state is RegisterErrorState) {
                if (AuthSessionHelper.isExistingAccountError(state.error)) {
                  await AuthSessionHelper.goToLoginAfterRegistration(
                    isProvider: _role == UserRole.provider,
                    loginIdentifier: widget.options?.phone,
                  );
                  return;
                }
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
                    TaalaButton(
                      label: AppStrings.continueKey.tr(),
                      onPressed: () => _submit(context),
                    ),
                  16.height,
                  Center(
                    child: ClickableTextWidget(
                      textStyle: Theme.of(context).textTheme.labelSmall,
                      clickableTextStyle: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(
                            color: TaalaTokens.of(context).primary,
                            decoration: TextDecoration.underline,
                            decorationColor: TaalaTokens.of(context).primary,
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
