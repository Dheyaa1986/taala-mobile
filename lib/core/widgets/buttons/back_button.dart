import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/design_system/theme/taala_tokens.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? verticalPadding;
  const CustomBackButton({super.key, this.onPressed, this.verticalPadding});

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    if (!context.canPop() && onPressed == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 8),
      child: GestureDetector(
        onTap: onPressed ?? () => context.pop(),
        child: Container(
          height: 48.h,
          width: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: tokens.borderSubtle,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back,
              color: tokens.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
