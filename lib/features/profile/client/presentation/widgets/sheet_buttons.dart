import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/design_system/components/taala_button.dart';

import '../../../../../core/app_config/app_strings.dart';

class SheetButtons extends StatelessWidget {
  const SheetButtons({super.key, this.title, this.onPressed});
  final String? title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TaalaButton(
            label: title ?? AppStrings.confirm.tr(),
            onPressed: () {
              if (onPressed != null) {
                onPressed!();
              } else {
                context.pop();
              }
            },
          ),
        ),
        8.width,
        Expanded(
          child: TaalaButton(
            label: AppStrings.cancel.tr(),
            variant: TaalaButtonVariant.secondary,
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}
