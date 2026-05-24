import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClickableTextWidget extends StatelessWidget {
  final String text, clickableText;
  final VoidCallback? onTap;
  final FontWeight? clickableFontWeight;
  final TextAlign? textAlign;
  final TextStyle? textStyle,clickableTextStyle;
  const ClickableTextWidget({
    super.key,
    required this.text,
    required this.clickableText,
    this.onTap,
    this.textAlign,
    this.textStyle,
    this.clickableTextStyle,
    this.clickableFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(

            text: text,
            style:textStyle?? Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          WidgetSpan(
            baseline: TextBaseline.alphabetic,
            alignment: PlaceholderAlignment.baseline,
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                clickableText,
                style:clickableTextStyle?? Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight:clickableFontWeight?? FontWeight.w600,
                  decorationThickness: 1,
                  fontSize: 14.sp,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor

                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: textAlign ?? TextAlign.center,
      style:textStyle?? Theme.of(context).textTheme.headlineLarge,
    );
  }
}
