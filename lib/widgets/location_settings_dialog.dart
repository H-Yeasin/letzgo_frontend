import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Shown when location permission is permanently denied and the OS will no
/// longer surface its own prompt — the only way to recover is Settings.
Future<void> showLocationSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Location permission needed'),
      content: const Text(
        'Location access is turned off for LetzGo. Enable it in your '
        "phone's settings to find and post nearby rides.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}
