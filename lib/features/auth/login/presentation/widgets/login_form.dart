import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:taal/core/extensions/space_extension.dart';

import 'package:taal/core/helpers/extensions.dart';

import 'package:taal/core/validations/validators.dart';



import '../../../../../config/routes/routes.dart';

import '../../../../../core/app_config/app_colors.dart';

import '../../../../../core/app_config/app_icons.dart';

import '../../../../../core/app_config/app_strings.dart';

import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/alerts/push_notification_service.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/extensions/device_insets_extension.dart';
import '../../../../../core/helpers/messages.dart';

import '../../../../../core/helpers/secure_local_storage.dart';

import '../../../../../core/helpers/shared_pref_local_storage.dart';

import '../../../../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

import '../../../../../core/widgets/buttons/custom_button.dart';

import '../../../../../core/widgets/fields/custom_text_field.dart';

import '../../../../../core/widgets/fields/password_field.dart';

import '../../../../../core/widgets/texts/clickable_text_widget.dart';

import '../../../select_role/widgets/role_list_tile.dart';

import '../../../widgets/auth_header_widget.dart';

import '../cubit/login_cubit/login_cubit.dart';
import 'client_phone_login_fields.dart';



class LoginForm extends StatefulWidget {

  final bool? initialIsProvider;
  final bool hideHeaderLanguage;

  const LoginForm({super.key, this.initialIsProvider, this.hideHeaderLanguage = false});



  @override

  State<LoginForm> createState() => _LoginFormState();

}



class _LoginFormState extends State<LoginForm> {

  late TextEditingController _emailController,
      _passwordController,
      _phoneController;

  final _formKey = GlobalKey<FormState>();

  UserRole? _role;
  bool _rememberMe = true;



  @override

  void initState() {

    super.initState();

    _resolveInitialRole();

    addPostFrameCallBack();

    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }



  void _resolveInitialRole() {

    if (widget.initialIsProvider != null) {

      _role = widget.initialIsProvider!

          ? UserRole.provider

          : UserRole.client;

      return;

    }

    final saved = getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount);

    if (saved is bool) {
      _role = saved ? UserRole.provider : UserRole.client;
    } else {
      _role = UserRole.client;
    }
  }



  void addPostFrameCallBack() {

    WidgetsBinding.instance.addPostFrameCallback((_) async {

      bool? rememberMe = getIt<SharedPref>().get(key: PrefsKeys.rememberMe);

      if (rememberMe is bool) {
        _rememberMe = rememberMe;
      }

      if (_rememberMe) {

        _passwordController.text =

            await SecureLocalStorage.read(PrefsKeys.password) ?? '';

        _emailController.text =

            await SecureLocalStorage.read(PrefsKeys.mailOrPhone) ?? '';

      }

    });

  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }



  @override

  Widget build(BuildContext context) {

    return BlocListener<LoginCubit, LoginState>(

      listener: (context, state) {

        if (state is LoginLoading) {

          AppMessages.showLoading(context);

        } else {

          context.pop();

          if (state is LoginSuccess) {
            context.read<BottomNavigationCubit>().isProvider =
                _role == UserRole.provider;
            PushNotificationService.instance.syncTokenIfLoggedIn();
            context.pushNamedAndRemoveUntil(
              Routes.home,
              predicate: (_) => false,
            );
          } else if (state is LoginError) {

            AppMessages.showError(context, state.error);

          } else if (state is AccountNotVerified) {

            AppMessages.showError(context, state.error);

          }

        }

      },

      child: Padding(

        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              Expanded(

                child: SingleChildScrollView(

                  physics: const AlwaysScrollableScrollPhysics(),

                  child: Column(

                    children: [

                      40.height,

                      Center(

                        child: AuthHeaderWidget(

                          subTitle: AppStrings.loginHeaderSubtitle.tr(),

                          title: AppStrings.login.tr(),

                          showLanguage: !widget.hideHeaderLanguage,

                        ),

                      ),

                      24.height,

                      if (_role == UserRole.provider) ...[
                        CustomTextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          label: AppStrings.email.tr(),
                          hint: AppStrings.enterEmail.tr(),
                          validator: CustomValidators.validateEmail,
                        ),
                        16.height,
                        PasswordField(
                          controller: _passwordController,
                          label: AppStrings.password.tr(),
                          hint: AppStrings.enterPassword.tr(),
                          validator: (password) {
                            if (password == null || password.isEmpty) {
                              return AppStrings.pleaseEnterYourPassword.tr();
                            }
                            if (password.length < 8) {
                              return AppStrings.passwordLengthValidation.tr();
                            }
                            return null;
                          },
                        ),
                      ] else if (_role == UserRole.client) ...[
                        ClientPhoneLoginFields(
                          phoneController: _phoneController,
                        ),
                      ],

                      20.height,

                      Align(

                        alignment: AlignmentDirectional.centerStart,

                        child: Text(

                          AppStrings.chooseAccountType.tr(),

                          style:

                              Theme.of(context).textTheme.labelMedium?.copyWith(

                                    color: AppColors.lightTText,

                                  ),

                        ),

                      ),

                      12.height,

                      RoleTile(

                        title: AppStrings.imProvider.tr(),

                        body: AppStrings.providerDescription.tr(),

                        icon: AppIcons.provider,

                        onTap: () => setState(() => _role = UserRole.provider),

                        role: UserRole.provider,

                        value: _role,

                      ),

                      10.height,

                      RoleTile(

                        title: AppStrings.imClient.tr(),

                        body: AppStrings.clientDescription.tr(),

                        icon: AppIcons.client,

                        onTap: () => setState(() => _role = UserRole.client),

                        role: UserRole.client,

                        value: _role,

                      ),

                      if (_role == UserRole.provider) ...[
                        14.height,
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: AppColors.primaryColor,
                              onChanged: (value) {
                                setState(() => _rememberMe = value ?? true);
                                context
                                    .read<LoginCubit>()
                                    .toggleRememberMe(_rememberMe);
                              },
                            ),
                            Expanded(
                              child: Text(
                                AppStrings.rememberMe.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: AppColors.lightTText),
                              ),
                            ),
                          ],
                        ),
                      ],

                      14.height,

                    ],

                  ),

                ),

              ),

              CustomButton.filled(

                text: AppStrings.login.tr(),

                isBackgroundGradient: false,

                onTap: _login,

              ),

              16.height,

              if (_role == UserRole.provider)
                Center(
                  child: ClickableTextWidget(
                    textStyle: Theme.of(context).textTheme.labelSmall,
                    clickableTextStyle: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(
                            color: AppColors.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1,
                            decorationColor: AppColors.primaryColor),
                    text: "  ${AppStrings.dontHaveAccount.tr()}  ",
                    clickableText: AppStrings.register.tr(),
                    onTap: () {
                      context.pushReplacementNamed(
                        Routes.register,
                        arguments: true,
                      );
                    },
                  ),
                )
              else if (_role == UserRole.client)
                Padding(
                  padding: REdgeInsets.only(top: 8),
                  child: Text(
                    AppStrings.clientUseGuestMap.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),

              SizedBox(height: context.safeBottomInset + 16.h),

            ],

          ),

        ),

      ),

    );

  }



  void _login() {

    if (_role == null) {

      AppMessages.showError(context, AppStrings.chooseAccountType.tr());

      return;

    }

    if (!_formKey.currentState!.validate()) return;



    FocusManager.instance.primaryFocus?.unfocus();

    final isProvider = _role == UserRole.provider;

    context.read<BottomNavigationCubit>().isProvider = isProvider;

    if (isProvider) {
      context.read<LoginCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            isProvider: true,
            rememberMe: _rememberMe,
          );
      return;
    }

    context.read<LoginCubit>().loginClientByPhone(
          phone: _phoneController.text.trim(),
        );
  }
}


