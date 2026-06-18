import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/themes/theme.dart';
import '../../core/app_config/app_urls.dart';
import '../../core/app_config/font_styles.dart';
import '../../core/models/theme_model.dart';
import '../../features/theme/presentation/cubit/theme_cubit.dart';

class OccasionBannerShell extends StatelessWidget {
  const OccasionBannerShell({super.key, required this.child});

  final Widget child;

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
    if (theme.bannerImageUrl != null && theme.bannerImageUrl!.trim().isNotEmpty) {
      return theme.bannerImageUrl!.trim();
    }
    return null;
  }

  static Color _bannerColor(ThemeModel theme) {
    final raw = theme.bannerColor ?? theme.colors?.primary;
    if (raw == null || raw.isEmpty) return const Color(0xFF1B5E20);
    try {
      final normalized =
          raw.startsWith('#') ? raw.replaceFirst('#', '0xFF') : raw;
      return Color(int.parse(normalized));
    } catch (_) {
      return const Color(0xFF1B5E20);
    }
  }

  static String _resolveImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return AppUrls.imageLink(url);
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

        final bannerHeight = 44.h;
        final text = _bannerText(theme!);
        final imageUrl = _bannerImageUrl(theme);
        final color = _bannerColor(theme);

        return Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.only(top: bannerHeight),
              child: child,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: bannerHeight,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: color),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null)
                          Image.network(
                            _resolveImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        if (text != null)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: FontStyles.body14W700.copyWith(
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
