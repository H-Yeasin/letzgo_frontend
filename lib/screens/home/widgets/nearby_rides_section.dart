import 'package:flutter/material.dart';
import 'package:letzgo_app/constants/theme.dart';
import 'package:letzgo_app/models/ride_ping.dart';
import 'package:letzgo_app/widgets/ride_ping_card.dart';

class NearbyRidesSection extends StatelessWidget {
  final List<RidePing> nearbyPings;
  final List<RidePing> filteredNearby;
  final bool isLoading;
  final VoidCallback onFiltersPressed;
  final VoidCallback onSeeAll;
  final void Function(String id) onRideTap;

  const NearbyRidesSection({
    super.key,
    required this.nearbyPings,
    required this.filteredNearby,
    required this.isLoading,
    required this.onFiltersPressed,
    required this.onSeeAll,
    required this.onRideTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Rides',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: onFiltersPressed,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filters'),
                ),
                const SizedBox(width: 4),
                TextButton(onPressed: onSeeAll, child: const Text('See All')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading && nearbyPings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filteredNearby.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.explore_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nearbyPings.isEmpty
                        ? 'No nearby rides available'
                        : 'No nearby rides match the current filters',
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
          )
        else
          ...filteredNearby
              .take(3)
              .map(
                (ping) =>
                    RidePingCard(ping: ping, onTap: () => onRideTap(ping.id)),
              ),
      ],
    );
  }
}
