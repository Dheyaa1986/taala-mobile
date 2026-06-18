import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/themes/theme.dart';
import '../../core/app_config/app_colors.dart';
import '../../core/app_config/app_urls.dart';
import '../../core/app_config/font_styles.dart';
import '../../core/models/theme_model.dart';
import '../../features/theme/presentation/cubit/theme_cubit.dart';

class OccasionBannerShell extends StatelessWidget {
  const OccasionBannerShell({super.key, required this.child});

  final Widget child;

  static const double _iconSize = 40;
  static const double _stripHeight = 56;

  static bool shouldShowBanner(ThemeModel? theme) {
    if (theme == null || !theme.isActive) return false;
    final text = _bannerText(theme);
    final image = _bannerImageUrl(theme);
    return (text != null && text.isNotEmpty) ||
        (image != null && image.isNotEmpty);
  }

  static String? _bannerText(ThemeModel theme) {
    if (theme.bannerText != null && theme.bannerText!.trim().isNotEmpty) {
      return theme.bannerText!.trim();
    }
    if (theme.occasion != null && theme.occasion!.trim().isNotEmpty) {
      return theme.occasion!.trim();
    }
    return null;
  }

  static String? _bannerImageUrl(ThemeModel theme) {
    if (theme.bannerImageUrl != null &&
        theme.bannerImageUrl!.trim().isNotEmpty) {
      return theme.bannerImageUrl!.trim();
    }
    return null;
  }

  static Color _parseColor(String? raw, Color fallback) {
    if (raw == null || raw.isEmpty) return fallback;
    try {
      final normalized =
          raw.startsWith('#') ? raw.replaceFirst('#', '0xFF') : raw;
      return Color(int.parse(normalized));
    } catch (_) {
      return fallback;
    }
  }

  static Color _backgroundColor(ThemeModel theme) =>
      _parseColor(theme.bannerColor, AppColors.lightBGColor);

  static Color _textColor(ThemeModel theme) =>
      _parseColor(theme.bannerTextColor, AppColors.lightMainText);

  static String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return AppUrls.imageLink(url);
  }

  Widget _buildBannerStrip({
    required ThemeModel theme,
    required String? text,
    required String? imageUrl,
  }) {
    final iconSize = _iconSize.w;
    final backgroundColor = _backgroundColor(theme);
    final textColor = _textColor(theme);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: _stripHeight.h,
          width: double.infinity,
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              SizedBox(width: 10.w),
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    _resolveImageUrl(imageUrl),
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        SizedBox(width: iconSize, height: iconSize),
                  ),
                )
              else
                SizedBox(width: iconSize),
              Expanded(
                child: text != null
                    ? Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: FontStyles.label14.copyWith(
                          color: textColor,
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                          height: 1.1,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(width: iconSize + 10.w),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final theme = state is ThemeLoaded
            ? state.theme
            : TariqyAppTheme.activeTheme;

        if (!shouldShowBanner(theme)) {
          return child;
        }

        final text = _bannerText(theme!);
        final imageUrl = _bannerImageUrl(theme);

        return ColoredBox(
          color: AppColors.lightBGColor,
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: _buildBannerStrip(
                  theme: theme,
                  text: text,
                  imageUrl: imageUrl,
                ),
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
