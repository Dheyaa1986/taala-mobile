import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/extensions.dart';
import 'package:taal/core/widgets/avatars/photo_avatar.dart';
import 'package:taal/features/auth/register/presentation/widgets/phone_field.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/countries/data/model/country_model.dart';
import '../../../../../core/countries/presentation/cubit/countries_cubit.dart';
import '../../../../../core/helpers/messages.dart';
import '../../../../../core/helpers/phone_helper.dart';
import '../../../../../core/validations/validators.dart';
import '../../../../../core/widgets/bottom_sheets/image_sheet.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../../../core/widgets/fields/password_field.dart';
import '../../../../../core/widgets/otp/phone_otp_verification_section.dart';
import '../../../../../core/widgets/texts/clickable_text_widget.dart';
import 'package:taal/features/guest/data/repository/guest_otp_repository.dart';
import '../../../widgets/auth_header_widget.dart';
import '../../data/model/register_options.dart';
import '../cubit/register_cubit.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(),
      _emailController = TextEditingController(),
      _phoneController = TextEditingController(),
      _passwordController = TextEditingController(),
      _confirmController = TextEditingController(),
      _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  final _otpRepository = GuestOtpRepository();
  bool _providerOtpSent = false;
  File? _image;

  CountryModel? _country;

  void _register() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_providerOtpSent) {
      AppMessages.showError(context, AppStrings.sendOtpFirst.tr());
      return;
    }

    if (_otpController.text.trim().length < 6) {
      AppMessages.showError(context, AppStrings.otpCode.tr());
      return;
    }

      final countriesState = context.read<CountriesCubit>().state;
      final selectedCountry = countriesState is CountriesLoaded
          ? countriesState.country
          : _country;

      context.pushNamed(
        Routes.providerRegisterSteps,
        arguments: RegisterOptions(
          countryImageSvg: selectedCountry?.flagSvg ?? '',
          confirmPassword: _confirmController.text,
          password: _passwordController.text,
          username: _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' '),
          phone: PhoneFormatterHelper.formatPhone(
            _phoneController.text,
            selectedCountry,
          ),
          email: _emailController.text,
          address: '',
          image: _image,
          country: selectedCountry?.name ?? '',
          otp: _otpController.text.trim(),
        ),
      );
  }

  Future<({String? debugOtp, String? error})> _sendProviderOtp(
    String phone,
  ) async {
    final result = await _otpRepository.sendRegistrationOtp(phone);
    return result.fold(
      (error) {
        if (mounted) {
          setState(() => _providerOtpSent = false);
        }
        return (debugOtp: null, error: error.displayMessage);
      },
      (payload) {
        if (mounted) {
          setState(() => _providerOtpSent = true);
        }
        return (debugOtp: payload.debugOtp, error: null);
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          current is RegisterLoadingState ||
          current is RegisterSuccessState ||
          current is RegisterErrorState,
      listener: (context, state) {
        if (state is RegisterLoadingState) {
          AppMessages.showLoading(context);
          return;
        }

        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is RegisterSuccessState) {
          AppMessages.showSuccess(context, state.response.message ?? '');
          context.pop();
          return;
        }

        if (state is RegisterErrorState) {
          AppMessages.showError(
            context,
            state.error,
          );
        }
      },
      child: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  120.height,
                  Center(
                    child: AuthHeaderWidget(
                      subTitle: AppStrings.signupHeaderSubtitle.tr(),
                      title: AppStrings.signUp.tr(),
                    ),
                  ),
                  12.height,
                  Text(
                    AppStrings.providerRegisterOnlyHint.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  20.height,
                  PhotoAvatar(
                    onTap: () {
                      ImagePickerHelper().selectImage(context, (image) {
                        setState(() {
                          _image = image;
                        });
                      });
                    },
                    image: _image,
                  ),
                  8.height,
                  Text(
                    AppStrings.optionalField.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  16.height,
                  CustomTextField(
                    controller: _nameController,
                    label: AppStrings.name.tr(),
                    hint: AppStrings.enterName.tr(),
                    helperText: AppStrings.tripleNameHint.tr(),
                    validator: CustomValidators.validateTripleName,
                  ),
                  20.height,
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    label: AppStrings.email.tr(),
                    hint: AppStrings.enterEmail.tr(),
                    validator: CustomValidators.validateEmail,
                  ),
                  20.height,
                  PhoneField(
                    phoneController: _phoneController,
                    country: _country,
                    isRequired: false,
                  ),
                  20.height,
                  Text(
                    AppStrings.providerPhoneVerifyHint.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  12.height,
                  PhoneOtpVerificationSection(
                    phone: _phoneController.text.trim(),
                    otpController: _otpController,
                    otpFocusNode: _otpFocusNode,
                    onSendOtp: _sendProviderOtp,
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
                      if (password.length < 8) {
                        return AppStrings.passwordLengthValidation.tr();
                      }
                      return null;
                    },
                  ),
                  24.height,

                  PasswordField(
                    controller: _confirmController,
                    label: AppStrings.confirmPassword.tr(),
                    hint: AppStrings.enterConfirmPassword.tr(),
                    validator: (confirmPassword) {
                      if (confirmPassword == null || confirmPassword.isEmpty) {
                        return AppStrings.pleaseEnterYourPassword.tr();
                      }
                      if (confirmPassword.length < 8) {
                        return AppStrings.passwordLengthValidation.tr();
                      }
                      return CustomValidators.validateConfirmPassword(
                          confirmPassword, _passwordController.text);
                    },
                  ),

                  68.height,
                  CustomButton.filled(
                    text: AppStrings.next.tr(),
                    isBackgroundGradient: false,
                    onTap: _register,
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
                      text: "  ${AppStrings.alreadyHaveAccount.tr()}  ",
                      clickableText: AppStrings.login.tr(),
                      onTap: () {
                        context.pushReplacementNamed(Routes.login);
                      },
                    ),
                  ),
                  16.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
