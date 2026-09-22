import 'package:flutter/material.dart';

import '../tokens/taala_palette.dart';
import '../tokens/taala_radius.dart';

@immutable
class TaalaTokens extends ThemeExtension<TaalaTokens> {
  const TaalaTokens({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderSubtle,
    required this.error,
    required this.success,
    required this.cardRadius,
    required this.buttonRadius,
    required this.inputRadius,
  });

  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color primary;
  final Color primarySoft;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderSubtle;
  final Color error;
  final Color success;
  final double cardRadius;
  final double buttonRadius;
  final double inputRadius;

  static TaalaTokens light({Color? primaryOverride}) {
    final primary = primaryOverride ?? TaalaPalette.primary;
    return TaalaTokens(
      background: TaalaPalette.lightBackground,
      surface: TaalaPalette.lightSurface,
      surfaceMuted: TaalaPalette.lightSurfaceMuted,
      primary: primary,
      primarySoft: TaalaPalette.lightPrimarySoft,
      onPrimary: TaalaPalette.onPrimary,
      textPrimary: TaalaPalette.lightTextPrimary,
      textSecondary: TaalaPalette.lightTextSecondary,
      borderSubtle: TaalaPalette.lightBorderSubtle,
      error: TaalaPalette.error,
      success: TaalaPalette.success,
      cardRadius: TaalaRadius.lg,
      buttonRadius: TaalaRadius.md,
      inputRadius: TaalaRadius.md,
    );
  }

  static TaalaTokens dark({Color? primaryOverride}) {
    final primary = primaryOverride ?? TaalaPalette.primary;
    return TaalaTokens(
      background: TaalaPalette.darkBackground,
      surface: TaalaPalette.darkSurface,
      surfaceMuted: TaalaPalette.darkSurfaceMuted,
      primary: primary,
      primarySoft: TaalaPalette.darkPrimarySoft,
      onPrimary: TaalaPalette.onPrimary,
      textPrimary: TaalaPalette.darkTextPrimary,
      textSecondary: TaalaPalette.darkTextSecondary,
      borderSubtle: TaalaPalette.darkBorderSubtle,
      error: TaalaPalette.error,
      success: TaalaPalette.success,
      cardRadius: TaalaRadius.lg,
      buttonRadius: TaalaRadius.md,
      inputRadius: TaalaRadius.md,
    );
  }

  static TaalaTokens of(BuildContext context) {
    return Theme.of(context).extension<TaalaTokens>() ??
        TaalaTokens.light();
  }

  @override
  TaalaTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? primary,
    Color? primarySoft,
    Color? onPrimary,
    Color? textPrimary,
    Color? textSecondary,
    Color? borderSubtle,
    Color? error,
    Color? success,
    double? cardRadius,
    double? buttonRadius,
    double? inputRadius,
  }) {
    return TaalaTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      error: error ?? this.error,
      success: success ?? this.success,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      inputRadius: inputRadius ?? this.inputRadius,
    );
  }

  @override
  TaalaTokens lerp(ThemeExtension<TaalaTokens>? other, double t) {
    if (other is! TaalaTokens) return this;
    return TaalaTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      buttonRadius: buttonRadius + (other.buttonRadius - buttonRadius) * t,
      inputRadius: inputRadius + (other.inputRadius - inputRadius) * t,
    );
  }
}
