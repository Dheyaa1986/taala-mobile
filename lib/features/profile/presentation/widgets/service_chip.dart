import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';
import 'package:taal/core/extensions/space_extension.dart';

class ServiceChip extends StatelessWidget {
  const ServiceChip({
    super.key,
    required this.service,
    this.onRemove,
  });

  final String service;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          if (onRemove != null) ...[
            GestureDetector(
              onTap: onRemove,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 10.r,
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 20.r,
                ),
              ),
            ),
            8.width,
          ],
          Text(
            service,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
