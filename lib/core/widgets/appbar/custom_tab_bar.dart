import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(int? index)? onTap;
  final List<String> tabTitles;

  const CustomTabBar({
    Key? key,
    required this.onTap,
    required this.tabTitles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      dividerColor: Colors.transparent,
      tabs: List.generate(
        tabTitles.length,
        (index) => Tab(
          text: tabTitles[index],
        ),
      ),
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: AppColors.primaryColor,
      indicatorWeight: 4,
      labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Theme.of(context).textTheme.labelLarge?.color,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
