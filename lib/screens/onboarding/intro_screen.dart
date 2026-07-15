import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/defi/defi_badge.dart';
import '../../widgets/defi/defi_button.dart';
import '../../widgets/defi/defi_card.dart';
import '../../widgets/defi/defi_glass_card.dart';
import '../../widgets/defi/defi_glow_text.dart';
import '../../widgets/defi/defi_grid_background.dart';
import '../../widgets/defi/defi_ping_indicator.dart';

/// First-launch story carousel shown (once) before the auth flow.
/// 4 code-drawn pages that tell the LetzGo story: shared roles, radar
/// matching, fare splitting, and built-in safety.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _IntroPageData(
      eyebrow: 'RIDE TOGETHER',
      titleTop: 'No drivers.',
      titleGlow: 'Just riders.',
      body:
          'Host a ride one day, hop into one the next — '
          'you decide every trip.',
    ),
    _IntroPageData(
      eyebrow: 'PING NEARBY',
      titleTop: 'Ping riders',
      titleGlow: 'going your way',
      body:
          'Share your route and find fellow commuters '
          'heading in the same direction.',
    ),
    _IntroPageData(
      eyebrow: 'SPLIT THE FARE',
      titleTop: 'Half the fare,',
      titleGlow: 'same ride',
      body:
          'Split the cost of every trip. The more you '
          'share, the more you save.',
    ),
    _IntroPageData(
      eyebrow: 'RIDE SAFE',
      titleTop: 'Safety is',
      titleGlow: 'built in',
      body:
          'Verified riders, community ratings, and '
          'gender preferences — set per ride, not per profile.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingPrefsProvider.notifier).markIntroSeen();
    if (mounted) context.go('/phone-input');
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    return Scaffold(
      backgroundColor: defi.bg,
      body: DefiGridBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: mini logo + Skip
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: defi.gradientPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.directions_car_filled,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LetzGo',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: defi.fg,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    DefiButton(
                      label: 'Skip',
                      variant: DefiButtonVariant.ghost,
                      onPressed: _finish,
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final data = _pages[index];
                    return _IntroPageContent(data: data, index: index);
                  },
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Page dots
                    _IntroDots(count: _pages.length, index: _page),
                    const SizedBox(height: 24),
                    // Next / Get Started
                    DefiButton(
                      label: _page == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      fullWidth: true,
                      icon: _page == _pages.length - 1
                          ? Icons.arrow_forward
                          : null,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page data ──────────────────────────────────────────────

class _IntroPageData {
  final String eyebrow;
  final String titleTop;
  final String titleGlow;
  final String body;

  const _IntroPageData({
    required this.eyebrow,
    required this.titleTop,
    required this.titleGlow,
    required this.body,
  });
}

// ─── Single page content ────────────────────────────────────

class _IntroPageContent extends StatelessWidget {
  final _IntroPageData data;
  final int index;

  const _IntroPageContent({required this.data, required this.index});

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
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: defi.fg,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
                DefiGlowText(
                  text: data.titleGlow,
                  style: GoogleFonts.spaceGrotesk(
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
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
        ],
      ),
    );
  }

  Widget _buildVisual(BuildContext context, DefiThemeExtension defi) {
    switch (index) {
      case 0:
        return _SharedRolesVisual(defi: defi);
      case 1:
        return _RadarVisual(defi: defi);
      case 2:
        return _FareSplitVisual(defi: defi);
      case 3:
        return _SafetyVisual(defi: defi);
      default:
        return const SizedBox();
    }
  }
}

// ─── Page 1: No drivers / Just riders ────────────────────────

class _SharedRolesVisual extends StatefulWidget {
  final DefiThemeExtension defi;
  const _SharedRolesVisual({required this.defi});

  @override
  State<_SharedRolesVisual> createState() => _SharedRolesVisualState();
}

class _SharedRolesVisualState extends State<_SharedRolesVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _swapCtrl;

  @override
  void initState() {
    super.initState();
    _swapCtrl = AnimationController(vsync: this, duration: 900.ms)
      ..repeat(reverse: true);
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
          left: 108,
          top: 70,
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

class _RadarVisual extends StatefulWidget {
  final DefiThemeExtension defi;
  const _RadarVisual({required this.defi});

  @override
  State<_RadarVisual> createState() => _RadarVisualState();
}

class _RadarVisualState extends State<_RadarVisual>
    with TickerProviderStateMixin {
  late final List<AnimationController> _dotCtrls;

  @override
  void initState() {
    super.initState();
    _dotCtrls = List.generate(3, (i) {
      final ctrl = AnimationController(vsync: this, duration: 1500.ms);
      Future.delayed((i * 500).ms, () => ctrl.repeat());
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
            width: r * 2,
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

class _FareSplitVisual extends StatefulWidget {
  final DefiThemeExtension defi;
  const _FareSplitVisual({required this.defi});

  @override
  State<_FareSplitVisual> createState() => _FareSplitVisualState();
}

class _FareSplitVisualState extends State<_FareSplitVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _fareCtrl;

  @override
  void initState() {
    super.initState();
    _fareCtrl = AnimationController(vsync: this, duration: 2300.ms)..repeat();
  }

  @override
  void dispose() {
    _fareCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defi = widget.defi;
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
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: defi.fgMuted,
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
                      style: GoogleFonts.spaceGrotesk(
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

class _SafetyVisual extends StatelessWidget {
  final DefiThemeExtension defi;
  const _SafetyVisual({required this.defi});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SafetyItem(
        icon: Icons.verified_user,
        color: defi.success,
        label: 'Verified riders',
      ),
      _SafetyItem(
        icon: Icons.star,
        color: defi.warning,
        label: 'Community ratings',
      ),
      _SafetyItem(
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
                    .fadeIn(delay: (i * 150).ms, duration: 300.ms)
                    .slideX(begin: 0.15),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SafetyItem {
  final IconData icon;
  final Color color;
  final String label;

  const _SafetyItem({
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

// ─── Page indicator dots ─────────────────────────────────────

class _IntroDots extends StatelessWidget {
  final int count;
  final int index;

  const _IntroDots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: 250.ms,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive ? defi.gradientPrimary : null,
            color: isActive ? null : defi.border,
            borderRadius: BorderRadius.circular(9999),
          ),
        );
      }),
    );
  }
}
