import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';
import '../../models/ride_ping.dart';
import '../../providers/ping_provider.dart';
import '../../widgets/ride_ping_card.dart';

class MyRidesScreen extends ConsumerStatefulWidget {
  const MyRidesScreen({super.key});

  @override
  ConsumerState<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends ConsumerState<MyRidesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isDeletingExpired = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pingProvider.notifier).fetchMyPings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final theme = Theme.of(context);
    final activeStatuses = {'open', 'matched'};
    final activeRides = pingState.myPings
        .where((ping) => activeStatuses.contains(ping.status))
        .toList();
    final pastRides = pingState.myPings
        .where((ping) => !activeStatuses.contains(ping.status))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeRides.length})'),
            Tab(text: 'Past (${pastRides.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.read(pingProvider.notifier).fetchMyPings(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRideList(
              activeRides,
              pingState,
              'No active rides yet',
              theme,
            ),
            _buildRideList(
              pastRides,
              pingState,
              'No past rides yet',
              theme,
              showDeleteExpiredAction: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideList(
    List<RidePing> list,
    PingState pingState,
    String emptyText,
    ThemeData theme,
    {bool showDeleteExpiredAction = false}
  ) {
    if (pingState.isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
      );
    }

    final headerCount = showDeleteExpiredAction ? 1 : 0;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length + headerCount,
      itemBuilder: (context, index) {
        if (headerCount == 1 && index == 0) {
          return _buildDeleteExpiredButton(context, theme);
        }

        final ping = list[index - headerCount];
        return RidePingCard(
          ping: ping,
          onTap: () => context.push('/ride-details/${ping.id}'),
        );
      },
    );
  }

  Widget _buildDeleteExpiredButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: _isDeletingExpired ? null : () => _deleteExpiredRides(context),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isDeletingExpired)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              else
                const Icon(Icons.delete_outline, size: 18),
              const SizedBox(width: 8),
              Text(
                _isDeletingExpired ? 'Deleting expired rides' : 'Delete expired rides',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteExpiredRides(BuildContext context) async {
    if (_isDeletingExpired) {
      return;
    }

    setState(() => _isDeletingExpired = true);
    final deleted = await ref.read(pingProvider.notifier).deleteExpiredPings();
    if (!mounted) {
      return;
    }

    setState(() => _isDeletingExpired = false);

    final message = deleted == null
        ? 'Failed to delete expired rides. Please try again.'
        : deleted > 0
            ? 'Deleted $deleted expired ride${deleted == 1 ? '' : 's'}.'
            : 'No expired rides to delete.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
