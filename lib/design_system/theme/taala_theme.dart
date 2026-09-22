import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/theme_model.dart';
import '../tokens/taala_palette.dart';
import '../tokens/taala_radius.dart';
import '../tokens/taala_typography.dart';
import 'taala_tokens.dart';

abstract final class TaalaTheme {
  static ThemeData light({ThemeModel? occasionTheme}) {
    return _build(
      brightness: Brightness.light,
      occasionTheme: occasionTheme,
    );
  }

  static ThemeData dark({ThemeModel? occasionTheme}) {
    return _build(
      brightness: Brightness.dark,
      occasionTheme: occasionTheme,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    ThemeModel? occasionTheme,
  }) {
    final primaryOverride = _parseColor(occasionTheme?.colors?.primary);
    final tokens = brightness == Brightness.light
        ? TaalaTokens.light(primaryOverride: primaryOverride)
        : TaalaTokens.dark(primaryOverride: primaryOverride);

    final colorScheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: tokens.primary,
            onPrimary: tokens.onPrimary,
            secondary: tokens.primary,
            onSecondary: tokens.onPrimary,
            surface: tokens.surface,
            onSurface: tokens.textPrimary,
            error: tokens.error,
            onError: Colors.white,
          )
        : ColorScheme.dark(
            primary: tokens.primary,
            onPrimary: tokens.onPrimary,
            secondary: tokens.primary,
            onSecondary: tokens.onPrimary,
            surface: tokens.surface,
            onSurface: tokens.textPrimary,
            error: tokens.error,
            onError: Colors.white,
          );

    final textTheme = TaalaTypography.textTheme(
      textPrimary: tokens.textPrimary,
      textSecondary: tokens.textSecondary,
      primary: tokens.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: TaalaTypography.fontFamily,
      scaffoldBackgroundColor: tokens.background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryColor: tokens.primary,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: tokens.background,
        foregroundColor: tokens.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.cardRadius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodySmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.inputRadius),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.inputRadius),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.inputRadius),
          borderSide: BorderSide(color: tokens.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.inputRadius),
          borderSide: BorderSide(color: tokens.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.inputRadius),
          borderSide: BorderSide(color: tokens.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: tokens.primary,
          foregroundColor: tokens.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: tokens.onPrimary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: tokens.textPrimary,
          backgroundColor: tokens.primarySoft,
          side: BorderSide.none,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primary,
          textStyle: textTheme.labelLarge?.copyWith(color: tokens.primary),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.surface,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelMedium?.copyWith(
          color: tokens.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: TaalaRadius.xlBorder,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: tokens.textPrimary,
        ),
        actionTextColor: tokens.primary,
        shape: RoundedRectangleBorder(
          borderRadius: TaalaRadius.mdBorder,
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceMuted,
        selectedColor: tokens.primarySoft,
        labelStyle: textTheme.bodySmall!,
        side: BorderSide(color: tokens.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: TaalaRadius.smBorder,
        ),
      ),
    );
  }

  static Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      final normalized = colorString.startsWith('#')
          ? colorString.replaceFirst('#', '0xFF')
          : colorString;
      return Color(int.parse(normalized));
    } catch (_) {
      return null;
    }
  }

  static Color splashBackground({ThemeModel? occasionTheme}) {
    return _parseColor(occasionTheme?.colors?.primary) ??
        TaalaPalette.primary;
  }
}
