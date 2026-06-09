import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/theme.dart';
import '../../models/ride_ping.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';
import '../../providers/ping_provider.dart';
import 'widgets/ride_details_sections.dart';

class RideDetailsScreen extends ConsumerStatefulWidget {
  const RideDetailsScreen({super.key, required this.pingId});

  final String pingId;

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

  Future<void> _respondToRequest(MatchRequest request, String action) async {
    setState(() => _processingRequestIds.add(request.id));
    try {
      final success = await ref
          .read(matchProvider.notifier)
          .respondToRequest(request.id, action);
      if (!success) return;

      await ref.read(pingProvider.notifier).getPingDetails(widget.pingId);
      await ref.read(matchProvider.notifier).fetchPendingRequests(widget.pingId);
      if (!mounted) return;

      final isAccepted = action == 'accept';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${isAccepted ? 'accepted' : 'declined'}'),
          backgroundColor: isAccepted ? AppTheme.successColor : null,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processingRequestIds.remove(request.id));
      }
    }
  }

  Future<void> _requestToJoin() async {
    final success =
        await ref.read(matchProvider.notifier).requestMatch(widget.pingId);
    if (!success || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Match request sent!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
    context.pop();
  }

  Future<void> _cancelRide() async {
    await ref.read(pingProvider.notifier).cancelPing(widget.pingId);
    if (mounted) context.pop();
  }

  void _loadHostRequestsIfNeeded(bool isHost) {
    if (!isHost || _hasLoadedRequests) return;
    _hasLoadedRequests = true;
    Future.microtask(() {
      ref.read(matchProvider.notifier).fetchPendingRequests(widget.pingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final matchState = ref.watch(matchProvider);
    final authState = ref.watch(authProvider);
    final ping = pingState.selectedPing;

    if (pingState.isLoading && ping == null) {
      return const _RideDetailsScaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (ping == null) {
      return const _RideDetailsScaffold(child: Center(child: Text('Ride not found')));
    }

    final isHost = ping.hostId == authState.user?.id;
    final isExpired = ping.expiresAt.isBefore(DateTime.now());
    final hasRequested = matchState.requestedRideIds.contains(ping.id);
    _loadHostRequestsIfNeeded(isHost);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          RideStatusHeader(
            status: ping.status,
            expiresAt: ping.expiresAt,
            isExpired: isExpired,
          ),
          const SizedBox(height: 24),
          RideRouteSummary(
            pickupLabel: ping.pickupLabel,
            destinationLabel: ping.destinationLabel,
          ),
          const SizedBox(height: 24),
          if (ping.meetupPoint != null) ...[
            MeetupPointCard(meetupPoint: ping.meetupPoint!),
            const SizedBox(height: 16),
          ],
          RideFactsCard(ping: ping),
          const SizedBox(height: 16),
          if (ping.host != null) HostInfoCard(host: ping.host!),
          if (matchState.error != null) ...[
            const SizedBox(height: 16),
            Text(
              matchState.error!,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ],
          if (isHost) ...[
            const SizedBox(height: 24),
            JoinRequestsSection(
              requests: matchState.pendingRequests,
              processingRequestIds: _processingRequestIds,
              onRespond: _respondToRequest,
            ),
          ],
          const SizedBox(height: 24),
          _RideActionButton(
            isHost: isHost,
            isExpired: isExpired,
            hasRequested: hasRequested,
            pingStatus: ping.status,
            isLoading: matchState.isLoading,
            onRequestToJoin: _requestToJoin,
            onCancelRide: _cancelRide,
          ),
        ],
      ),
    );
  }
}

class _RideDetailsScaffold extends StatelessWidget {
  const _RideDetailsScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Ride Details')), body: child);
  }
}

class _RideActionButton extends StatelessWidget {
  const _RideActionButton({
    required this.isHost,
    required this.isExpired,
    required this.hasRequested,
    required this.pingStatus,
    required this.isLoading,
    required this.onRequestToJoin,
    required this.onCancelRide,
  });

  final bool isHost;
  final bool isExpired;
  final bool hasRequested;
  final String pingStatus;
  final bool isLoading;
  final VoidCallback onRequestToJoin;
  final VoidCallback onCancelRide;

  @override
  Widget build(BuildContext context) {
    if (!isHost && pingStatus == 'open' && !isExpired) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isLoading || hasRequested ? null : onRequestToJoin,
          icon: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(hasRequested ? Icons.check_circle : Icons.handshake),
          label: Text(hasRequested ? 'Request Sent' : 'Request to Join'),
        ),
      );
    }

    if (isHost && pingStatus == 'open') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onCancelRide,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Ride'),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
