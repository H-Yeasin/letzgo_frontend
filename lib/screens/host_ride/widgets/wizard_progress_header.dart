import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/defi_theme_extension.dart';

/// Wizard header: close/back button, animated gradient segment bar
/// and a "n / total" counter. Mirrors the profile setup header.
class WizardProgressHeader extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const WizardProgressHeader({
    super.key,
    required this.step,
    required this.total,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(step == 0 ? Icons.close : Icons.arrow_back),
            color: defi.fg,
            onPressed: step == 0 ? onClose : onBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: List.generate(total, (i) {
                final isFilled = i <= step;
                return Expanded(
                  child: AnimatedContainer(
                    duration: 300.ms,
                    height: 4,
                    margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
                    decoration: BoxDecoration(
                      gradient: isFilled ? defi.gradientPrimary : null,
                      color: isFilled ? null : defi.border,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${step + 1} / $total',
            style: TextStyle(color: defi.fgMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
