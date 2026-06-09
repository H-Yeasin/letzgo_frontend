import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letzgo_app/models/user.dart';
import '../../../constants/theme.dart';
import '../../../models/ride_ping.dart';

typedef MatchRequestAction =
    Future<void> Function(MatchRequest request, String action);

class RideStatusHeader extends StatelessWidget {
  const RideStatusHeader({
    super.key,
    required this.status,
    required this.expiresAt,
    required this.isExpired,
  });

  final String status;
  final DateTime expiresAt;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        StatusBadge(status: status),
        const SizedBox(width: 12),
        if (isExpired)
          const Text('Expired', style: TextStyle(color: AppTheme.errorColor))
        else
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppTheme.lightTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Expires ${DateFormat('h:mm a').format(expiresAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTextColor,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class RideRouteSummary extends StatelessWidget {
  const RideRouteSummary({
    super.key,
    required this.pickupLabel,
    required this.destinationLabel,
  });

  final String pickupLabel;
  final String destinationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Column(
          children: [
            _RouteDot(color: AppTheme.primaryColor),
            Container(
              width: 3,
              height: 60,
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            _RouteDot(color: AppTheme.secondaryColor),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RouteLabel(label: 'FROM', value: pickupLabel, theme: theme),
              const SizedBox(height: 24),
              _RouteLabel(label: 'TO', value: destinationLabel, theme: theme),
            ],
          ),
        ),
      ],
    );
  }
}

class RideFactsCard extends StatelessWidget {
  const RideFactsCard({super.key, required this.ping});

  final RidePing ping;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'Tk ',
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FactRow(
              label: 'Estimated Fare',
              value: currencyFormat.format(ping.estimatedFare),
              isHighlighted: true,
            ),
            const Divider(height: 24),
            _FactRow(
              label: 'Gender Preference',
              value: _genderLabel(ping.genderPreference),
            ),
            const Divider(height: 24),
            _FactRow(
              label: 'Passengers',
              value: '${ping.currentPassengers}/${ping.maxPassengers}',
            ),
          ],
        ),
      ),
    );
  }

  String _genderLabel(String value) => switch (value) {
    'male' => 'Male',
    'female' => 'Female',
    _ => 'Any',
  };
}

class MeetupPointCard extends StatelessWidget {
  const MeetupPointCard({super.key, required this.meetupPoint});

  final String meetupPoint;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag, color: AppTheme.primaryColor),
        title: const Text('Meetup Point'),
        subtitle: Text(meetupPoint),
      ),
    );
  }
}

class HostInfoCard extends StatelessWidget {
  const HostInfoCard({super.key, required this.host});

  final PublicUserProfile host;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text(
            host.name.isNotEmpty ? host.name[0].toUpperCase() : '?',
            style: const TextStyle(color: AppTheme.primaryColor),
          ),
        ),
        title: Text(host.name),
        subtitle: Text('${host.ratingAvg} rating'),
      ),
    );
  }
}

class JoinRequestsSection extends StatelessWidget {
  const JoinRequestsSection({
    super.key,
    required this.requests,
    required this.processingRequestIds,
    required this.onRespond,
  });

  final List<MatchRequest> requests;
  final Set<String> processingRequestIds;
  final MatchRequestAction onRespond;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join Requests',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          Text(
            'No pending requests yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTextColor,
            ),
          )
        else
          ...requests.map(
            (request) => _JoinRequestCard(
              request: request,
              isProcessing: processingRequestIds.contains(request.id),
              onRespond: onRespond,
            ),
          ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

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

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.request,
    required this.isProcessing,
    required this.onRespond,
  });

  final MatchRequest request;
  final bool isProcessing;
  final MatchRequestAction onRespond;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guest = request.guest;
    final displayName = guest?.name ?? 'Guest';
    final genderLabel = guest?.gender ?? '-';
    final rating = guest?.ratingAvg ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gender: $genderLabel | Rating: ${rating.toStringAsFixed(1)}',
                        style: theme.textTheme.bodySmall?.copyWith(
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
                        : () => onRespond(request, 'decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                    child: _RequestButtonLabel(
                      isProcessing: isProcessing,
                      label: 'Decline',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isProcessing
                        ? null
                        : () => onRespond(request, 'accept'),
                    child: _RequestButtonLabel(
                      isProcessing: isProcessing,
                      label: 'Accept',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestButtonLabel extends StatelessWidget {
  const _RequestButtonLabel({
    required this.isProcessing,
    required this.label,
    this.color,
  });

  final bool isProcessing;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return isProcessing
        ? SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        : Text(label);
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final valueStyle = isHighlighted
        ? const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.primaryColor,
          )
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _RouteDot extends StatelessWidget {
  const _RouteDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _RouteLabel extends StatelessWidget {
  const _RouteLabel({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
