import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/di/service_locator.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/avatars/photo_avatar.dart';
import 'package:taal/core/widgets/bottom_sheets/image_sheet.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/profile/client/presentation/widgets/complete_profile_sheet.dart';
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
    isDismissible: !required,
    enableDrag: !required,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => BlocProvider.value(
      value: profileCubit,
      child: CompleteProfileSheet(
        profile: profile,
        required: required,
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
  File? _image;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final success = await context.read<ProfileCubit>().updateProfile(
          name: _nameController.text.trim(),
          image: _image,
          isProvider: false,
          completeProfile: true,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Form(
        key: _formKey,
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
            20.height,
            _saving
                ? const CircularProgressIndicator()
                : CustomButton.filled(
                    text: AppStrings.save.tr(),
                    onTap: _save,
                  ),
            if (!widget.required) ...[
              12.height,
              CustomButton.outlined(
                text: AppStrings.later.tr(),
                onTap: () => context.pop(false),
              ),
            ],
          ],
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
        if (completed == true) {
          return true;
        }
        return false;
      },
    );
  }

  static Future<void> promptAfterFirstOrder(BuildContext context) async {
    await getIt<ProfileCubit>().loadProfile();
    final state = getIt<ProfileCubit>().state;
    if (state is! ProfileLoaded || !state.profile.needsProfileCompletion) {
      return;
    }
    if (!context.mounted) return;
    await showCompleteProfileSheet(
      context,
      required: false,
      profile: state.profile,
    );
  }

  static void showDebugOtp(BuildContext context, String? debugOtp) {
    if (!kDebugMode || debugOtp == null || debugOtp.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.debugOtp.tr()}: $debugOtp')),
    );
  }
}
