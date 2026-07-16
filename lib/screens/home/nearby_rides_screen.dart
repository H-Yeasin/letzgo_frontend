import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/location_provider.dart';
import '../../providers/ping_provider.dart';
import '../../widgets/ride_ping_card.dart';

/// Full list of nearby rides — the "See All" target from the home screen.
/// Displays every active ping already loaded in [pingProvider]; pull to
/// refresh re-fetches with the same radius/gender filters the home screen
/// was using when it navigated here.
class NearbyRidesScreen extends ConsumerWidget {
  final double radiusMeters;
  final String? gender;

  const NearbyRidesScreen({
    super.key,
    required this.radiusMeters,
    this.gender,
  });

  Future<void> _refresh(WidgetRef ref) async {
    final location = ref.read(locationProvider);
    final lat = location.latitude;
    final lng = location.longitude;
    if (lat == null || lng == null) return;
    await ref.read(pingProvider.notifier).fetchNearbyPings(
          lat: lat,
          lng: lng,
          radius: radiusMeters,
          gender: gender,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pingState = ref.watch(pingProvider);
    final now = DateTime.now();
    const activeStatuses = {'open', 'matched'};
    final rides = pingState.nearbyPings
        .where(
          (ping) =>
              activeStatuses.contains(ping.status) &&
              ping.expiresAt.isAfter(now),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Rides')),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: pingState.isLoading && rides.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : rides.isEmpty
                ? ListView(
                    // ListView keeps pull-to-refresh working on the empty state.
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 96),
                        child: Column(
                          children: [
                            Icon(
                              Icons.explore_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No nearby rides available',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pull down to refresh or host a ride!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: rides.length,
                    itemBuilder: (context, index) {
                      final ping = rides[index];
                      return RidePingCard(
                        ping: ping,
                        onTap: () => context.push('/ride-details/${ping.id}'),
                      );
                    },
                  ),
      ),
    );
  }
}
