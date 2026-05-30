import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/extensions/space_extension.dart';

import '../../app_config/app_colors.dart';
import '../../app_config/font_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final bool isBackgroundGradient, fit;
  final Gradient? gradient;
  final bool hasBorder, enabled;
  final Color? borderColor;
  final TextStyle? style;
  final void Function()? onTap;
  final double? fontSize;
  final Widget? icon, prefix;
  final Widget? widget;
  final EdgeInsets? padding;
  final Radius? radius;
  final double? width;
  final double? height;
  const CustomButton(
      {this.width,
      super.key,
      required this.text,
      this.onTap,
      this.style,
      this.enabled = true,
      this.fit = true,
      this.backgroundColor,
      this.isBackgroundGradient = false,
      this.hasBorder = false,
      this.borderColor,
      this.fontSize,
      this.icon,
      this.prefix,
      this.widget,
      this.padding,
      this.radius,
      this.gradient,
      this.height});

  factory CustomButton.filled({
    double? width,
    Key? key,
    required String text,
    void Function()? onTap,
    TextStyle? style,
    bool enabled = true,
    bool fit = true,
    Color? backgroundColor,
    Color? textColor,
    bool isBackgroundGradient = false,
    double? fontSize,
    Widget? icon,
    Widget? prefix,
    Widget? widget,
    EdgeInsets? padding,
    Radius? radius,
    Gradient? gradient,
    double? height,
  }) {
    return CustomButton(
      fit: fit,
      width: width,
      key: key,
      text: text,
      onTap: onTap,
      style: style?.copyWith(
            color: textColor ?? Colors.black,
          ) ??
          FontStyles.headline16.copyWith(
            color: textColor ?? Colors.black,
          ),
      enabled: enabled,
      backgroundColor: backgroundColor,
      isBackgroundGradient: isBackgroundGradient,
      fontSize: fontSize,
      icon: icon,
      prefix: prefix,
      widget: widget,
      padding: padding,
      radius: radius,
      gradient: gradient,
      height: height,
    );
  }

  factory CustomButton.outlined({
    double? width,
    Key? key,
    required String text,
    void Function()? onTap,
    TextStyle? style,
    bool enabled = true,
    bool fit = true,
    Color? borderColor,
    Color? textColor,
    double? fontSize,
    Widget? icon,
    Widget? prefix,
    Widget? widget,
    EdgeInsets? padding,
    Radius? radius,
    double? height,
  }) {
    return CustomButton(
      fit: fit,
      hasBorder: true,
      borderColor: borderColor ?? AppColors.primaryColor,
      backgroundColor: Colors.transparent,
      isBackgroundGradient: false,
      width: width,
      key: key,
      text: text,
      onTap: onTap,
      style: style?.copyWith(
            color: textColor ?? borderColor ?? AppColors.primaryColor,
          ) ??
          FontStyles.headline16.copyWith(
            color: textColor ?? borderColor ?? AppColors.primaryColor,
          ),
      enabled: enabled,
      fontSize: fontSize,
      icon: icon,
      prefix: prefix,
      widget: widget,
      padding: padding,
      radius: radius,
      height: height,
    );
  }
  factory CustomButton.text({
    double? width,
    Key? key,
    required String text,
    void Function()? onTap,
    TextStyle? style,
    Color? color,
    bool enabled = true,
    bool fit = true,
    double? fontSize,
    Widget? icon,
    Widget? prefix,
    Widget? widget,
    EdgeInsets? padding,
    Radius? radius,
    double? height,
  }) {
    return CustomButton(
      fit: fit,
      hasBorder: false,
      borderColor: Colors.transparent,
      width: width,
      key: key,
      text: text,
      onTap: onTap,
      style: style?.copyWith(
            color: color ?? AppColors.primaryColor,
          ) ??
          FontStyles.headline16.copyWith(
            color: color ?? AppColors.primaryColor,
          ),
      enabled: enabled,
      backgroundColor: Colors.transparent,
      isBackgroundGradient: false,
      fontSize: fontSize,
      icon: icon,
      prefix: prefix,
      widget: widget,
      padding: padding,
      radius: radius,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: padding ?? EdgeInsets.symmetric(vertical: 16.h),
            width: width ?? double.infinity,
            height: height,
            decoration: BoxDecoration(
              gradient: isBackgroundGradient
                  ? gradient ?? AppColors.primaryGradient
                  : null,
              color: backgroundColor ?? AppColors.primaryColor,
              border: hasBorder
                  ? Border.all(
                      width: 1.w,
                      color: borderColor ?? AppColors.primaryColor,
                    )
                  : null,
              borderRadius: BorderRadius.all(
                radius ?? Radius.circular(40.r),
              ),
            ),
            child: (widget) != null
                ? widget
                : icon != null || prefix != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          if (prefix != null) ...[
                            prefix!,
                            8.width,
                          ],
                          fit
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    text,
                                    style: style ??
                                        Theme.of(context)
                                            .textTheme
                                            .headlineMedium,
                                  ),
                                )
                              : Text(
                                  text,
                                  style: style ??
                                      Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                ),
                          if (icon != null) ...[
                            16.width,
                            icon!,
                          ],

                          const Spacer(),
                        ],
                      )
                    : fit
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              text,
                              style: style ??
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                          )
                        : Text(
                            text,
                            style: style ??
                                Theme.of(context).textTheme.headlineMedium,
                          ),
          ),
        ),
      ),
    );
  }
}

class CustomElevationButton extends StatelessWidget {
  const CustomElevationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: const Text(""),
        ));
  }
}
