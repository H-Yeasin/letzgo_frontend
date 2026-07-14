import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

enum DefiCardVariant { normal, glass, hover }

class DefiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final DefiCardVariant variant;
  final VoidCallback? onTap;

  const DefiCard({
    super.key,
    required this.child,
    this.padding,
    this.variant = DefiCardVariant.normal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    BoxDecoration decoration;
    switch (variant) {
      case DefiCardVariant.normal:
        decoration = BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.borderLight),
        );
      case DefiCardVariant.glass:
        decoration = BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.borderLight),
        );
      case DefiCardVariant.hover:
        decoration = BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.borderLight),
        );
    }

    return Container(
      decoration: decoration,
      padding: padding ?? const EdgeInsets.all(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
