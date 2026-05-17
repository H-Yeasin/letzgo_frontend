import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../models/ride_ping.dart';

class RidePingCard extends StatelessWidget {
  final RidePing ping;
  final VoidCallback? onTap;
  final bool showActions;

  const RidePingCard({
    super.key,
    required this.ping,
    this.onTap,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge & time
              Row(
                children: [
                  _StatusBadge(status: ping.status),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.lightTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(ping.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Route: Pickup → Destination
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 30,
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ping.pickupLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ping.destinationLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Host info & Fare
              Row(
                children: [
                  if (ping.host != null) ...[
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        ping.host!.name.isNotEmpty
                            ? ping.host!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ping.host!.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: AppTheme.lightTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${ping.availableSeats}/${ping.maxPassengers}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    currencyFormat.format(ping.estimatedFare),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'open':
        bgColor = AppTheme.statusOpen.withValues(alpha: 0.1);
        textColor = AppTheme.statusOpen;
        label = 'Open';
        break;
      case 'matched':
        bgColor = AppTheme.statusMatched.withValues(alpha: 0.1);
        textColor = AppTheme.statusMatched;
        label = 'Matched';
        break;
      case 'completed':
        bgColor = AppTheme.statusCompleted.withValues(alpha: 0.1);
        textColor = AppTheme.statusCompleted;
        label = 'Completed';
        break;
      case 'cancelled':
        bgColor = AppTheme.statusCancelled.withValues(alpha: 0.1);
        textColor = AppTheme.statusCancelled;
        label = 'Cancelled';
        break;
      default:
        bgColor = AppTheme.lightTextColor.withValues(alpha: 0.1);
        textColor = AppTheme.lightTextColor;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
