import 'package:flutter/material.dart';

import '../theme/taala_tokens.dart';
import '../tokens/taala_shadows.dart';
import '../tokens/taala_spacing.dart';

class TaalaCard extends StatelessWidget {
  const TaalaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TaalaSpacing.lg),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        boxShadow: TaalaShadows.soft(brightness),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: card,
      ),
    );
  }
}
