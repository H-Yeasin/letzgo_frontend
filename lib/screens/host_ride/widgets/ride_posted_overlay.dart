import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../constants/defi_theme_extension.dart';
import '../../../widgets/defi/defi_glow_text.dart';

/// Full-screen "Ride posted!" celebration shown after a successful
/// submission; calls [onDone] after a short beat so the shell can pop.
class RidePostedOverlay extends StatefulWidget {
  final VoidCallback onDone;

  const RidePostedOverlay({super.key, required this.onDone});

  @override
  State<RidePostedOverlay> createState() => _RidePostedOverlayState();
}

class _RidePostedOverlayState extends State<RidePostedOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(1400.ms, widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return Container(
      color: defi.bg.withValues(alpha: 0.94),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: defi.successMuted,
              shape: BoxShape.circle,
              border: Border.all(color: defi.success, width: 2),
              boxShadow: [
                BoxShadow(
                  color: defi.success.withValues(alpha: 0.45),
                  blurRadius: 40,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(Icons.check_rounded, size: 52, color: defi.success),
          ).animate().scale(
                begin: const Offset(0.3, 0.3),
                curve: Curves.easeOutBack,
                duration: 450.ms,
              ),
          const SizedBox(height: 24),
          const DefiGlowText(
            text: 'Ride posted!',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 250.ms, duration: 300.ms).slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            'Riders nearby can now see your ping',
            style: TextStyle(color: defi.fgMuted, fontSize: 14),
          ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
        ],
      ),
    );
  }
}
