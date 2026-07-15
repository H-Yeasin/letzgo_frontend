import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/defi/defi_badge.dart';
import '../../widgets/defi/defi_button.dart';
import '../../widgets/defi/defi_glow_text.dart';
import '../../widgets/defi/defi_grid_background.dart';
import '../../widgets/defi/defi_initials_avatar.dart';
import '../../widgets/defi/defi_ping_indicator.dart';

/// "Welcome aboard" finale shown once after profile completion.
/// Auto-advances to [/home] after ~3.2 s, or the user can tap Start exploring.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3200), _goHome);
  }

  void _goHome() {
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    final authState = ref.watch(authProvider);
    final prefs = ref.watch(onboardingPrefsProvider);

    final name = authState.user?.name.trim() ?? '';
    final firstName =
        name.isNotEmpty ? name.split(RegExp(r'\s+')).first : 'rider';
    final avatarStyle = prefs.avatarStyle;
    final intent = prefs.rideIntent;

    String intentTagline;
    switch (intent) {
      case RideIntent.host:
        intentTagline = 'Ready to host your first ride?';
      case RideIntent.join:
        intentTagline = 'Riders nearby are ready when you are.';
      case RideIntent.both:
      case null:
        intentTagline = 'Host it or join it — every trip is yours.';
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: defi.bg,
        body: DefiGridBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // Celebration stack
                  SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Confetti sparks — code-drawn circles/squares that
                        // burst outward from the avatar on entry.
                        ..._buildConfetti(defi),
                        // Ambient ping indicators
                        Positioned(
                          top: 12,
                          left: 40,
                          child: DefiPingIndicator(
                            size: 8,
                            color: defi.info,
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 36,
                          child: DefiPingIndicator(
                            size: 6,
                            color: defi.success,
                          ),
                        ),
                        // Avatar
                        DefiInitialsAvatar(
                          name: name.isNotEmpty ? name : 'You',
                          styleIndex: avatarStyle,
                          size: 104,
                        ).animate().scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Badge
                  const DefiBadge(
                    label: 'PROFILE COMPLETE',
                    variant: DefiBadgeVariant.success,
                    pulse: true,
                  ).animate().fadeIn(
                    delay: 300.ms,
                    duration: 300.ms,
                  ),

                  const SizedBox(height: 20),

                  // Welcome text
                  DefiGlowText(
                    text: 'Welcome aboard,\n$firstName!',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(
                    delay: 450.ms,
                    duration: 400.ms,
                  ).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  // Intent-personalized tagline
                  Text(
                    intentTagline,
                    style: TextStyle(
                      fontSize: 15,
                      color: defi.fgMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(
                    delay: 600.ms,
                    duration: 400.ms,
                  ),

                  const Spacer(),

                  // Start exploring button
                  DefiButton(
                    label: 'Start exploring',
                    fullWidth: true,
                    icon: Icons.arrow_forward,
                    onPressed: _goHome,
                  ).animate().fadeIn(
                    delay: 800.ms,
                    duration: 400.ms,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfetti(DefiThemeExtension defi) {
    final colors = [
      AppColors.primary,
      AppColors.tertiary,
      AppColors.secondary,
      defi.info,
      defi.success,
    ];
    const sparkCount = 10;
    return List.generate(sparkCount, (i) {
      final angle = (i / sparkCount) * math.pi * 2;
      final distance = 50.0 + (i % 3) * 20.0;
      final endX = math.cos(angle) * distance;
      final endY = math.sin(angle) * distance;
      final color = colors[i % colors.length];
      final isSquare = i.isEven;

      return Positioned(
        // Place at center of the 160×160 box; animate from there.
        left: 80 - (isSquare ? 4 : 3),
        top: 80 - (isSquare ? 4 : 3),
        child: Container(
          width: isSquare ? 8 : 6,
          height: isSquare ? 8 : 6,
          decoration: BoxDecoration(
            color: color,
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isSquare ? BorderRadius.circular(1) : null,
          ),
        ).animate(
          delay: (i * 40).ms,
        ).fadeIn(
          duration: 150.ms,
        ).move(
          begin: const Offset(0, 0),
          end: Offset(endX, endY),
          duration: 700.ms,
          curve: Curves.easeOutCubic,
        ).fadeOut(
          delay: 450.ms,
          duration: 300.ms,
        ),
      );
    });
  }
}
