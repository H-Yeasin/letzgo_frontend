// Backward-compatible bridge — re-exports the new dark theme
// Old code used: AppTheme.lightTheme / AppTheme.primaryColor / etc.
// New code uses: defiDarkTheme / AppColors / etc.
// This file keeps existing imports working without modifying every screen.

import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_colors.dart';

export 'app_theme.dart';
export 'app_colors.dart';
export 'defi_theme_extension.dart';

/// Backward-compatible accessor for code still referencing `AppTheme.*`
class AppTheme {
  static ThemeData get lightTheme => defiDarkTheme;
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const Color errorColor = AppColors.danger;
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;
  static const Color backgroundColor = AppColors.bg;
  static const Color surfaceColor = AppColors.surface;
  static const Color darkTextColor = AppColors.fg;
  static const Color lightTextColor = AppColors.fgMuted;
  static const Color femaleColor = Color(0xFFFF6B9D);
  static const Color maleColor = Color(0xFF4A90D9);
  static const Color statusOpen = Color(0xFF22C55E);
  static const Color statusMatched = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF64748B);
  static const Color statusCancelled = Color(0xFFEF4444);
}
