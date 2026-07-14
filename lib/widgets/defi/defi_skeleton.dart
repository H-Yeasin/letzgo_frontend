import 'package:flutter/material.dart';
import '../../constants/defi_theme_extension.dart';

class DefiSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const DefiSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: defi.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Shimmer(
        linearGradient: LinearGradient(
          colors: [
            Colors.transparent,
            defi.shimmerHighlight,
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class Shimmer extends StatefulWidget {
  final LinearGradient linearGradient;

  const Shimmer({super.key, required this.linearGradient});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return widget.linearGradient.createShader(
              Rect.fromLTWH(
                bounds.width * (_animation.value - 1) / 2,
                0,
                bounds.width * 2,
                bounds.height,
              ),
            );
          },
          blendMode: BlendMode.srcOver,
          child: Container(
            color: context.defi.surfaceHover.withValues(alpha: 0.3),
          ),
        );
      },
    );
  }
}
