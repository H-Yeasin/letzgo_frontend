import 'dart:ui';

import 'package:flutter/material.dart';

/// A map pin glyph with its drop shadow painted in the same widget
/// subtree.
///
/// Never use the [Icon.shadows] property on map markers: glyph shadows go
/// through the text-rendering pipeline and can be drawn with a stale
/// transform while the map pans, leaving the shadow floating away from the
/// pin. Here the shadow is a blurred copy of the same icon stacked directly
/// underneath, so both always move as one.
class MapPinIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color shadowColor;

  const MapPinIcon({
    super.key,
    this.icon = Icons.location_on,
    required this.size,
    required this.color,
    this.shadowColor = Colors.black45,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 2,
          left: 0,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Icon(icon, size: size, color: shadowColor),
          ),
        ),
        Icon(icon, size: size, color: color),
      ],
    );
  }
}
