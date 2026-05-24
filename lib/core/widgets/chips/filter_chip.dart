import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';
import '../../app_config/app_colors.dart';

class CustomFilterChip extends StatelessWidget {
  const CustomFilterChip({
    super.key,
    required this.title,
    required this.onRemove,
  });

  final String title;
  final Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onRemove,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(100.r),
              child: Container(
                padding: EdgeInsets.all(5.5.r),
                decoration: const BoxDecoration(
                  color: AppColors.whiteColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 10.r,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            6.width,
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),


          ],
        ),
      ),
    );
  }
}
