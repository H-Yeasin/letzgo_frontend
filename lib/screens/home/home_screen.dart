import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ping_provider.dart';
import '../../widgets/ride_ping_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbyRides();
    });
  }

  void _loadNearbyRides() {
    ref
        .read(pingProvider.notifier)
        .fetchNearbyPings(lat: 23.8103, lng: 90.4125, radius: 2000.0);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final pingState = ref.watch(pingProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LetzGo'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: false,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadNearbyRides(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : 'U',
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
                        'Hello, ${user?.name ?? 'User'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Where are you heading?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                        '${user?.ratingAvg ?? 0.0}',
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

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.directions_car_filled,
                    label: 'Host a Ride',
                    color: AppTheme.primaryColor,
                    onTap: () => context.push('/host-ride'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.person_search,
                    label: 'Find a Ride',
                    color: AppTheme.secondaryColor,
                    onTap: () => context.push('/discover'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nearby rides section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Rides',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/discover'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nearby pings
            if (pingState.isLoading && pingState.nearbyPings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (pingState.nearbyPings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No nearby rides available',
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
              ...pingState.nearbyPings
                  .take(3)
                  .map(
                    (ping) => RidePingCard(
                      ping: ping,
                      onTap: () => context.push('/ride-details/${ping.id}'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
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
