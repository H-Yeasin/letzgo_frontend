import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';
import '../../providers/ping_provider.dart';
import '../../widgets/ride_ping_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    _loadNearbyPings();
  }

  void _loadNearbyPings() {
    // In production, get user's actual location
    ref
        .read(pingProvider.notifier)
        .fetchNearbyPings(lat: 23.8103, lng: 90.4125, radius: 2000.0);
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Rides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyPings,
          ),
          IconButton(
            icon: Badge(isLabelVisible: false, child: const Icon(Icons.tune)),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadNearbyPings(),
        child: pingState.isLoading && pingState.nearbyPings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : pingState.nearbyPings.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No rides found nearby',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try expanding your search radius or host a ride!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.push('/host-ride'),
                        icon: const Icon(Icons.add),
                        label: const Text('Host a Ride'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pingState.nearbyPings.length,
                itemBuilder: (context, index) {
                  final ping = pingState.nearbyPings[index];
                  return RidePingCard(
                    ping: ping,
                    onTap: () => context.push('/ride-details/${ping.id}'),
                  );
                },
              ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Rides',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Gender Preference'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Any', 'Male', 'Female']
                  .map(
                    (g) => FilterChip(
                      label: Text(g),
                      selected: true,
                      onSelected: (_) {},
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('Max Fare'),
            const SizedBox(height: 8),
            const Slider(value: 5000, max: 5000, onChanged: null),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
