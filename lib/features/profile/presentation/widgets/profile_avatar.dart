import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/avatars/user_avatar.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.isActive,
    required this.url,
  });

  final bool isActive;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        UserAvatar(
          useImageLink: false,
          radius: 60.r,
          url: url,
        ),
        if (isActive)
          Positioned(
            bottom: -14.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.green2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: AppColors.green2,
                    size: 10.r,
                  ),
                  8.width,
                  Text(
                    "Active",
                    style: TextStyle(
                      color: AppColors.green2,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
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
