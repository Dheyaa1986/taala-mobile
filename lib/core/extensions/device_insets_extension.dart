import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension DeviceInsets on BuildContext {
  MediaQueryData get _mq => MediaQuery.of(this);

  /// Physical inset at the bottom (notch, gesture bar, home indicator).
  double get safeBottomInset =>
      math.max(_mq.viewPadding.bottom, _mq.padding.bottom);

  double get safeTopInset => math.max(_mq.viewPadding.top, _mq.padding.top);

  double get keyboardInset => _mq.viewInsets.bottom;

  /// Extra space when content scrolls above the main bottom navigation bar.
  double get bottomNavContentInset => 72.h + safeBottomInset;

  EdgeInsets bottomSafePadding({
    double extra = 0,
    bool includeKeyboard = false,
  }) {
    final bottom = safeBottomInset + extra + (includeKeyboard ? keyboardInset : 0);
    return EdgeInsets.only(bottom: bottom);
  }
}
