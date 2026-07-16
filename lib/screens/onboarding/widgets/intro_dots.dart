import 'package:flutter/material.dart';

import '../../../constants/defi_theme_extension.dart';

class IntroDots extends StatelessWidget {
  final int count;
  final int index;

  const IntroDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive ? defi.gradientPrimary : null,
            color: isActive ? null : defi.border,
            borderRadius: BorderRadius.circular(9999),
          ),
        );
      }),
    );
  }
}
