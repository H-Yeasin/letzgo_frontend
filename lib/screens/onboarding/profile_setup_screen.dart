import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/defi/defi_badge.dart';
import '../../widgets/defi/defi_button.dart';
import '../../widgets/defi/defi_glow_text.dart';
import '../../widgets/defi/defi_grid_background.dart';
import '../../widgets/defi/defi_initials_avatar.dart';
import '../../widgets/defi/defi_input.dart';

/// Multi-step "Join the community" profile setup (replaces the old
/// single-step auth version). Presented as an internal PageView driven
/// by Continue buttons — no swipe, one step at a time.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _pageController = PageController();
  int _step = 0;
  String? _gender;
  var _avatarStyle = 0;
  var _intent = RideIntent.both;
  var _nameValid = false;

  static const _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final valid = _nameController.text.trim().length >= 2;
    if (valid != _nameValid) {
      setState(() => _nameValid = valid);
    }
  }

  void _back() {
    if (_step > 0) {
      _pageController.previousPage(
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _pageController.nextPage(
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    // Persist local choices before the API call
    final prefs = ref.read(onboardingPrefsProvider.notifier);
    await prefs.setRideIntent(_intent);
    await prefs.setAvatarStyle(_avatarStyle);

    await ref.read(authProvider.notifier).completeProfile(
          name: _nameController.text.trim(),
          gender: _gender,
          // avatarUrl intentionally omitted — the app uses initials
        );

    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated && auth.error == null &&
        (auth.user?.isOnboardingComplete ?? false)) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    final authState = ref.watch(authProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _back();
      },
      child: Scaffold(
        backgroundColor: defi.bg,
        body: DefiGridBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      if (_step > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: defi.fg,
                          onPressed: _back,
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      Expanded(
                        child: _StepProgressBar(
                          step: _step,
                          total: _totalSteps,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_step + 1} / $_totalSteps',
                        style: TextStyle(
                          color: defi.fgMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Step body
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _step = i),
                    children: [
                      _NameStep(
                        controller: _nameController,
                        valid: _nameValid,
                      ),
                      _IdentityStep(
                        name: _nameController.text.trim(),
                        gender: _gender,
                        avatarStyle: _avatarStyle,
                        onGenderChanged: (g) => setState(() => _gender = g),
                        onAvatarChanged: (s) => setState(() => _avatarStyle = s),
                      ),
                      _IntentStep(
                        intent: _intent,
                        onChanged: (i) => setState(() => _intent = i),
                      ),
                    ],
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      if (authState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            authState.error!,
                            style: TextStyle(
                              color: defi.danger,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      DefiButton(
                        label: _step < _totalSteps - 1
                            ? 'Continue'
                            : 'Join the community',
                        fullWidth: true,
                        loading: _step == _totalSteps - 1 && authState.isLoading,
                        onPressed: _step < _totalSteps - 1
                            ? _next
                            : (_nameValid ? _submit : null),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step progress bar ───────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int step;
  final int total;
  const _StepProgressBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Row(
      children: List.generate(total, (i) {
        final isFilled = i <= step;
        return Expanded(
          child: AnimatedContainer(
            duration: 300.ms,
            height: 4,
            margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
            decoration: BoxDecoration(
              gradient: isFilled ? defi.gradientPrimary : null,
              color: isFilled ? null : defi.border,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Step 1: Name ────────────────────────────────────────────

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final bool valid;

  const _NameStep({required this.controller, required this.valid});

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefiGlowText(
            text: 'What should riders\ncall you?',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is how you\'ll appear to the community.',
            style: TextStyle(
              fontSize: 15,
              color: defi.fgMuted,
            ),
          ),
          const SizedBox(height: 32),
          DefiInput(
            controller: controller,
            labelText: 'Full name',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {}, // validation lives in the parent
          ),
          if (!valid && controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Name must be at least 2 characters',
                style: TextStyle(
                  color: defi.danger,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06),
    );
  }
}

// ─── Step 2: Gender + avatar style ───────────────────────────

class _IdentityStep extends StatelessWidget {
  final String name;
  final String? gender;
  final int avatarStyle;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<int> onAvatarChanged;

  const _IdentityStep({
    required this.name,
    required this.gender,
    required this.avatarStyle,
    required this.onGenderChanged,
    required this.onAvatarChanged,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefiGlowText(
            text: 'Make it yours',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),

          // Avatar preview
          Center(
            child: Animate(
              key: ValueKey(avatarStyle),
              effects: [
                ScaleEffect(
                  begin: const Offset(0.85, 0.85),
                  curve: Curves.easeOutBack,
                  duration: 300.ms,
                ),
              ],
              child: DefiInitialsAvatar(
                name: name.isNotEmpty ? name : 'You',
                styleIndex: avatarStyle,
                size: 96,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Style swatches
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                DefiInitialsAvatar.palette.length,
                (i) {
                  final gradient = DefiInitialsAvatar.palette[i]
                      as LinearGradient;
                  final isSelected = i == avatarStyle;
                  return GestureDetector(
                    onTap: () => onAvatarChanged(i),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: defi.primaryGlow,
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Gender label
          Row(
            children: [
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: defi.fg,
                ),
              ),
              const SizedBox(width: 8),
              const DefiBadge(
                label: 'OPTIONAL',
                variant: DefiBadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Helps riders set per-ride preferences — like women-only rides.',
            style: TextStyle(fontSize: 12, color: defi.fgMuted),
          ),
          const SizedBox(height: 12),

          // Gender chips
          Row(
            children: [
              _GenderChip(
                label: 'Male',
                icon: Icons.male,
                isSelected: gender == 'male',
                onTap: () =>
                    onGenderChanged(gender == 'male' ? null : 'male'),
              ),
              const SizedBox(width: 12),
              _GenderChip(
                label: 'Female',
                icon: Icons.female,
                isSelected: gender == 'female',
                onTap: () =>
                    onGenderChanged(gender == 'female' ? null : 'female'),
              ),
              const SizedBox(width: 12),
              _GenderChip(
                label: 'Other',
                icon: Icons.transgender,
                isSelected: gender == 'other',
                onTap: () =>
                    onGenderChanged(gender == 'other' ? null : 'other'),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? defi.bg
                : defi.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : defi.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : defi.fgMuted,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : defi.fgMuted,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 3: Ride intent ─────────────────────────────────────

class _IntentStep extends StatelessWidget {
  final RideIntent intent;
  final ValueChanged<RideIntent> onChanged;

  const _IntentStep({required this.intent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    final cards = [
      _IntentCardData(
        intent: RideIntent.host,
        icon: Icons.directions_car_filled,
        title: 'I usually host rides',
        subtitle: 'I have a vehicle or\nroute to share',
      ),
      _IntentCardData(
        intent: RideIntent.join,
        icon: Icons.hail,
        title: 'I usually hop into rides',
        subtitle: 'I look for rides\nheading my way',
      ),
      _IntentCardData(
        intent: RideIntent.both,
        icon: Icons.swap_horiz,
        title: 'I\'ll decide trip by trip',
        subtitle: 'No fixed role\n— the LetzGo way',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefiGlowText(
            text: 'How will you ride?',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No fixed roles on LetzGo — every rider can do both.\n'
            'This helps us tailor your home screen.',
            style: TextStyle(fontSize: 14, color: defi.fgMuted, height: 1.4),
          ),
          const SizedBox(height: 24),
          ...List.generate(cards.length, (i) {
            final data = cards[i];
            final isSelected = intent == data.intent;
            return Padding(
              padding: EdgeInsets.only(bottom: i < cards.length - 1 ? 12 : 0),
              child: _IntentCard(
                data: data,
                isSelected: isSelected,
                onTap: () => onChanged(data.intent),
              ).animate().fadeIn(
                delay: (i * 100).ms,
                duration: 300.ms,
              ).slideX(begin: 0.1),
            );
          }),
        ],
      ),
    );
  }
}

class _IntentCardData {
  final RideIntent intent;
  final IconData icon;
  final String title;
  final String subtitle;

  const _IntentCardData({
    required this.intent,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _IntentCard extends StatelessWidget {
  final _IntentCardData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntentCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: defi.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : defi.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: defi.primaryGlow,
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              data.icon,
              color: isSelected ? AppColors.primary : defi.fgMuted,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: defi.fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: defi.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (data.intent == RideIntent.both)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DefiBadge(
                  label: 'THE LETZGO WAY',
                  variant: DefiBadgeVariant.info,
                ),
              ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : defi.border,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
