import 'package:flutter/material.dart';

import 'taala_tokens.dart';

extension TaalaContext on BuildContext {
  TaalaTokens get tokens => TaalaTokens.of(this);

  TextStyle get textPrimaryStyle =>
      Theme.of(this).textTheme.bodyLarge ??
      TextStyle(color: tokens.textPrimary);

  TextStyle get textSecondaryStyle =>
      Theme.of(this).textTheme.bodySmall ??
      TextStyle(color: tokens.textSecondary);

  Color get readableTextPrimary => tokens.textPrimary;

  Color get readableTextSecondary => tokens.textSecondary;
}
