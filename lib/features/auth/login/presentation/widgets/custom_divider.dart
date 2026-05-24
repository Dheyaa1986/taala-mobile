import 'package:flutter/material.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/font_styles.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: AppColors.dividerColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: FontStyles.textStyle14.copyWith(
              color: AppColors.dividerColor,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: AppColors.dividerColor,
          ),
        ),
      ],
    );
  }
}

class CustomDividerWithoutText extends StatelessWidget {
  final Color? color ;
  final double? thickness ;
  final double? height ;
  const CustomDividerWithoutText({
    super.key,this.color,
    this.thickness,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness:thickness ??  1,
      color:color ??  AppColors.lightGreyTextField,
    );
  }
}