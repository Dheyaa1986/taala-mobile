import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/config/routes/routes.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/features/app_info/data/model/app_public_info_model.dart';

class LegalLinksRow extends StatelessWidget {
  const LegalLinksRow({super.key});

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: AppColors.primaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 11.sp,
      decoration: TextDecoration.underline,
    );
    final separatorStyle = TextStyle(
      color: AppColors.commentColor,
      fontSize: 11.sp,
    );

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: separatorStyle,
          children: [
            TextSpan(
              text: AppStrings.termsAndConditions.tr(),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.pushNamed(
                      Routes.legalDocument,
                      extra: LegalDocumentType.terms,
                    ),
            ),
            TextSpan(text: ' • '),
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
    );
  }
}
