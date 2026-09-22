import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';

class LegalConsentCheckbox extends StatelessWidget {
  const LegalConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final linkStyle = TextStyle(
      color: tokens.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      fontSize: 12.sp,
    );
    final baseStyle = TextStyle(
      color: tokens.textPrimary,
      fontSize: 12.sp,
      height: 1.4,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
          activeColor: tokens.primary,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: RichText(
              text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: '${AppStrings.legalConsentPrefix.tr()} '),
                  TextSpan(
                    text: AppStrings.termsAndConditions.tr(),
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.pushNamed(
                            Routes.legalDocument,
                            extra: LegalDocumentType.terms,
                          ),
                  ),
                  TextSpan(text: ' ${AppStrings.and.tr()} '),
                  TextSpan(
                    text: AppStrings.privacyPolicy.tr(),
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.pushNamed(
                            Routes.legalDocument,
                            extra: LegalDocumentType.privacy,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
