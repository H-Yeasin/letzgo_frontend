import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';
import 'defi_card.dart';

class DefiStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Color iconColor;

  const DefiStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return DefiCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: defi.fgMuted,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: defi.fg,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: TextStyle(
                fontSize: 12,
                color: defi.fgDim,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
