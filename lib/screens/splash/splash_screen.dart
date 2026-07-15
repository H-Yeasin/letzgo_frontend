import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/defi/defi_grid_background.dart';

/// Branded splash screen shown at app launch while auth + prefs hydrate.
/// Auto-navigates via the GoRouter redirect once [authProvider.isInitialized]
/// flips to true.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _timedOut = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _timedOut = true);
    });
    _checkAuth();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    try {
      await ref.read(onboardingPrefsProvider.notifier).load();
      await ref.read(authProvider.notifier).checkAuthStatus();
    } catch (_) {
      // Initialization errors are surfaced via the 15 s timeout.
    } finally {
      _timeoutTimer?.cancel();
      if (mounted && ref.read(authProvider).isInitialized) {
        setState(() => _timedOut = false);
      }
    }
    // GoRouter redirect handles navigation once isInitialized == true.
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    return Scaffold(
      backgroundColor: defi.bg,
      body: DefiGridBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ---- Icon with gradient glow ----
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: defi.gradientPrimary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: Colors.white,
                  size: 48,
                ),
              ).animate().scale(
                begin: const Offset(0.6, 0.6),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),

              const SizedBox(height: 28),

              // ---- "LetzGo" title with gold gradient ----
              Text(
                'LetzGo',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: defi.fg,
                ),
              ).animate().fadeIn(
                delay: 300.ms,
                duration: 500.ms,
              ).slideY(begin: 0.15),

              const SizedBox(height: 10),

              // ---- Tagline ----
              Text(
                'Micro-pooling for commuters',
                style: TextStyle(
                  fontSize: 15,
                  color: defi.fgMuted,
                  letterSpacing: 0.3,
                ),
              ).animate().fadeIn(
                delay: 500.ms,
                duration: 500.ms,
              ),

              const Spacer(flex: 2),

              // ---- Timeout / loading ----
              if (_timedOut)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        'Connection timed out.\nCheck that the backend server is running.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: defi.danger,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() => _timedOut = false);
                          _checkAuth();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: defi.fgMuted,
                    ),
                  ).animate(
                    // Only show the spinner after the initial entrance animation
                    // so the layout feels settled first.
                    delay: 600.ms,
                  ).fadeIn(),
                ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
