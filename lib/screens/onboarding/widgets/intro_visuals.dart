import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/defi_theme_extension.dart';
import '../../../widgets/defi/defi_badge.dart';
import '../../../widgets/defi/defi_card.dart';
import '../../../widgets/defi/defi_glass_card.dart';
import '../../../widgets/defi/defi_glow_text.dart';
import '../../../widgets/defi/defi_ping_indicator.dart';

// ─── Page 1: No drivers / Just riders ────────────────────────

class SharedRolesVisual extends StatefulWidget {
  final DefiThemeExtension defi;
  const SharedRolesVisual({super.key, required this.defi});

  @override
  State<SharedRolesVisual> createState() => _SharedRolesVisualState();
}

class _SharedRolesVisualState extends State<SharedRolesVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _swapCtrl;

  @override
  void initState() {
    super.initState();
    _swapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defi = widget.defi;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Center car icon
        Container(
          width: 300,
          height: 70,
          decoration: BoxDecoration(
            gradient: defi.gradientPrimary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: defi.primaryGlow,
                blurRadius: 40,
                spreadRadius: -4,
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_car_filled,
            color: Colors.white,
            size: 36,
          ),
        ),
        // Left rider icon
        Positioned(
          left: 20,
          top: 50,
          child: _riderDot(gradient: defi.gradientPrimary, size: 44),
        ),
        // Right rider icon
        Positioned(
          right: 20,
          top: 50,
          child: _riderDot(
            gradient: Gradient.lerp(
              defi.gradientGold,
              const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFFD600)],
              ),
              1.0,
            )!,
            size: 44,
          ),
        ),
        // Swap icon between them
        Positioned(
          left: 132,
          top: 60,
          child: AnimatedBuilder(
            animation: _swapCtrl,
            builder: (context, child) => Transform.scale(
              scale: 0.9 + (_swapCtrl.value * 0.25),
              child: DefiGlassCard(
                padding: const EdgeInsets.all(6),
                borderRadius: 12,
                child: Icon(Icons.swap_horiz, size: 18, color: defi.fg),
              ),
            ),
          ),
        ),
        // Badge: HOST below left
        Positioned(
          left: 14,
          top: 110,
          child: AnimatedBuilder(
            animation: _swapCtrl,
            builder: (context, child) => Opacity(
              opacity: 1.0 - (_swapCtrl.value * 0.5),
              child: const DefiBadge(
                label: 'HOST',
                variant: DefiBadgeVariant.warning,
              ),
            ),
          ),
        ),
        // Badge: JOIN below right
        Positioned(
          right: 14,
          top: 110,
          child: AnimatedBuilder(
            animation: _swapCtrl,
            builder: (context, child) => Opacity(
              opacity: 0.5 + (_swapCtrl.value * 0.5),
              child: const DefiBadge(
                label: 'JOIN',
                variant: DefiBadgeVariant.info,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _riderDot({required Gradient gradient, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
      child: Icon(Icons.person, color: Colors.white, size: size * 0.5),
    );
  }
}

// ─── Page 2: Ping riders / going your way ─────────────────────

class RadarVisual extends StatefulWidget {
  final DefiThemeExtension defi;
  const RadarVisual({super.key, required this.defi});

  @override
  State<RadarVisual> createState() => _RadarVisualState();
}

class _RadarVisualState extends State<RadarVisual>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotCtrls;

  @override
  void initState() {
    super.initState();
    _dotCtrls = List.generate(3, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      Future.delayed(Duration(milliseconds: i * 500), () {
        if (mounted) ctrl.repeat();
      });
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (final c in _dotCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defi = widget.defi;
    final dotColors = [AppColors.primary, defi.info, defi.success];

    // Ring radii
    const rings = [110.0, 75.0, 40.0];

    // Dot angles (fixed positions on rings)
    const angles = [0.3, 1.8, 3.8]; // radians

    return Stack(
      alignment: Alignment.center,
      children: [
        for (final r in rings)
          Container(
            width: r * 3,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: defi.borderLight, width: 1),
            ),
          ),
        const DefiPingIndicator(size: 18, color: AppColors.primary),
        for (int i = 0; i < 3; i++)
          Positioned(
            left: 110 + rings[i] * math.cos(angles[i]) - 8,
            top: 110 + rings[i] * math.sin(angles[i]) - 8,
            child: AnimatedBuilder(
              animation: _dotCtrls[i],
              builder: (context, _) {
                final progress = _dotCtrls[i].value;
                // Fade in, scale from 0.4, then fade out in last third
                final visible = progress < 0.7;
                final opacity = visible
                    ? (progress < 0.2 ? progress / 0.2 : 1.0)
                    : 1.0 - ((progress - 0.7) / 0.3);
                final scale = visible
                    ? 0.4 + (progress.clamp(0.0, 0.3) / 0.3 * 0.6)
                    : 1.0;

                return Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: dotColors[i],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: dotColors[i].withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        // "going your way" badge on the third dot's approximate position
        Positioned(
          left: 100 + rings[1] * math.cos(angles[1]),
          top: 80 + rings[1] * math.sin(angles[1]),
          child: AnimatedBuilder(
            animation: _dotCtrls[1],
            builder: (context, _) {
              final progress = _dotCtrls[1].value;
              return Opacity(
                opacity: (progress > 0.2 && progress < 0.6) ? 1.0 : 0.0,
                child: const DefiBadge(
                  label: 'going your way',
                  variant: DefiBadgeVariant.info,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Page 3: Half the fare / same ride ────────────────────────

class FareSplitVisual extends StatefulWidget {
  final DefiThemeExtension defi;
  const FareSplitVisual({super.key, required this.defi});

  @override
  State<FareSplitVisual> createState() => _FareSplitVisualState();
}

class _FareSplitVisualState extends State<FareSplitVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _fareCtrl;

  @override
  void initState() {
    super.initState();
    _fareCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    )..repeat();
  }

  @override
  void dispose() {
    _fareCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DefiGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        borderRadius: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '৳ 300',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: widget.defi.fgMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                // Animated fare
                AnimatedBuilder(
                  animation: _fareCtrl,
                  builder: (context, _) {
                    final t = _fareCtrl.value;
                    final value = t < 0.6 ? 300.0 - ((t / 0.6) * 150.0) : 150.0;
                    return DefiGlowText(
                      text: '৳ ${value.round()}',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _miniAvatar(size: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.call_split,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                _miniAvatar(size: 24),
                const SizedBox(width: 8),
                const DefiBadge(
                  label: 'YOU SAVE 50%',
                  variant: DefiBadgeVariant.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniAvatar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.gradientPrimary,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.white, size: size * 0.55),
    );
  }
}

// ─── Page 4: Safety is / built in ────────────────────────────

class SafetyVisual extends StatelessWidget {
  final DefiThemeExtension defi;
  const SafetyVisual({super.key, required this.defi});

  @override
  Widget build(BuildContext context) {
    final items = [
      SafetyItem(
        icon: Icons.verified_user,
        color: defi.success,
        label: 'Verified riders',
      ),
      SafetyItem(
        icon: Icons.star,
        color: defi.warning,
        label: 'Community ratings',
      ),
      SafetyItem(
        icon: Icons.wc,
        color: defi.info,
        label: 'Gender preference,\nset per ride',
      ),
    ];

    return Stack(
      children: [
        // Large watermark shield
        Center(
          child: Icon(
            Icons.shield_outlined,
            size: 140,
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
        ),
        // Safety cards
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: i < items.length - 1 ? 12 : 0),
                child: items[i]
                    .toWidget(defi)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: i * 150),
                      duration: const Duration(milliseconds: 300),
                    )
                    .slideX(begin: 0.15),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class SafetyItem {
  final IconData icon;
  final Color color;
  final String label;

  const SafetyItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  Widget toWidget(DefiThemeExtension defi) {
    return DefiCard(
      variant: DefiCardVariant.glass,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SizedBox(
        width: 220,
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
