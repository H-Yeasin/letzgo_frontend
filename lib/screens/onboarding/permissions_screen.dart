import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/defi_theme_extension.dart';
import '../../providers/location_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/defi/defi_button.dart';
import '../../widgets/defi/defi_glass_card.dart';
import '../../widgets/defi/defi_grid_background.dart';

/// One-time onboarding screen asking for location permission, shown once
/// right after the welcome finale and before the rider reaches Home.
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _isRequesting = false;

  Future<void> _enable() async {
    setState(() => _isRequesting = true);
    await ref.read(locationProvider.notifier).refreshLocation();
    await _finish();
  }

  Future<void> _skip() async {
    await _finish();
  }

  Future<void> _finish() async {
    await ref.read(onboardingPrefsProvider.notifier).markPermissionsSeen();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    return Scaffold(
      backgroundColor: defi.bg,
      body: DefiGridBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefiGlassCard(
                  padding: const EdgeInsets.all(28),
                  borderRadius: 20,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: defi.gradientPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Find rides near you',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: defi.fg,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We need your location to find nearby rides and '
                        'help other riders find you.',
                        style: TextStyle(
                          fontSize: 15,
                          color: defi.fgMuted,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                DefiButton(
                  label: 'Enable Location',
                  fullWidth: true,
                  loading: _isRequesting,
                  onPressed: _isRequesting ? null : _enable,
                ),
                const SizedBox(height: 12),
                DefiButton(
                  label: 'Skip for now',
                  variant: DefiButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: _isRequesting ? null : _skip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
