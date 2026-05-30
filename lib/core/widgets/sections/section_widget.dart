import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/app_strings.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final Widget content;
  final TextStyle? titleStyle;
  final double? titleAndContentSpace;
  final String? Function(Object?)? validator;

  final VoidCallback? onSeeAllTap;
  const SectionWidget({
    super.key,
    required this.title,
    required this.content,
    this.onSeeAllTap,
    this.titleStyle,
    this.titleAndContentSpace,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField(
        validator: validator,
        builder: (state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style:
                          titleStyle ?? Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  if (state.hasError) ...[
                    Flexible(
                      child: Text(
                        "${state.errorText!}*",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.errorColor,
                            ),
                      ),
                    ),
                  ],
                  if (onSeeAllTap != null)
                    GestureDetector(
                      onTap: onSeeAllTap,
                      child: Text(
                        AppStrings.seeAll.tr(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 14.sp),
                      ),
                    ),
                ],
              ),
              if (titleAndContentSpace != null) titleAndContentSpace!.height,
              content
            ],
          );
        });
  }
}
