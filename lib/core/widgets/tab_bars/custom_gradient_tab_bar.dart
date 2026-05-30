import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';

class CustomGradientTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  const CustomGradientTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        width: double.infinity,
        height: 61.h,
        padding: EdgeInsets.all(1.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: [
              AppColors.primaryColor,
              AppColors.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
              children: List.generate(tabs.length, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (index == selectedIndex) return;
                  onTabChanged(index);
                },
                child: AnimatedContainer(
                  width: double.infinity,
                  height: double.infinity,
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: index != selectedIndex
                          ? [
                              Colors.transparent,
                              Colors.transparent,
                            ]
                          : [
                              AppColors.primaryColor,
                              AppColors.secondaryColor,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: FittedBox(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontSize: 20.sp,
                              color: selectedIndex == index
                                  ? Colors.white
                                  : AppColors.secondaryColor,
                            ),
                        child: Text(
                          tabs[index],
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          strutStyle: const StrutStyle(
                            height: 1.0,
                            forceStrutHeight: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          })),
        ),
      ),
    );
  }
}
