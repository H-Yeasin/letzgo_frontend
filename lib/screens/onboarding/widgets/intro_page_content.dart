import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/defi_theme_extension.dart';
import '../../../widgets/defi/defi_glow_text.dart';
import 'intro_page_data.dart';
import 'intro_visuals.dart';

class IntroPageContent extends StatelessWidget {
  final IntroPageData data;
  final int index;

  const IntroPageContent({super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Visual area
          SizedBox(height: 240, child: _buildVisual(context, defi)),
          const SizedBox(height: 32),
          // Text block
          KeyedSubtree(
            key: ValueKey(index),
            child: Column(
              children: [
                Text(
                  data.eyebrow,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: defi.fgMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.titleTop,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: defi.fg,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
                DefiGlowText(
                  text: data.titleGlow,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  data.body,
                  style: TextStyle(
                    fontSize: 15,
                    color: defi.fgMuted,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)).slideY(begin: 0.08),
        ],
      ),
    );
  }

  Widget _buildVisual(BuildContext context, DefiThemeExtension defi) {
    switch (index) {
      case 0:
        return SharedRolesVisual(defi: defi);
      case 1:
        return RadarVisual(defi: defi);
      case 2:
        return FareSplitVisual(defi: defi);
      case 3:
        return SafetyVisual(defi: defi);
      default:
        return const SizedBox();
    }
  }
}
