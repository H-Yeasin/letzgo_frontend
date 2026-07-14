import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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

  Color get _bgColor {
    switch (variant) {
      case DefiBadgeVariant.success:
        return AppColors.successMuted;
      case DefiBadgeVariant.warning:
        return AppColors.warningMuted;
      case DefiBadgeVariant.danger:
        return AppColors.dangerMuted;
      case DefiBadgeVariant.info:
        return AppColors.infoMuted;
      case DefiBadgeVariant.neutral:
        return AppColors.fgDim.withValues(alpha: 0.12);
    }
  }

  Color get _textColor {
    switch (variant) {
      case DefiBadgeVariant.success:
        return AppColors.success;
      case DefiBadgeVariant.warning:
        return AppColors.warning;
      case DefiBadgeVariant.danger:
        return AppColors.danger;
      case DefiBadgeVariant.info:
        return AppColors.info;
      case DefiBadgeVariant.neutral:
        return AppColors.fgMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
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
                color: _textColor,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: _textColor,
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
