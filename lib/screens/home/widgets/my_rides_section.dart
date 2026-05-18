import 'package:flutter/material.dart';
import 'package:letzgo_app/constants/theme.dart';
import 'package:letzgo_app/models/ride_ping.dart';
import 'package:letzgo_app/widgets/ride_ping_card.dart';

class MyRidesSection extends StatelessWidget {
  final List<RidePing> activeRides;
  final void Function(String id) onRideTap;

  const MyRidesSection({
    super.key,
    required this.activeRides,
    required this.onRideTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (activeRides.isNotEmpty) ...[
          Text(
            'Your Rides',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...activeRides
              .take(3)
              .map(
                (ping) =>
                    RidePingCard(ping: ping, onTap: () => onRideTap(ping.id)),
              ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active rides yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Host a ride to get started!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
