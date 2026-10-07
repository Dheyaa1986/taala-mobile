import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class DeviceKeyButton extends StatelessWidget {
  const DeviceKeyButton({
    super.key,
    required this.onPressed,
    this.size = 52,
  });

  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final side = size.r;
    return SizedBox(
      width: side,
      height: side,
      child: Material(
        color: tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
          side: BorderSide(color: tokens.primary, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
          child: Icon(
            Icons.fingerprint,
            color: tokens.primary,
            size: (size * 0.52).r,
            semanticLabel: AppStrings.biometricUnlockTitle.tr(),
          ),
        ),
      ),
    );
  }
}
