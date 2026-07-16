import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/defi_theme_extension.dart';
import '../../../widgets/defi/defi_glow_text.dart';
import '../host_ride_draft_provider.dart';
import '../widgets/selection_chip.dart';

/// Step 4 — passenger seats, who can join, and how long the ping lives.
class PreferencesStep extends ConsumerWidget {
  const PreferencesStep({super.key});

  static const _expiryOptions = [
    (15, '15m'),
    (30, '30m'),
    (45, '45m'),
    (60, '1h'),
    (120, '2h'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defi = context.defi;
    final draft = ref.watch(hostRideDraftProvider);
    final notifier = ref.read(hostRideDraftProvider.notifier);

    final sections = <Widget>[
      _Section(
        title: 'Passenger seats',
        subtitle: 'How many riders can hop in?',
        child: Row(
          children: List.generate(5, (i) {
            final count = i + 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 4 ? 8 : 0),
                child: SelectionChip(
                  label: '$count',
                  isSelected: draft.maxPassengers == count,
                  onTap: () => notifier.setMaxPassengers(count),
                ),
              ),
            );
          }),
        ),
      ),
      _Section(
        title: 'Who can join?',
        subtitle: 'Set a gender preference for this ride.',
        child: Row(
          children: [
            _PreferenceCard(
              label: 'Anyone',
              icon: Icons.groups_outlined,
              isSelected: draft.genderPreference == 'any',
              onTap: () => notifier.setGenderPreference('any'),
            ),
            const SizedBox(width: 12),
            _PreferenceCard(
              label: 'Men only',
              icon: Icons.male,
              isSelected: draft.genderPreference == 'male',
              onTap: () => notifier.setGenderPreference('male'),
            ),
            const SizedBox(width: 12),
            _PreferenceCard(
              label: 'Women only',
              icon: Icons.female,
              isSelected: draft.genderPreference == 'female',
              onTap: () => notifier.setGenderPreference('female'),
            ),
          ],
        ),
      ),
      _Section(
        title: 'Ping lifetime',
        subtitle: 'Your ride disappears from the map after this.',
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _expiryOptions.map((option) {
            final (minutes, label) = option;
            return SelectionChip(
              label: label,
              icon: Icons.schedule,
              isSelected: draft.expiresInMinutes == minutes,
              onTap: () => notifier.setExpiry(minutes),
            );
          }).toList(),
        ),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DefiGlowText(
            text: 'Your ride, your rules',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fine-tune who joins and for how long the offer stands.',
            style: TextStyle(fontSize: 14, color: defi.fgMuted),
          ),
          const SizedBox(height: 28),
          ...List.generate(sections.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: sections[i]
                  .animate()
                  .fadeIn(delay: (i * 90).ms, duration: 300.ms)
                  .slideY(begin: 0.08),
            );
          }),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: defi.fg,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: defi.fgMuted),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Vertical icon + label card, matching the profile setup gender chips.
class _PreferenceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PreferenceCard({
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
            color: isSelected ? defi.bg : defi.surface,
            borderRadius: BorderRadius.circular(12),
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
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : defi.fgMuted,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : defi.fgMuted,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
