import 'package:flutter/material.dart';
import 'package:taal/config/themes/theme.dart';
import 'package:taal/core/app_config/app_urls.dart';

class ThemedBackground extends StatelessWidget {
  const ThemedBackground({super.key, required this.child});

  final Widget child;

  String? _backgroundImageUrl() {
    final url = TariqyAppTheme.activeTheme?.backgroundImageUrl;
    if (url == null || url.isEmpty) return null;
    return url.startsWith('http') ? url : AppUrls.imageLink(url);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _backgroundImageUrl();
    if (imageUrl == null) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.12,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        child,
      ],
    );
  }
}
