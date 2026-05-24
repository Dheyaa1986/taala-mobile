import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/fields/password_field.dart';
import 'package:taal/features/profile/client/presentation/widgets/sheet_buttons.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/validations/validators.dart';
import '../../../../../core/widgets/avatars/photo_avatar.dart';
import '../../../../../core/widgets/bottom_sheets/image_sheet.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../custom_sheet.dart';

Future showChangePasswordSheet(BuildContext context) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const ChangePasswordSheet(),
  );
}

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final formKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsSheetHeader(title: AppStrings.changePassword.tr()),
          Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  16.height,
                  PasswordField(
                    controller: oldPasswordController,
                    label: AppStrings.oldPassword.tr(),
                    hint: AppStrings.enterOldPassword.tr(),
                    validator: CustomValidators.validatePassword,
                  ),
                  20.height,
                  PasswordField(

                    controller: newPasswordController,
                    label: AppStrings.newPassword.tr(),
                    hint: AppStrings.enterNewPassword.tr(),
                    validator: CustomValidators.validatePassword,
                  ),
                  20.height,
                  PasswordField(


                    controller: confirmPasswordController,
                    label: AppStrings.confirmPassword.tr(),
                    hint: AppStrings.confirmYourPassword.tr(),
                    validator: (p0) {
                      return CustomValidators.validateConfirmPassword(
                          newPasswordController.text, p0);
                    },
                  ),
                  20.height,
                  SheetButtons(
                    title: AppStrings.confirm.tr(),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
