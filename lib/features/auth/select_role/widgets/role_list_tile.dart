import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

import '../../../../core/app_config/app_colors.dart';

enum UserRole {
  client,
  provider,
}

class RoleTile extends StatelessWidget {
  final UserRole role;
  final UserRole? value;
  final VoidCallback onTap;
  final String title, body, icon;
  const RoleTile({
    super.key,
    required this.role,
    required this.onTap,
    this.value,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        padding: const EdgeInsets.all(16).r,
        duration: const Duration(
          milliseconds: 200,
        ),
        decoration: BoxDecoration(
          color: role != value
              ? Colors.transparent
              : AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16).r,
          border: Border.all(
            width: 1.w,
            color:
                role != value ? AppColors.borderColor : AppColors.primaryColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 63.h,
              width: 63.w,
              padding: const EdgeInsets.all(12).r,
              decoration: BoxDecoration(
                color: role != value
                    ? AppColors.profileDividerColor
                    : AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8).r,
              ),
              child: SvgImageWidget(
                image: icon,
                width: 63.w,
                height: 63.h,
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.lightTText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  6.height,
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.subtitleGreyColor,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
