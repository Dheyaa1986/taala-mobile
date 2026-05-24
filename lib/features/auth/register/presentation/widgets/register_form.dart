import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';

import 'package:taal/core/helpers/extensions.dart';
import 'package:taal/core/widgets/avatars/photo_avatar.dart';
import 'package:taal/features/auth/register/presentation/widgets/phone_field.dart';
import '../../../../../config/routes/routes.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_icons.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../../core/countries/data/model/country_model.dart';
import '../../../../../core/countries/presentation/cubit/countries_cubit.dart';
import '../../../../../core/countries/presentation/widgets/countries_widget.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/helpers/messages.dart';
import '../../../../../core/helpers/phone_helper.dart';
import '../../../../../core/validations/validators.dart';
import '../../../../../core/widgets/bottom_sheets/custom_bottom_sheet.dart';
import '../../../../../core/widgets/bottom_sheets/image_sheet.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../../../core/widgets/fields/password_field.dart';
import '../../../../../core/widgets/svg_image/svg_image_widget.dart';
import '../../../../../core/widgets/texts/clickable_text_widget.dart';
import '../../../../../core/widgets/texts/header_text.dart';
import '../../../login/presentation/widgets/custom_divider.dart';
import '../../../widgets/auth_header_widget.dart';
import '../../data/model/register_options.dart';
import '../cubit/register_cubit.dart';
import '../screens/register_screen.dart';

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
      _addressController = TextEditingController(),
      _passwordController = TextEditingController(),
      _confirmController = TextEditingController();
  File? _image;

  CountryModel? _country;

  _register() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_image == null) {
      AppMessages.showError(context, AppStrings.pleaseSelectAnImage.tr());
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.pushNamed(
        Routes.selectRoleScreen,
        arguments: RegisterOptions(
          countryImageSvg: _country?.flagSvg ?? '',
          confirmPassword: _confirmController.text,
          password: _passwordController.text,
          username: _nameController.text,
          phone:
              PhoneFormatterHelper.formatPhone(_phoneController.text, _country),
          email: _emailController.text,
          address: _addressController.text,
          image: _image!,
          country: _country?.name ?? '',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterLoadingState) {
          AppMessages.showLoading(context);
        } else if (state is RegisterSuccessState) {
          AppMessages.showSuccess(context, state.response.message ?? '');
          context.pop();
        } else if (state is RegisterErrorState) {
          context.pop();
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
                16.height,
                CustomTextField(
                  controller: _nameController,
                  label: AppStrings.name.tr(),
                  hint: AppStrings.enterName.tr(),
                  validator: CustomValidators.validateEmpty,
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
                ),
                20.height,
                CustomTextField(
                  keyboardType: TextInputType.text,
                  controller: _addressController,
                  label: AppStrings.address.tr(),
                  hint: AppStrings.enterAddress.tr(),
                  validator: CustomValidators.validateEmpty,
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
                    return null;
                  },
                ),
                24.height,
                PasswordField(
                  controller: _confirmController,
                  label: AppStrings.confirmPassword.tr(),
                  hint: AppStrings.enterConfirmPassword.tr(),
                  validator: (p0) {
                    return CustomValidators.validateConfirmPassword(
                        p0, _passwordController.text);
                  },
                ),
                68.height,
                // const Spacer(),
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
