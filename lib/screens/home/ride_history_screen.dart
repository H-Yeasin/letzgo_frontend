import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/theme.dart';
import '../../providers/match_provider.dart';
import '../../widgets/ride_ping_card.dart';

class RideHistoryScreen extends ConsumerStatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  ConsumerState<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends ConsumerState<RideHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchProvider.notifier).fetchMyMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final theme = Theme.of(context);

    final completedCancelled = matchState.myMatches
        .where((m) => m.status == 'completed' || m.status == 'cancelled')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(matchProvider.notifier).fetchMyMatches(),
        child: matchState.isLoading && completedCancelled.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : completedCancelled.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No ride history yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: completedCancelled.length,
                itemBuilder: (context, index) {
                  final match = completedCancelled[index];
                  if (match.ride == null) return const SizedBox.shrink();
                  return RidePingCard(ping: match.ride!, onTap: () {});
                },
              ),
      ),
    );
  }
}
