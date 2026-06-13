import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/shared_pref_local_storage.dart';
import 'package:taal/features/profile/client/presentation/widgets/change_password_sheet.dart';
import 'package:taal/features/profile/data/models/user_profile_model.dart';
import 'package:taal/features/profile/presentation/cubit/profile_cubit.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../../../core/helpers/messages.dart';
import '../../../../../core/validations/validators.dart';
import '../../../../../core/widgets/avatars/photo_avatar.dart';
import '../../../../../core/widgets/bottom_sheets/image_sheet.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../custom_sheet.dart';

Future<void> openMyProfileSheet(BuildContext context) async {
  final cubit = context.read<ProfileCubit>();
  UserProfileModel? profile;

  final state = cubit.state;
  if (state is ProfileLoaded) {
    profile = state.profile;
  } else if (state is ProfileUpdating) {
    profile = state.profile;
  } else {
    AppMessages.showLoading(context);
    await cubit.loadProfile();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    final loaded = cubit.state;
    if (loaded is ProfileLoaded) {
      profile = loaded.profile;
    } else if (loaded is ProfileError && context.mounted) {
      AppMessages.showError(context, loaded.message);
      return;
    }
  }

  if (profile != null && context.mounted) {
    await showEditProfileSheet(context, profile: profile);
  }
}

Future showEditProfileSheet(
  BuildContext context, {
  required UserProfileModel profile,
}) async {
  final profileCubit = context.read<ProfileCubit>();
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => BlocProvider.value(
      value: profileCubit,
      child: EditProfileSheet(profile: profile),
    ),
  );
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  File? _image;
  bool _isSaving = false;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.profile.name);
    emailController = TextEditingController(text: widget.profile.email);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final isProvider =
        getIt<SharedPref>().get(key: PrefsKeys.isProviderAccount) == true;

    final success = await context.read<ProfileCubit>().updateProfile(
          name: nameController.text.trim(),
          image: _image,
          isProvider: isProvider,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.pop();
    } else if (context.read<ProfileCubit>().state is ProfileError) {
      AppMessages.showError(
        context,
        (context.read<ProfileCubit>().state as ProfileError).message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsSheetHeader(title: AppStrings.editProfile.tr()),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PhotoAvatar(
                  url: widget.profile.imageLink,
                  size: 100.w,
                  isEditing: true,
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
                  controller: nameController,
                  label: AppStrings.name.tr(),
                  hint: AppStrings.enterName.tr(),
                  validator: CustomValidators.validateEmpty,
                ),
                20.height,
                CustomTextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  label: AppStrings.email.tr(),
                  hint: AppStrings.enterEmail.tr(),
                  enabled: false,
                  validator: CustomValidators.validateEmail,
                ),
                20.height,
                _isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      )
                    : CustomButton(
                        text: AppStrings.save.tr(),
                        onTap: _save,
                      ),
                12.height,
                CustomButton.outlined(
                  text: AppStrings.changePassword.tr(),
                  onTap: () => showChangePasswordSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
