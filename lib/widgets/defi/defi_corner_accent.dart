import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';

class DefiCornerAccent extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double length;

  const DefiCornerAccent({
    super.key,
    this.alignment = Alignment.topLeft,
    this.color = AppColors.primary,
    this.length = 24,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = context.defi.gradientPrimary;
    return Align(
      alignment: alignment,
      child: Stack(
        children: [
          // Horizontal line
          Positioned(
            left: alignment == Alignment.topLeft ? 0 : null,
            right: alignment == Alignment.topRight ? 0 : null,
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? 0 : null,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? 0 : null,
            child: Container(
              width: length,
              height: 2,
              decoration: BoxDecoration(
                gradient: gradient,
              ),
            ),
          ),
          // Vertical line
          Positioned(
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? 0 : null,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? 0 : null,
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? 0 : null,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? 0 : null,
            child: Container(
              width: 2,
              height: length,
              decoration: BoxDecoration(
                gradient: gradient,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
