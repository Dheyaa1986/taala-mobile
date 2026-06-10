import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/app_config/app_icons.dart';
import 'package:taal/core/widgets/bottom_nav_bar/cubit/bottom_navigation_cubit.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

class ProfileIconButton extends StatelessWidget {
  const ProfileIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
      onPressed: () {
        context.read<BottomNavigationCubit>().goToBranch(2);
      },
      icon: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryColor.withValues(alpha: 0.12),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Center(
          child: SvgImageWidget(
            image: AppIcons.userIcon,
            width: 20.w,
            height: 20.h,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
