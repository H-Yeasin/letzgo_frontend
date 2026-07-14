import 'package:flutter/material.dart';
import '../../constants/defi_theme_extension.dart';

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
    final defi = context.defi;
    final borderRadius = BorderRadius.circular(16);

    BoxDecoration decoration;
    switch (variant) {
      case DefiCardVariant.normal:
        decoration = BoxDecoration(
          color: defi.surface,
          borderRadius: borderRadius,
          border: Border.all(color: defi.borderLight),
        );
      case DefiCardVariant.glass:
        decoration = BoxDecoration(
          color: defi.glassFill,
          borderRadius: borderRadius,
          border: Border.all(color: defi.borderLight),
        );
      case DefiCardVariant.hover:
        decoration = BoxDecoration(
          color: defi.surface,
          borderRadius: borderRadius,
          border: Border.all(color: defi.borderLight),
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
