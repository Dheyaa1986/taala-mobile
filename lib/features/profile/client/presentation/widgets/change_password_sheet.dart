import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/app_config/prefs_keys.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/helpers/messages.dart';
import 'package:taal/core/helpers/secure_local_storage.dart';
import 'package:taal/core/widgets/fields/password_field.dart';
import 'package:taal/features/profile/client/data/repository/client_settings_repository.dart';
import 'package:taal/features/profile/client/presentation/widgets/sheet_buttons.dart';

import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/validations/validators.dart';
import '../../../custom_sheet.dart';

Future showChangePasswordSheet(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: const ChangePasswordSheet(),
    ),
  );
}

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ClientSettingsRepository();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    AppMessages.showLoading(context);

    final result = await _repository.changePassword(
      oldPassword: _oldPasswordController.text,
      password: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;
    context.pop();
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => AppMessages.showError(context, failure.message),
      (response) async {
        await SecureLocalStorage.write(
          PrefsKeys.password,
          _newPasswordController.text,
        );
        if (!mounted) return;
        AppMessages.showSuccess(
          context,
          response.message?.isNotEmpty == true
              ? response.message!
              : AppStrings.changePassword.tr(),
        );
        context.pop();
      },
    );
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                16.height,
                PasswordField(
                  controller: _oldPasswordController,
                  label: AppStrings.oldPassword.tr(),
                  hint: AppStrings.enterOldPassword.tr(),
                  validator: CustomValidators.validatePassword,
                ),
                20.height,
                PasswordField(
                  controller: _newPasswordController,
                  label: AppStrings.newPassword.tr(),
                  hint: AppStrings.enterNewPassword.tr(),
                  validator: CustomValidators.validatePassword,
                ),
                20.height,
                PasswordField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPassword.tr(),
                  hint: AppStrings.confirmYourPassword.tr(),
                  validator: (value) => CustomValidators.validateConfirmPassword(
                    _newPasswordController.text,
                    value,
                  ),
                ),
                20.height,
                SheetButtons(
                  title: AppStrings.confirm.tr(),
                  onPressed: _isSubmitting ? () {} : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
