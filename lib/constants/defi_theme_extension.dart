import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class DefiThemeExtension extends ThemeExtension<DefiThemeExtension> {
  final Color? primaryGlow;
  final Color? surfaceElevated;
  final Color? borderHover;
  final Color? fgDim;
  final Gradient? gradientPrimary;
  final Gradient? gradientGold;

  const DefiThemeExtension({
    this.primaryGlow = AppColors.primaryGlow,
    this.surfaceElevated = AppColors.surfaceElevated,
    this.borderHover = AppColors.borderLight,
    this.fgDim = AppColors.fgDim,
    this.gradientPrimary = AppColors.gradientPrimary,
    this.gradientGold = AppColors.gradientGold,
  });

  @override
  ThemeExtension<DefiThemeExtension> copyWith({
    Color? primaryGlow,
    Color? surfaceElevated,
    Color? borderHover,
    Color? fgDim,
    Gradient? gradientPrimary,
    Gradient? gradientGold,
  }) {
    return DefiThemeExtension(
      primaryGlow: primaryGlow ?? this.primaryGlow,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      borderHover: borderHover ?? this.borderHover,
      fgDim: fgDim ?? this.fgDim,
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
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t),
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t),
      borderHover: Color.lerp(borderHover, other.borderHover, t),
      fgDim: Color.lerp(fgDim, other.fgDim, t),
      gradientPrimary: gradientPrimary,
      gradientGold: gradientGold,
    );
  }
}
