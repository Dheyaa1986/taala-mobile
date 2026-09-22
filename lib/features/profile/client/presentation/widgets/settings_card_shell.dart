import 'package:flutter/material.dart';

import '../../../../../design_system/theme/taala_tokens.dart';
import '../../../../../design_system/tokens/taala_shadows.dart';

/// White card shell that separates clearly from [TaalaTokens.background].
class SettingsCardShell extends StatelessWidget {
  const SettingsCardShell({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: tokens.borderSubtle),
        boxShadow: TaalaShadows.card(brightness),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}
