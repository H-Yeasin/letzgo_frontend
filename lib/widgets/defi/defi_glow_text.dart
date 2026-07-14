import 'package:flutter/material.dart';
import '../../constants/defi_theme_extension.dart';

class DefiGlowText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// Defaults to the theme's gold gradient when null.
  final Gradient? gradient;

  const DefiGlowText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? context.defi.gradientGold;
    return ShaderMask(
      shaderCallback: (bounds) => effectiveGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}
