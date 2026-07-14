import 'package:flutter/material.dart';
import '../../constants/defi_theme_extension.dart';

enum DefiBadgeVariant { success, warning, danger, info, neutral }

class DefiBadge extends StatelessWidget {
  final String label;
  final DefiBadgeVariant variant;
  final bool pulse;

  const DefiBadge({
    super.key,
    required this.label,
    this.variant = DefiBadgeVariant.neutral,
    this.pulse = false,
  });

  Color _bgColor(DefiThemeExtension defi) {
    switch (variant) {
      case DefiBadgeVariant.success:
        return defi.successMuted;
      case DefiBadgeVariant.warning:
        return defi.warningMuted;
      case DefiBadgeVariant.danger:
        return defi.dangerMuted;
      case DefiBadgeVariant.info:
        return defi.infoMuted;
      case DefiBadgeVariant.neutral:
        return defi.fgDim.withValues(alpha: 0.12);
    }
  }

  Color _textColor(DefiThemeExtension defi) {
    switch (variant) {
      case DefiBadgeVariant.success:
        return defi.success;
      case DefiBadgeVariant.warning:
        return defi.warning;
      case DefiBadgeVariant.danger:
        return defi.danger;
      case DefiBadgeVariant.info:
        return defi.info;
      case DefiBadgeVariant.neutral:
        return defi.fgMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor(defi),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: _textColor(defi),
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: _textColor(defi),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
