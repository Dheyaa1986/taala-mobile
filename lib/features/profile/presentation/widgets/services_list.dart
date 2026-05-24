import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

import '../../../../core/app_config/app_colors.dart';
import '../../../../core/app_config/app_icons.dart';

class ServicesList extends StatelessWidget {
  const ServicesList({super.key, required this.services});
  final List<String> services;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              AppStrings.services.tr(),
              style: TextStyle(
                color: AppColors.greyTitle,
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        16.height,
        ...services.map(
          (e) => Padding(
            padding: REdgeInsets.only(bottom:  12),
            child: Row(
              children: [
               const SvgImageWidget(image: AppIcons.dot),
                8.width,
                Text(
                  e,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGrey,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
