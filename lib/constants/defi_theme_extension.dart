import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Carries every Bitcoin DeFi design token so widgets can resolve colors
/// from the active theme (dark void / light daylight) via `context.defi`.
@immutable
class DefiThemeExtension extends ThemeExtension<DefiThemeExtension> {
  // Surfaces
  final Color bg;
  final Color surface;
  final Color surfaceHover;
  final Color surfaceElevated;

  // Foreground
  final Color fg;
  final Color fgMuted;
  final Color fgDim;

  // Borders
  final Color border;
  final Color borderLight;
  final Color borderHover;

  // Brand effects
  final Color primaryGlow;
  final Color glassFill;
  final Color gridLine;
  final Color shimmerBase;
  final Color shimmerHighlight;

  // Semantic
  final Color success;
  final Color successMuted;
  final Color warning;
  final Color warningMuted;
  final Color danger;
  final Color dangerMuted;
  final Color info;
  final Color infoMuted;

  // Gradients
  final Gradient gradientPrimary;
  final Gradient gradientGold;

  const DefiThemeExtension({
    required this.bg,
    required this.surface,
    required this.surfaceHover,
    required this.surfaceElevated,
    required this.fg,
    required this.fgMuted,
    required this.fgDim,
    required this.border,
    required this.borderLight,
    required this.borderHover,
    required this.primaryGlow,
    required this.glassFill,
    required this.gridLine,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.success,
    required this.successMuted,
    required this.warning,
    required this.warningMuted,
    required this.danger,
    required this.dangerMuted,
    required this.info,
    required this.infoMuted,
    required this.gradientPrimary,
    required this.gradientGold,
  });

  /// "True Void" — the original dark Bitcoin DeFi palette.
  static const DefiThemeExtension dark = DefiThemeExtension(
    bg: AppColors.bg,
    surface: AppColors.surface,
    surfaceHover: AppColors.surfaceHover,
    surfaceElevated: AppColors.surfaceElevated,
    fg: AppColors.fg,
    fgMuted: AppColors.fgMuted,
    fgDim: AppColors.fgDim,
    border: AppColors.border,
    borderLight: AppColors.borderLight,
    borderHover: AppColors.borderLight,
    primaryGlow: AppColors.primaryGlow,
    glassFill: Color(0x66000000), // black 40%
    gridLine: Color(0x141E293B), // border at 8%
    shimmerBase: AppColors.surface,
    shimmerHighlight: Color(0x33FFFFFF), // white 20%
    success: AppColors.success,
    successMuted: AppColors.successMuted,
    warning: AppColors.warning,
    warningMuted: AppColors.warningMuted,
    danger: AppColors.danger,
    dangerMuted: AppColors.dangerMuted,
    info: AppColors.info,
    infoMuted: AppColors.infoMuted,
    gradientPrimary: AppColors.gradientPrimary,
    gradientGold: AppColors.gradientGold,
  );

  /// "Daylight Gold" — the light counterpart.
  static const DefiThemeExtension light = DefiThemeExtension(
    bg: AppColorsLight.bg,
    surface: AppColorsLight.surface,
    surfaceHover: AppColorsLight.surfaceHover,
    surfaceElevated: AppColorsLight.surfaceElevated,
    fg: AppColorsLight.fg,
    fgMuted: AppColorsLight.fgMuted,
    fgDim: AppColorsLight.fgDim,
    border: AppColorsLight.border,
    borderLight: AppColorsLight.borderLight,
    borderHover: AppColorsLight.borderLight,
    primaryGlow: AppColorsLight.primaryGlow,
    glassFill: Color(0xA6FFFFFF), // white 65%
    gridLine: Color(0x1A64748B), // slate 10%
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xB3FFFFFF), // white 70%
    success: AppColorsLight.success,
    successMuted: AppColorsLight.successMuted,
    warning: AppColorsLight.warning,
    warningMuted: AppColorsLight.warningMuted,
    danger: AppColorsLight.danger,
    dangerMuted: AppColorsLight.dangerMuted,
    info: AppColorsLight.info,
    infoMuted: AppColorsLight.infoMuted,
    gradientPrimary: AppColorsLight.gradientPrimary,
    gradientGold: AppColorsLight.gradientGold,
  );

  @override
  ThemeExtension<DefiThemeExtension> copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceHover,
    Color? surfaceElevated,
    Color? fg,
    Color? fgMuted,
    Color? fgDim,
    Color? border,
    Color? borderLight,
    Color? borderHover,
    Color? primaryGlow,
    Color? glassFill,
    Color? gridLine,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? success,
    Color? successMuted,
    Color? warning,
    Color? warningMuted,
    Color? danger,
    Color? dangerMuted,
    Color? info,
    Color? infoMuted,
    Gradient? gradientPrimary,
    Gradient? gradientGold,
  }) {
    return DefiThemeExtension(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      fg: fg ?? this.fg,
      fgMuted: fgMuted ?? this.fgMuted,
      fgDim: fgDim ?? this.fgDim,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      borderHover: borderHover ?? this.borderHover,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      glassFill: glassFill ?? this.glassFill,
      gridLine: gridLine ?? this.gridLine,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      success: success ?? this.success,
      successMuted: successMuted ?? this.successMuted,
      warning: warning ?? this.warning,
      warningMuted: warningMuted ?? this.warningMuted,
      danger: danger ?? this.danger,
      dangerMuted: dangerMuted ?? this.dangerMuted,
      info: info ?? this.info,
      infoMuted: infoMuted ?? this.infoMuted,
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
      gradientGold: gradientGold ?? this.gradientGold,
    );
  }

  @override
  ThemeExtension<DefiThemeExtension> lerp(
    covariant ThemeExtension<DefiThemeExtension>? other,
    double t,
  ) {
    if (other is! DefiThemeExtension) return this;
    return DefiThemeExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      fgMuted: Color.lerp(fgMuted, other.fgMuted, t)!,
      fgDim: Color.lerp(fgDim, other.fgDim, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderHover: Color.lerp(borderHover, other.borderHover, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
          Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      success: Color.lerp(success, other.success, t)!,
      successMuted: Color.lerp(successMuted, other.successMuted, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningMuted: Color.lerp(warningMuted, other.warningMuted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerMuted: Color.lerp(dangerMuted, other.dangerMuted, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoMuted: Color.lerp(infoMuted, other.infoMuted, t)!,
      gradientPrimary: Gradient.lerp(gradientPrimary, other.gradientPrimary, t)!,
      gradientGold: Gradient.lerp(gradientGold, other.gradientGold, t)!,
    );
  }
}

/// Shorthand for resolving DeFi tokens from the active theme:
/// `context.defi.surface`, `context.defi.gradientGold`, ...
extension DefiThemeContext on BuildContext {
  DefiThemeExtension get defi =>
      Theme.of(this).extension<DefiThemeExtension>() ?? DefiThemeExtension.dark;
}
