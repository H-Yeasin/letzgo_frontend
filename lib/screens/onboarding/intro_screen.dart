import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/defi_theme_extension.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/defi/defi_button.dart';
import '../../widgets/defi/defi_grid_background.dart';
import 'widgets/intro_dots.dart';
import 'widgets/intro_page_content.dart';
import 'widgets/intro_page_data.dart';

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
    if (_page < introPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
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
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
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
                  itemCount: introPages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final data = introPages[index];
                    return IntroPageContent(data: data, index: index);
                  },
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Page dots
                    IntroDots(count: introPages.length, index: _page),
                    const SizedBox(height: 24),
                    // Next / Get Started
                    DefiButton(
                      label: _page == introPages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      fullWidth: true,
                      icon: _page == introPages.length - 1
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
