import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/buttons/custom_button.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/features/auth/login/presentation/cubit/login_cubit/login_cubit.dart';
import 'package:taal/features/profile/client/presentation/widgets/complete_profile_sheet.dart';

class ClientPhoneLoginFields extends StatefulWidget {
  const ClientPhoneLoginFields({
    super.key,
    required this.phoneController,
    required this.otpController,
  });

  final TextEditingController phoneController;
  final TextEditingController otpController;

  @override
  State<ClientPhoneLoginFields> createState() => _ClientPhoneLoginFieldsState();
}

class _ClientPhoneLoginFieldsState extends State<ClientPhoneLoginFields> {
  bool _otpSent = false;
  bool _sendingOtp = false;
  int _otpCooldown = 0;

  Future<void> _sendOtp() async {
    final phone = widget.phoneController.text.trim();
    if (CustomValidators.validatePhone(phone) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.invalidPhone.tr())),
      );
      return;
    }

    setState(() => _sendingOtp = true);
    final response =
        await context.read<LoginCubit>().sendClientOtp(phone);
    if (!mounted) return;
    setState(() => _sendingOtp = false);

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error!)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.otpSent.tr())),
    );
    ClientProfileGuard.showDebugOtp(context, response.debugOtp);
    setState(() {
      _otpSent = true;
      _otpCooldown = 60;
    });
    _tickOtpCooldown();
  }

  void _tickOtpCooldown() {
    if (_otpCooldown <= 0 || !mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _otpCooldown -= 1);
      if (_otpCooldown > 0) {
        _tickOtpCooldown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.clientPhoneLoginHint.tr(),
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        16.height,
        CustomTextField(
          controller: widget.phoneController,
          label: AppStrings.phone.tr(),
          hint: AppStrings.phone.tr(),
          keyboardType: TextInputType.phone,
          validator: CustomValidators.validatePhone,
        ),
        16.height,
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: widget.otpController,
                label: AppStrings.otpCode.tr(),
                hint: AppStrings.otpCode.tr(),
                keyboardType: TextInputType.number,
                validator: CustomValidators.validateEmpty,
              ),
            ),
            8.width,
            CustomButton.outlined(
              text: _otpCooldown > 0
                  ? '${_otpCooldown}s'
                  : (_otpSent
                      ? AppStrings.resendOtp.tr()
                      : AppStrings.sendOtp.tr()),
              onTap: (_sendingOtp || _otpCooldown > 0) ? null : _sendOtp,
            ),
          ],
        ),
      ],
    );
  }
}
