import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';
import 'package:taal/core/widgets/otp/phone_otp_verification_section.dart';

class ClientPhoneLoginFields extends StatelessWidget {
  const ClientPhoneLoginFields({
    super.key,
    required this.phoneController,
    required this.otpController,
    required this.otpFocusNode,
    required this.showOtpSection,
    required this.onSendOtp,
  });

  final TextEditingController phoneController;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final bool showOtpSection;
  final PhoneOtpSender onSendOtp;

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
          controller: phoneController,
          label: AppStrings.phone.tr(),
          hint: '07XXXXXXXXX',
          keyboardType: TextInputType.phone,
          validator: CustomValidators.validatePhone,
          readOnly: showOtpSection,
        ),
        if (showOtpSection) ...[
          20.height,
          PhoneOtpVerificationSection(
            phone: phoneController.text.trim(),
            otpController: otpController,
            otpFocusNode: otpFocusNode,
            onSendOtp: onSendOtp,
          ),
        ],
      ],
    );
  }
}
