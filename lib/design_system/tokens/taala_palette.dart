import 'package:flutter/material.dart';

/// Raw brand palette — semantic usage goes through [TaalaTokens] / Theme.
abstract final class TaalaPalette {
  static const primary = Color(0xFFFFC20F);
  static const primaryDark = Color(0xFFE6AD00);
  static const onPrimary = Color(0xFF1C1C1E);

  static const error = Color(0xFFFF3B30);
  static const success = Color(0xFF34C759);

  static const lightBackground = Color(0xFFEFEFF4);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFF2F2F7);
  static const lightPrimarySoft = Color(0xFFFFF8E1);
  static const lightTextPrimary = Color(0xFF1C1C1E);
  static const lightTextSecondary = Color(0xFF8E8E93);
  static const lightBorderSubtle = Color(0xFFDCDCE2);

  static const darkBackground = Color(0xFF121214);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkSurfaceMuted = Color(0xFF2C2C2E);
  static const darkPrimarySoft = Color(0xFF3D3419);
  static const darkTextPrimary = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFFAEAEB2);
  static const darkBorderSubtle = Color(0xFF3A3A3C);
}
