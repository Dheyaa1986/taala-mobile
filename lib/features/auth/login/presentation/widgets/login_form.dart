import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:taal/core/extensions/space_extension.dart';

import 'package:taal/core/helpers/extensions.dart';

import 'package:taal/core/helpers/phone_helper.dart';
import 'package:taal/core/validations/validators.dart';

import '../../../../../config/routes/routes.dart';

import '../../../../../core/app_config/app_icons.dart';

import '../../../../../core/app_config/app_strings.dart';

import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/alerts/push_notification_service.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/extensions/device_insets_extension.dart';
import '../../../../../core/helpers/messages.dart';

import '../../../../../core/helpers/auth_session_helper.dart';
import '../../../../../core/helpers/biometric_auth.dart';
import '../../../../../core/helpers/guest_session_helper.dart';
import '../biometric_enrollment.dart';
import 'device_key_button.dart';
import '../../../../../core/helpers/secure_local_storage.dart';

import '../../../../../core/helpers/shared_pref_local_storage.dart';

import '../../../../../core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';

import '../../../../../design_system/components/taala_button.dart';
import '../../../../../design_system/theme/taala_tokens.dart';

import '../../../../../core/widgets/fields/custom_text_field.dart';

import '../../../../../core/widgets/fields/password_field.dart';

import '../../../../../core/widgets/texts/clickable_text_widget.dart';

import '../../../select_role/widgets/role_list_tile.dart';

import '../../../widgets/auth_header_widget.dart';

import '../cubit/login_cubit/login_cubit.dart';

class LoginForm extends StatefulWidget {
  final bool? initialIsProvider;
  final bool hideHeaderLanguage;

  const LoginForm({super.key, this.initialIsProvider, this.hideHeaderLanguage = false});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _identifierController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  UserRole? _role;
  bool _showDeviceKey = false;

  @override
  void initState() {
    super.initState();
    _resolveInitialRole();
    addPostFrameCallBack();
    _passwordController = TextEditingController();
    _identifierController = TextEditingController();
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
      _identifierController.text =
          await SecureLocalStorage.read(PrefsKeys.mailOrPhone) ?? '';
      await SecureLocalStorage.delete(PrefsKeys.password);
      final showKey = await BiometricAuth.isEnabled() &&
          await BiometricAuth.canUseDeviceKey() &&
          await AuthSessionHelper.hasActiveSession();
      if (mounted) setState(() => _showDeviceKey = showKey);
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginLoading) {
          AppMessages.showLoading(context);
        } else {
          context.pop();

          if (state is LoginSuccess) {
            final isProvider = _role == UserRole.provider;
            context.read<BottomNavigationCubit>().isProvider = isProvider;
            PushNotificationService.instance.syncTokenIfLoggedIn();
            await BiometricEnrollment.handleAfterPasswordLogin(context);
            if (!context.mounted) return;
            await AuthSessionHelper.openAuthenticatedApp(context);
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
                      if (_role != null) ...[
                        CustomTextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _identifierController,
                          label: AppStrings.emailOrPhone.tr(),
                          hint: AppStrings.enterEmailOrPhone.tr(),
                          validator: CustomValidators.validateEmailOrPhone,
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
                      ],
                      20.height,
                      if (widget.initialIsProvider == null) ...[
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            AppStrings.chooseAccountType.tr(),
                            style: Theme.of(context).textTheme.labelMedium,
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
                      ],
                      14.height,
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  if (_showDeviceKey) ...[
                    DeviceKeyButton(onPressed: _openDeviceKey),
                    12.width,
                  ],
                  Expanded(
                    child: TaalaButton(
                      label: AppStrings.login.tr(),
                      onPressed: _login,
                    ),
                  ),
                ],
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
                            color: TaalaTokens.of(context).primary,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1,
                            decorationColor:
                                TaalaTokens.of(context).primary),
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
              else if (_role == UserRole.client) ...[
                Center(
                  child: ClickableTextWidget(
                    textStyle: Theme.of(context).textTheme.labelSmall,
                    clickableTextStyle: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(
                            color: TaalaTokens.of(context).primary,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1,
                            decorationColor:
                                TaalaTokens.of(context).primary),
                    text: "  ${AppStrings.dontHaveAccount.tr()}  ",
                    clickableText: AppStrings.register.tr(),
                    onTap: () {
                      context.pushReplacementNamed(Routes.register);
                    },
                  ),
                ),
                if (!_showDeviceKey) ...[
                  12.height,
                  Center(
                    child: TextButton(
                      onPressed: _browseAsGuest,
                      child: Text(
                        AppStrings.browseAsGuest.tr(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: TaalaTokens.of(context).primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ],
              SizedBox(height: context.safeBottomInset + 16.h),
            ],
          ),
        ),
      ),
    );
  }

  String _normalizeLoginIdentifier(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains('@')) {
      return trimmed;
    }
    return PhoneFormatterHelper.normalizeForApi(trimmed);
  }

  void _openDeviceKey() {
    context.go(Routes.biometricUnlock);
  }

  Future<void> _browseAsGuest() async {
    await GuestSessionHelper.startGuestBrowsing();
    if (!mounted) return;
    context.read<BottomNavigationCubit>().isProvider = false;
    context.pushNamedAndRemoveUntil(
      Routes.home,
      predicate: (_) => false,
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

    context.read<LoginCubit>().login(
          email: _normalizeLoginIdentifier(_identifierController.text),
          password: _passwordController.text,
          isProvider: isProvider,
        );
  }
}
