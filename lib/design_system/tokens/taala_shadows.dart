import 'package:flutter/material.dart';

abstract final class TaalaShadows {
  /// Elevated cards on grouped backgrounds (settings lists, menus).
  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.light) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> soft(Brightness brightness) {
    final opacity = brightness == Brightness.light ? 0.06 : 0.22;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> medium(Brightness brightness) {
    final opacity = brightness == Brightness.light ? 0.06 : 0.28;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
