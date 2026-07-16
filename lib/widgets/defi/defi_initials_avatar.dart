import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A code-drawn circular avatar showing the user's initials against a
/// vibrant gradient background. The [styleIndex] selects from [palette];
/// used in the onboarding profile step and the welcome screen.
///
/// Fallback avatar for users without an uploaded photo (`avatarUrl` is
/// optional): a deterministic initials avatar based on the user's name and
/// the locally-stored style index.
class DefiInitialsAvatar extends StatelessWidget {
  final String name;
  final int styleIndex;
  final double size;

  const DefiInitialsAvatar({
    super.key,
    required this.name,
    this.styleIndex = 0,
    this.size = 56,
  });

  /// 6 gradient variants built from existing [AppColors] brand hues.
  static const List<Gradient> palette = [
    // Primary
    LinearGradient(
      colors: [Color(0xFFEA580C), Color(0xFFF7931A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Gold
    LinearGradient(
      colors: [Color(0xFFF7931A), Color(0xFFFFD600)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Info → Primary
    LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFFF7931A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Success
    LinearGradient(
      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Secondary → Danger
    LinearGradient(
      colors: [Color(0xFFEA580C), Color(0xFFEF4444)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Info → Success
    LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  /// Extract initials from [name]: first letter of the first two words.
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = palette[styleIndex % palette.length];
    final firstColor = (gradient as LinearGradient).colors.first;
    final glowColor = firstColor.withValues(alpha: 0.35);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: palette[styleIndex % palette.length],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: size * 0.35,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            color: Colors.white,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
