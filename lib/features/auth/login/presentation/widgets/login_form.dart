import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/extensions.dart';
import 'package:taal/core/validations/validators.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/app_config/prefs_keys.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/helpers/messages.dart';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/helpers/shared_pref_local_storage.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../../../core/widgets/fields/password_field.dart';
import '../../../../../core/widgets/texts/clickable_text_widget.dart';
import '../../../widgets/auth_header_widget.dart';
import '../cubit/login_cubit/login_cubit.dart';

class LoginForm extends StatefulWidget {
  final bool isProvider;
  const LoginForm({super.key, this.isProvider = false});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController _emailController, _passwordController;
  final _formKey = GlobalKey<FormState>();
  late bool _isProvider;

  @override
  void initState() {
    super.initState();
    _isProvider = widget.isProvider;
    addPostFrameCallBack();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
  }

  void addPostFrameCallBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool? rememberMe = getIt<SharedPref>().get(key: PrefsKeys.rememberMe);
      if (rememberMe == true) {
        _passwordController.text =
            await SecureLocalStorage.read(PrefsKeys.password) ?? '';
        _emailController.text =
            await SecureLocalStorage.read(PrefsKeys.mailOrPhone) ?? '';
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
            context.pushNamedAndRemoveUntil(
              Routes.splashScreen,
              predicate: (route) => false,
            );
          } else if (state is LoginError) {
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
                      60.height,
                      Center(
                        child: AuthHeaderWidget(
                          subTitle: AppStrings.loginHeaderSubtitle.tr(),
                          title: AppStrings.login.tr(),
                        ),
                      ),
                      50.height,
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        label: AppStrings.email.tr(),
                        hint: AppStrings.enterEmail.tr(),
                        validator: CustomValidators.validateEmail,
                      ),
                      20.height,
                      PasswordField(
                        controller: _passwordController,
                        label: AppStrings.password.tr(),
                        hint: AppStrings.enterPassword.tr(),
                        validator: (password) {
                          if (password == null || password.isEmpty) {
                            return AppStrings.pleaseEnterYourPassword.tr();
                          }

                          // 🎯 التعديل السحري: استدعاء النص المترجم تلقائياً بناءً على لغة الجهاز
                          if (password.length < 8) {
                            return AppStrings.passwordLengthValidation.tr();
                          }
                          return null;
                        },
                      ),
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
                    context.pushReplacementNamed(Routes.register);
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      context.go(Routes.selectRoleScreen);
    }
  }
}
