import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/features/auth/register/presentation/cubit/register_cubit.dart';

import '../../../../core/app_config/app_icons.dart';
import '../../../../core/app_config/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/helpers/messages.dart';
import '../../../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../register/data/model/register_options.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterCubit>(),
      child: Scaffold(
        body: Builder(builder: (context) {
          return BlocListener<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is RegisterLoadingState) {
                AppMessages.showLoading(context);
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                if (state is RegisterSuccessState) {}
                if (state is RegisterErrorState) {
                  AppMessages.showError(
                    context,
                    state.error.tr(),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16).r,
              child: Column(
                children: [
                  60.height,
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
                  const Spacer(
                    flex: 1,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_role == null) return;
    context.read<BottomNavigationCubit>().isProvider =
        _role == UserRole.provider;
    context.go(Routes.home);
  }
}
