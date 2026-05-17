import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/theme.dart';
import '../../providers/match_provider.dart';
import '../../providers/auth_provider.dart';

class ActiveRideScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ActiveRideScreen({super.key, required this.matchId});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(matchProvider.notifier).getMatchDetails(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final match = matchState.activeMatch;
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

    if (matchState.isLoading && match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Ride')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Ride')),
        body: const Center(child: Text('No active ride')),
      );
    }

    final isHost = match.hostId == authState.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Ride'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => context.push('/chat/${match.id}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.statusOpen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.statusOpen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ride in progress',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.statusOpen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Route
          if (match.ride != null) ...[
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 60,
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.ride!.pickupLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        match.ride!.destinationLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Fare card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Fare', style: TextStyle(fontSize: 16)),
                  Text(
                    currencyFormat.format(match.ride?.estimatedFare ?? 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          if (isHost)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref
                      .read(matchProvider.notifier)
                      .completeMatch(
                        widget.matchId,
                        match.ride?.estimatedFare ?? 0,
                      );
                  if (mounted) {
                    context.push('/rating/${widget.matchId}');
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete Ride'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                ),
              ),
            ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancel Ride'),
                    content: const Text(
                      'Are you sure you want to cancel this ride?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('No'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Yes, Cancel'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await ref
                      .read(matchProvider.notifier)
                      .cancelMatch(widget.matchId);
                  if (mounted) context.go('/home');
                }
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Ride'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
