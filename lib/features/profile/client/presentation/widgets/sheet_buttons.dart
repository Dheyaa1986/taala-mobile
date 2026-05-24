import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';

class SheetButtons extends StatelessWidget {
  const SheetButtons({super.key, this.title, this.onPressed});
  final String? title;
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton.filled(
            text:title?? AppStrings.confirm.tr(),
            onTap: () {
              if (onPressed != null) {
                onPressed!();
              } else {
                context.pop();
              }
    } ,
          ),
        ),
        8.width,
        Expanded(
          child: CustomButton.outlined(
            borderColor: AppColors.primaryColor,
            textColor: AppColors.primaryColor,
            text: AppStrings.cancel.tr(),
            onTap: () => context.pop(),
          ),
        ),
      ],
    );
  }
}
