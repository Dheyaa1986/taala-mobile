import 'package:flutter/material.dart';
import 'package:taal/core/extensions/device_insets_extension.dart';

/// Keeps bottom actions above gesture bars, home indicators, and keyboards.
class BottomSafeArea extends StatelessWidget {
  const BottomSafeArea({
    super.key,
    required this.child,
    this.extra = 12,
    this.includeKeyboard = false,
    this.minimumBottom = 8,
  });

  final Widget child;
  final double extra;
  final bool includeKeyboard;
  final double minimumBottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: minimumBottom),
      child: Padding(
        padding: context.bottomSafePadding(
          extra: extra,
          includeKeyboard: includeKeyboard,
        ),
        child: child,
      ),
    );
  }
}
