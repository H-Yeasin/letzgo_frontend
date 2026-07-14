import 'package:flutter/material.dart';
import '../../constants/defi_theme_extension.dart';

enum DefiButtonVariant { primary, secondary, ghost, danger, outline }

class DefiButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;
  final DefiButtonVariant variant;

  const DefiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.variant = DefiButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    final isDisabled = onPressed == null || loading;

    BoxDecoration decoration;
    Color textColor;
    EdgeInsets padding;

    switch (variant) {
      case DefiButtonVariant.primary:
        decoration = BoxDecoration(
          gradient: defi.gradientPrimary,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: defi.primaryGlow,
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        );
        textColor = Colors.white;
        padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
      case DefiButtonVariant.secondary:
        decoration = BoxDecoration(
          color: defi.surfaceElevated,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: defi.borderLight),
        );
        textColor = defi.fg;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case DefiButtonVariant.ghost:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        );
        textColor = defi.fgMuted;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case DefiButtonVariant.danger:
        decoration = BoxDecoration(
          color: defi.danger,
          borderRadius: BorderRadius.circular(9999),
        );
        textColor = Colors.white;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case DefiButtonVariant.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: defi.border),
        );
        textColor = defi.fg;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }

    final buttonWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: decoration,
      padding: padding,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              ),
            ),
          if (icon != null && !loading) ...[
            Icon(
              icon,
              size: 18,
              color: textColor,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: buttonWidget,
    );
  }
}
