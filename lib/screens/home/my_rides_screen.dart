import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/theme.dart';
import '../../providers/match_provider.dart';
import '../../widgets/ride_ping_card.dart';
import '../../models/ride_ping.dart' as models;

class MyRidesScreen extends ConsumerStatefulWidget {
  const MyRidesScreen({super.key});

  @override
  ConsumerState<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends ConsumerState<MyRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchProvider.notifier).fetchMyMatches();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final theme = Theme.of(context);

    final activeMatches = matchState.myMatches
        .where((m) => m.status == 'in_progress')
        .toList();
    final pendingMatches = matchState.myMatches
        .where((m) => m.status == 'matched')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active (${activeMatches.length})'),
            Tab(text: 'Pending (${pendingMatches.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRideList(activeMatches, matchState, 'No active rides', theme),
          _buildRideList(
            pendingMatches,
            matchState,
            'No pending requests',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildRideList(
    List list,
    MatchState matchState,
    String emptyText,
    ThemeData theme,
  ) {
    if (matchState.isLoading && list.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final match = list[index];
        if (match.ride == null) return const SizedBox.shrink();
        return RidePingCard(
          ping: match.ride!,
          showActions: true,
          onTap: () => _onRideTap(match),
        );
      },
    );
  }

  void _onRideTap(models.Match match) {
    // Navigate based on match status
    if (match.status == 'in_progress' && mounted) {
      Navigator.of(context).pushNamed('/active-ride/${match.id}');
    } else if (match.status == 'matched' && mounted) {
      Navigator.of(context).pushNamed('/chat/${match.id}');
    }
  }
}
