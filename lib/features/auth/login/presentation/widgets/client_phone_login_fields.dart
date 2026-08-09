import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/validations/validators.dart';
import 'package:taal/core/widgets/fields/custom_text_field.dart';

class ClientPhoneLoginFields extends StatelessWidget {
  const ClientPhoneLoginFields({
    super.key,
    required this.phoneController,
  });

  final TextEditingController phoneController;

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
        ),
      ],
    );
  }
}
