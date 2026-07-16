import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/defi_theme_extension.dart';
import '../../../widgets/defi/defi_badge.dart';
import '../../../widgets/defi/defi_glass_card.dart';
import '../host_ride_draft_provider.dart';

/// Glass summary of the whole draft shown on the review step.
class ReviewSummaryCard extends StatelessWidget {
  final HostRideDraft draft;

  const ReviewSummaryCard({super.key, required this.draft});

  String get _expiryLabel {
    final minutes = draft.expiresInMinutes;
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours hour${hours > 1 ? 's' : ''}';
    }
    return '$minutes min';
  }

  String get _genderLabel {
    switch (draft.genderPreference) {
      case 'male':
        return 'MEN ONLY';
      case 'female':
        return 'WOMEN ONLY';
      default:
        return 'ANYONE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    final detailRows = <Widget>[
      _DetailRow(
        icon: Icons.payments_outlined,
        label: 'Fare per seat',
        value: '৳${draft.fareText.trim()}',
        valueColor: AppColors.primary,
      ),
      if (draft.meetupPoint.trim().isNotEmpty)
        _DetailRow(
          icon: Icons.flag_outlined,
          label: 'Meetup point',
          value: draft.meetupPoint.trim(),
        ),
      _DetailRow(
        icon: Icons.group_outlined,
        label: 'Passenger seats',
        value: '${draft.maxPassengers}',
      ),
      _DetailRow(
        icon: Icons.diversity_3_outlined,
        label: 'Open to',
        trailing: DefiBadge(
          label: _genderLabel,
          variant: draft.genderPreference == 'any'
              ? DefiBadgeVariant.info
              : DefiBadgeVariant.warning,
        ),
      ),
      _DetailRow(
        icon: Icons.schedule_outlined,
        label: 'Ping expires in',
        value: _expiryLabel,
      ),
    ];

    return DefiGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteBlock(
            pickupLabel: draft.pickup?.label ?? '—',
            destinationLabel: draft.destination?.label ?? '—',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: defi.border),
          ),
          ...List.generate(detailRows.length, (i) {
            return Padding(
              padding:
                  EdgeInsets.only(bottom: i < detailRows.length - 1 ? 14 : 0),
              child: detailRows[i]
                  .animate()
                  .fadeIn(delay: (i * 70).ms, duration: 250.ms)
                  .slideX(begin: 0.08),
            );
          }),
        ],
      ),
    );
  }
}

class _RouteBlock extends StatelessWidget {
  final String pickupLabel;
  final String destinationLabel;

  const _RouteBlock({
    required this.pickupLabel,
    required this.destinationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.trip_origin, size: 16, color: defi.success),
            ...List.generate(
              3,
              (_) => Container(
                width: 2,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: defi.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const Icon(Icons.location_on, size: 18, color: AppColors.secondary),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pickupLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: defi.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                destinationLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: defi.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Row(
      children: [
        Icon(icon, size: 18, color: defi.fgMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: defi.fgMuted, fontSize: 14),
          ),
        ),
        if (trailing != null)
          trailing!
        else
          Text(
            value ?? '',
            style: TextStyle(
              color: valueColor ?? defi.fg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
