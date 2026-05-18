import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/theme.dart';
import '../../providers/ping_provider.dart';
import '../../providers/match_provider.dart';
import '../../providers/auth_provider.dart';

class RideDetailsScreen extends ConsumerStatefulWidget {
  final String pingId;

  const RideDetailsScreen({super.key, required this.pingId});

  @override
  ConsumerState<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends ConsumerState<RideDetailsScreen> {
  bool _hasLoadedRequests = false;
  final Set<String> _processingRequestIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pingProvider.notifier).getPingDetails(widget.pingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final matchState = ref.watch(matchProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);
    final ping = pingState.selectedPing;

    if (pingState.isLoading && ping == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (ping == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ride Details')),
        body: const Center(child: Text('Ride not found')),
      );
    }

    final isHost = ping.hostId == authState.user?.id;
    final isExpired = ping.expiresAt.isBefore(DateTime.now());
    final hasRequested = matchState.requestedRideIds.contains(ping.id);

    if (isHost && !_hasLoadedRequests) {
      _hasLoadedRequests = true;
      Future.microtask(() {
        ref.read(matchProvider.notifier).fetchPendingRequests(widget.pingId);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Status & expiry
          Row(
            children: [
              _StatusBadge(status: ping.status),
              const SizedBox(width: 12),
              if (!isExpired)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.lightTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires ${DateFormat('h:mm a').format(ping.expiresAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Expired',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Route
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
                      'FROM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ping.pickupLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'TO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ping.destinationLabel,
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

          // Meetup point
          if (ping.meetupPoint != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.flag, color: AppTheme.primaryColor),
                title: const Text('Meetup Point'),
                subtitle: Text(ping.meetupPoint!),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Fare & details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Fare'),
                      Text(
                        currencyFormat.format(ping.estimatedFare),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gender Preference'),
                      Text(
                        ping.genderPreference == 'any'
                            ? 'Any'
                            : ping.genderPreference == 'male'
                            ? 'Male'
                            : 'Female',
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Passengers'),
                      Text('${ping.currentPassengers}/${ping.maxPassengers}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Host info
          if (ping.host != null)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    ping.host!.name.isNotEmpty
                        ? ping.host!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                title: Text(ping.host!.name),
                subtitle: Text('${ping.host!.ratingAvg} ⭐'),
              ),
            ),

          if (matchState.error != null) ...[
            const SizedBox(height: 16),
            Text(
              matchState.error!,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ],

          if (isHost) ...[
            const SizedBox(height: 24),
            Text(
              'Join Requests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (matchState.pendingRequests.isEmpty)
              Text(
                'No pending requests yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextColor,
                ),
              )
            else
              ...matchState.pendingRequests.map((request) {
                final guest = request.guest;
                final displayName = guest?.name ?? 'Guest';
                final genderLabel = guest?.gender ?? '—';
                final rating = guest?.ratingAvg ?? 0.0;
                final isProcessing =
                    _processingRequestIds.contains(request.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              child: Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Gender: $genderLabel • Rating: ${rating.toStringAsFixed(1)}',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.lightTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () async {
                                        setState(() {
                                          _processingRequestIds.add(
                                            request.id,
                                          );
                                        });
                                        try {
                                          final success = await ref
                                              .read(matchProvider.notifier)
                                              .respondToRequest(
                                                request.id,
                                                'decline',
                                              );
                                          if (success) {
                                            await ref
                                                .read(pingProvider.notifier)
                                                .getPingDetails(
                                                  widget.pingId,
                                                );
                                            await ref
                                                .read(matchProvider.notifier)
                                                .fetchPendingRequests(
                                                  widget.pingId,
                                                );
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Request declined'),
                                                ),
                                              );
                                            }
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _processingRequestIds.remove(
                                                request.id,
                                              );
                                            });
                                          }
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.errorColor,
                                ),
                                child: isProcessing
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: isProcessing
                                    ? null
                                    : () async {
                                        setState(() {
                                          _processingRequestIds.add(
                                            request.id,
                                          );
                                        });
                                        try {
                                          final success = await ref
                                              .read(matchProvider.notifier)
                                              .respondToRequest(
                                                request.id,
                                                'accept',
                                              );
                                          if (success) {
                                            await ref
                                                .read(pingProvider.notifier)
                                                .getPingDetails(
                                                  widget.pingId,
                                                );
                                            await ref
                                                .read(matchProvider.notifier)
                                                .fetchPendingRequests(
                                                  widget.pingId,
                                                );
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('Request accepted'),
                                                  backgroundColor:
                                                      AppTheme.successColor,
                                                ),
                                              );
                                            }
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _processingRequestIds.remove(
                                                request.id,
                                              );
                                            });
                                          }
                                        }
                                      },
                                child: isProcessing
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Accept'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],

          const SizedBox(height: 24),

          // Action buttons
          if (!isHost && ping.status == 'open' && !isExpired)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: matchState.isLoading || hasRequested
                    ? null
                    : () async {
                        final success = await ref
                            .read(matchProvider.notifier)
                            .requestMatch(widget.pingId);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Match request sent!'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                          context.pop();
                        }
                      },
                icon: matchState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(hasRequested ? Icons.check_circle : Icons.handshake),
                label: Text(
                  hasRequested ? 'Request Sent' : 'Request to Join',
                ),
              ),
            ),

          if (isHost && ping.status == 'open')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(pingProvider.notifier)
                      .cancelPing(widget.pingId);
                  if (mounted) context.pop();
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.statusOpen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.statusOpen,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
