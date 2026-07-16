import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letzgo_app/constants/theme.dart';
import 'package:letzgo_app/providers/onboarding_provider.dart';

class HomeHeader extends ConsumerWidget {
  final String displayName;
  final String initial;
  final double rating;
  final RideIntent? rideIntent;
  final VoidCallback onHostRide;
  final VoidCallback onFindRide;

  const HomeHeader({
    super.key,
    required this.displayName,
    required this.initial,
    required this.rating,
    this.rideIntent,
    required this.onHostRide,
    required this.onFindRide,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    String subtitle;
    switch (rideIntent) {
      case RideIntent.host:
        subtitle = 'Ready to host your next ride?';
      case RideIntent.join:
        subtitle = 'Find a ride heading your way';
      case RideIntent.both:
      case null:
        subtitle = 'Where are you heading?';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $displayName',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.directions_car_filled,
                label: 'Host a Ride',
                color: AppTheme.primaryColor,
                onTap: onHostRide,
                emphasized: rideIntent == RideIntent.host,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.person_search,
                label: 'Find a Ride',
                color: AppTheme.secondaryColor,
                onTap: onFindRide,
                emphasized: rideIntent == RideIntent.join,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool emphasized;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: emphasized ? 0.18 : 0.1,
          ),
          borderRadius: BorderRadius.circular(16),
          border: emphasized
              ? Border.all(color: color.withValues(alpha: 0.5))
              : null,
          boxShadow: emphasized
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
