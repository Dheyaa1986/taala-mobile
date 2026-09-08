import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/countries/data/model/country_model.dart';
import 'package:taal/core/countries/presentation/cubit/countries_cubit.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/phone_helper.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/avatars/photo_avatar.dart';
import 'package:taal/core/widgets/bottom_sheets/image_sheet.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/fields/password_field.dart';
import 'package:taal/features/auth/register/presentation/widgets/phone_field.dart';
import 'package:taal/features/profile/data/models/user_profile_model.dart';
import 'package:taal/features/profile/data/repository/profile_repository.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';

import '../../../custom_sheet.dart';

Future<bool?> showCompleteProfileSheet(
  BuildContext context, {
  required bool required,
  UserProfileModel? profile,
}) {
  final profileCubit = context.read<ProfileCubit>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: !required,
    enableDrag: !required,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => BlocProvider(
      create: (_) => getIt<CountriesCubit>()..getCountries(),
      child: BlocProvider.value(
        value: profileCubit,
        child: CompleteProfileSheet(
          profile: profile,
          required: required,
        ),
      ),
    ),
  );
}

class CompleteProfileSheet extends StatefulWidget {
  const CompleteProfileSheet({
    super.key,
    this.profile,
    required this.required,
  });

  final UserProfileModel? profile;
  final bool required;

  @override
  State<CompleteProfileSheet> createState() => _CompleteProfileSheetState();
}

class _CompleteProfileSheetState extends State<CompleteProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  File? _image;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _emailController =
        TextEditingController(text: widget.profile?.registrationEmail ?? '');
    _phoneController = TextEditingController(text: widget.profile?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.profile?.address ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _formatPhone() {
    final countriesState = context.read<CountriesCubit>().state;
    final selectedCountry = countriesState is CountriesLoaded
        ? countriesState.country
        : null;
    final formattedPhone = PhoneFormatterHelper.formatPhone(
      _phoneController.text,
      selectedCountry,
    );
    if (formattedPhone.trim().isEmpty) {
      return null;
    }
    return formattedPhone;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final formattedPhone = _formatPhone();
    if (formattedPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterPhone.tr())),
      );
      return;
    }

    setState(() => _saving = true);
    final success =
        await context.read<ProfileCubit>().completeClientRegistration(
              name: _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' '),
              email: _emailController.text.trim(),
              phone: formattedPhone,
              password: _passwordController.text,
              address: _addressController.text.trim(),
              image: _image,
            );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      context.pop(true);
    } else {
      final state = context.read<ProfileCubit>().state;
      if (state is ProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: context.safeBottomInset + context.keyboardInset + 20.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsSheetHeader(
                title: AppStrings.completeProfileTitle.tr(),
              ),
              8.height,
              Text(
                widget.required
                    ? AppStrings.completeProfileRequiredHint.tr()
                    : AppStrings.completeProfileOptionalHint.tr(),
                style: TextStyle(fontSize: 13.sp, height: 1.5),
                textAlign: TextAlign.center,
              ),
              16.height,
              PhotoAvatar(
                url: widget.profile?.imageLink,
                size: 88.w,
                isEditing: true,
                onTap: () {
                  ImagePickerHelper().selectImage(context, (image) {
                    setState(() => _image = image);
                  });
                },
                image: _image,
              ),
              16.height,
              CustomTextField(
                controller: _nameController,
                label: AppStrings.name.tr(),
                hint: AppStrings.enterName.tr(),
                helperText: AppStrings.tripleNameHint.tr(),
                validator: CustomValidators.validateTripleName,
              ),
              12.height,
              CustomTextField(
                controller: _emailController,
                label: AppStrings.email.tr(),
                hint: AppStrings.enterEmail.tr(),
                keyboardType: TextInputType.emailAddress,
                validator: CustomValidators.validateEmail,
              ),
              12.height,
              PhoneField(phoneController: _phoneController),
              12.height,
              CustomTextField(
                controller: _addressController,
                label: AppStrings.address.tr(),
                hint: AppStrings.enterAddress.tr(),
                validator: (value) => null,
              ),
              12.height,
              PasswordField(
                controller: _passwordController,
                label: AppStrings.password.tr(),
                hint: AppStrings.enterPassword.tr(),
                validator: CustomValidators.validatePassword,
              ),
              12.height,
              PasswordField(
                controller: _confirmPasswordController,
                label: AppStrings.confirmPassword.tr(),
                hint: AppStrings.confirmYourPassword.tr(),
                validator: (value) => CustomValidators.validateConfirmPassword(
                  _passwordController.text,
                  value,
                ),
              ),
              20.height,
              _saving
                  ? const CircularProgressIndicator()
                  : CustomButton.filled(
                      text: AppStrings.save.tr(),
                      onTap: _save,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientProfileGuard {
  static Future<bool> ensureReadyForNewOrder(BuildContext context) async {
    final result = await getIt<ProfileRepository>().getMyProfile();
    return result.fold(
      (_) => true,
      (profile) async {
        if (!profile.needsProfileCompletion) {
          return true;
        }

        if (!context.mounted) return false;
        final completed = await showCompleteProfileSheet(
          context,
          required: true,
          profile: profile,
        );
        return completed == true;
      },
    );
  }

  static void showDebugOtp(BuildContext context, String? debugOtp) {
    if (debugOtp == null || debugOtp.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppStrings.debugOtp.tr()}: $debugOtp'),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}
