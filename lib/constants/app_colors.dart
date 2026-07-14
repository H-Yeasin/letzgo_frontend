import 'package:flutter/material.dart';

class AppColors {
  // Surfaces
  static const Color bg = Color(0xFF030304);
  static const Color surface = Color(0xFF0F1115);
  static const Color surfaceHover = Color(0xFF1A1D24);
  static const Color surfaceElevated = Color(0xFF1E2028);

  // Brand
  static const Color primary = Color(0xFFF7931A);
  static const Color primaryHover = Color(0xFFE67E00);
  static const Color primaryGlow = Color(0x59F7931A); // 35% opacity
  static const Color secondary = Color(0xFFEA580C);
  static const Color tertiary = Color(0xFFFFD600);

  // Foreground
  static const Color fg = Color(0xFFFFFFFF);
  static const Color fgMuted = Color(0xFF94A3B8);
  static const Color fgDim = Color(0xFF64748B);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0x1A22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0x1AF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerMuted = Color(0x1AEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoMuted = Color(0x1A3B82F6);

  // Border
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0x14FFFFFF); // 8% opacity

  // Gradients
  static const Gradient gradientPrimary = LinearGradient(
    colors: [Color(0xFFEA580C), Color(0xFFF7931A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Gradient gradientGold = LinearGradient(
    colors: [Color(0xFFF7931A), Color(0xFFFFD600)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
