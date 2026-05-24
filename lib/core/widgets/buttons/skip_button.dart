import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';
import '../texts/clickable_text_widget.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({super.key,required this.onTap});
final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
      child: ClickableTextWidget(
        clickableTextStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: AppColors.lightGreyText,
        ),
        text: '',

        clickableText: AppStrings.skipKey.tr(),
        onTap: onTap,
      ),
    );
  }
}
