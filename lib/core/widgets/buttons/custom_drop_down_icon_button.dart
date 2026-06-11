import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taal/core/countries/presentation/widgets/countries_widget.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/widgets/svg_image/svg_image_widget.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../app_config/app_icons.dart';
import '../../app_config/text_style.dart';

class CustomDropdownIconButton extends StatelessWidget {
  final String? selectedOption;
  final Function(String?) onChanged;
  final List<String> options;
  final String iconPath;
  final double width;
  final double height;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final Gradient? gradient;

  const CustomDropdownIconButton({
    this.selectedOption,
    required this.onChanged,
    required this.options,
    this.iconPath = '',
    this.width = 130.0,
    this.height = 30.0,
    this.textStyle,
    this.backgroundColor = AppColors.secondaryButton,
    this.borderRadius = const BorderRadius.all(Radius.circular(44)),
    super.key,
    this.padding,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 5).r,
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: borderRadius,
      ),
      child: DropdownButton<String>(
        value: selectedOption,
        icon: icon ??
            Padding(
              padding: EdgeInsetsDirectional.only(start: 12.w, end: 5.w),
              child: SvgPicture.asset(
                iconPath,
                width: 15.w,
                height: 15.h,
              ),
            ),
        underline: const SizedBox(),
        alignment: Alignment.center,
        style: textStyle ??
            TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
        items: options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option,
                      style: textStyle ??
                          TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Poppins',
                          ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class PopMenuModel {
  final String title;
  final String? iconPath;
  final Function()? onTap;
  final Color? fontColor;
  PopMenuModel(
      {required this.title, this.iconPath, this.onTap, this.fontColor});
}

class CustomMenuButton extends StatefulWidget {
  const CustomMenuButton({
    super.key,
    this.onSelected,
    this.icon,
    required this.menuItems,
    this.tooltip,
    this.child,
  });
  final Function(PopMenuModel?)? onSelected;
  final Widget? icon, child;
  final List<PopMenuModel> menuItems;
  final String? tooltip;

  @override
  State<CustomMenuButton> createState() => _CustomMenuButtonState();
}

class _CustomMenuButtonState extends State<CustomMenuButton> {
  @override
  Widget build(BuildContext context) {
    bool isRTL = context.locale.languageCode == 'ar';
    return PopupMenuButton<PopMenuModel>(
      tooltip: widget.tooltip,
      offset: const Offset(-20, -20),
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.only(
          topLeft: isRTL ? Radius.zero : Radius.circular(12.r),
          topRight: isRTL ? Radius.circular(12.r) : Radius.zero,
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      icon: widget.icon,
      color: Theme.of(context).scaffoldBackgroundColor,
      menuPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 300),
      ),
      onSelected: widget.onSelected,
      itemBuilder: (context) => widget.menuItems
          .map((option) => _buildMenuItem(option))
          .toList(),
      child: widget.child,
    );
  }

  PopupMenuItem<PopMenuModel> _buildMenuItem(
    PopMenuModel option,
  ) {
    return PopupMenuItem<PopMenuModel>(
      onTap: option.onTap,
      height: 40,
      padding: EdgeInsets.zero,
      value: option,
      child: Center(
        child: Row(
          children: [
            if (option.iconPath != null)
              Row(
                children: [
                  SvgImageWidget(image: option.iconPath!),
                  4.width,
                ],
              ),
            const Spacer(),
            Text(
              option.title.tr(),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 14.sp,
                    color: option.fontColor,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
