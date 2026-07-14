import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class DefiGlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Gradient gradient;

  const DefiGlowText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.gradient = AppColors.gradientGold,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}
