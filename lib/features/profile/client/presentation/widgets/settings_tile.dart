import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_colors.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.title, this.onTap});
  final String title;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: const Color(0x269A9A9A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side:  const BorderSide(
          color: AppColors.borderColorMain,
        ),

      ),
      margin: EdgeInsets.zero,
      child: ListTile(
    contentPadding:  REdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),


        ),
        title: Text(
          title.tr(),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          )),
        trailing:  Icon(
          Icons.arrow_forward_ios,
          color: AppColors.greyText,
          size: 10.r,
        ),
        onTap: onTap,
      ),
    );
  }
}
