import 'dart:math' as math;

import 'package:flutter/material.dart';

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
    final mq = MediaQuery.of(context);
    // viewPadding reflects the physical inset even when padding was consumed.
    final systemBottom = mq.viewPadding.bottom;
    final keyboard = includeKeyboard ? mq.viewInsets.bottom : 0;
    final bottom = math.max(minimumBottom, systemBottom) + extra + keyboard;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}
