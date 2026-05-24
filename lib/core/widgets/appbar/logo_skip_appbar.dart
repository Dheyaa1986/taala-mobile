import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taal/core/widgets/svg_image/lang_popup.dart';

import '../../app_config/app_colors.dart';
import '../buttons/back_button.dart';
import '../buttons/skip_button.dart';
import '../logo/app_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSize {
  const CustomAppBar({
    super.key,
    this.customTitle,
    this.leading,
    this.title,
    this.centerTitle,
    this.bottomWidget,
    this.titleFs,
    this.actions,
    this.isShown,
    this.appBarHeight,
  });

  final Widget? customTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottomWidget;
  final String? title;
  final double? titleFs;
  final num? appBarHeight;
  final bool? centerTitle, isShown;
  factory CustomAppBar.logoSkipAppBar({Function()? onTap}) => CustomAppBar(
        leading: SkipButton(
          onTap: onTap,
        ),
        customTitle: AppLogo.svg(),
      );
  factory CustomAppBar.logoAppBar() => CustomAppBar(
        leading: null,
        customTitle: AppLogo.svg(),
      );
  factory CustomAppBar.backAppBar({
    String? title,
    PreferredSizeWidget? bottomWidget,
    bool? centerTitle,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) =>
      CustomAppBar(
        centerTitle: centerTitle,
        leading: CustomBackButton(
          onPressed: onBackPressed,
        ),
        title: title,
        bottomWidget: bottomWidget,
        actions: actions,
      );
  factory CustomAppBar.dividerBackAppBar({
    String? title,
    PreferredSizeWidget? bottomWidget,
    bool? centerTitle,
    double? titleFS,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    double? dividerHeight,
    double? appBarHeight,
    Widget? titleWidget,
  }) =>
      CustomAppBar(
        titleFs: titleFS,
        customTitle:  titleWidget,
        appBarHeight: appBarHeight,
        centerTitle: centerTitle,
        leading: CustomBackButton(
          onPressed: onBackPressed,
        ),
        title: title,
        bottomWidget: PreferredSize(
            preferredSize: Size.fromHeight(dividerHeight ?? 48),
            child: Divider(
              indent: 16.w,
              endIndent: 16.w,
              height: dividerHeight,
              color: AppColors.lightGreyDividerColor,
            )),
        actions: actions,
      );
  factory CustomAppBar.langAppBar({
    String? title,
    PreferredSizeWidget? bottomWidget,
    bool? centerTitle,
    double? titleFS,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    double? dividerHeight,
    double? appBarHeight,
    Widget? titleWidget,
    Widget? leading,
  }) =>
      CustomAppBar(
        titleFs: titleFS,
        customTitle:  titleWidget,
        appBarHeight: 0,
        centerTitle: centerTitle,
        leading:leading?? CustomBackButton(
          onPressed: onBackPressed,
        ),
        title: title,
        bottomWidget:bottomWidget,
        actions: [
          ...?actions,
          const LangPopup(),
        ],
      );
  factory CustomAppBar.homeAppBar(
          {VoidCallback? onLogoTap,
          bool? isShown,
          PreferredSizeWidget? bottomWidget}) =>
      CustomAppBar(
        centerTitle: true,
        isShown: isShown,
        bottomWidget: bottomWidget,
        customTitle: GestureDetector(
          onTap: onLogoTap,
          child: AppLogo.svg(),
        ),
      );
  @override
  Widget build(BuildContext context) {
    double height = bottomWidget != null
        ? kToolbarHeight + kTextTabBarHeight
        : kToolbarHeight;
    return AppBar(
      actions: actions,
      centerTitle: centerTitle ?? true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leadingWidth: 60.w,
      titleSpacing: 0,
      leading: leading == null ? null : Center(child: leading),
      toolbarHeight: height,
      bottom: bottomWidget,
      title: customTitle ??
          (title != null
              ? Text(
                  title!,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(fontSize: titleFs ?? 18.sp,fontWeight: FontWeight.w500),
                )
              : null),
    );
  }

  @override
  Widget get child => AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        offset: Offset(0, isShown ?? false ? 0 : -kToolbarHeight),
        child: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leadingWidth: 60.w,
          leading: SkipButton(
            onTap: () {},
          ),
          title: AppLogo.svg(),
        ),
      );

  @override
  // TODO: implement preferredSize
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (appBarHeight ?? 0));
}

class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LogoAppBar({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(130); // Total height including logo

  @override
  Widget build(BuildContext context) {
    // Get the current text direction (works with EasyLocalization)
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: isRTL ? null : 20.w,
            right: isRTL ? 20.w : null,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Padding(
                  padding: REdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.lightBGColor),
                ),
              ),
            ),
          ),
          AppLogo.png(
            height: 130.h,
            width: 130.w,
          ),
        ],
      ),
    );
  }
}
