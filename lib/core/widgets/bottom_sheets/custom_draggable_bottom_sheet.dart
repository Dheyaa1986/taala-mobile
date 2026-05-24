import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app_config/app_colors.dart';


class CustomDraggableBottomSheet extends StatelessWidget {
  final bool canClose, isScrollControlled;
  final Widget child;
  const CustomDraggableBottomSheet({
    super.key,
    this.canClose = true,
    this.isScrollControlled = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: !isScrollControlled
          ? null
          : BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(
            color: AppColors.borderColor,
          ),
          right: BorderSide(
            color: AppColors.borderColor,
          ),
          left: BorderSide(
            color: AppColors.borderColor,
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            32.r,
          ),
        ),
      ),
      child: Stack(
        children: [
          child,
      /*    if (canClose)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0).r,
                child: const CustomCloseButton(),
              ),
            ),*/
        ],
      ),
    );
  }
}
