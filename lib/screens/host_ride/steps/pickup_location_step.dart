import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../host_ride_draft_provider.dart';
import '../widgets/location_picker.dart';

/// Step 1 — choose where the ride starts.
class PickupLocationStep extends ConsumerWidget {
  const PickupLocationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(hostRideDraftProvider);
    final notifier = ref.read(hostRideDraftProvider.notifier);

    return LocationPicker(
      title: 'Where do you start?',
      searchHint: 'Search pickup area',
      initialSelection: draft.pickup,
      isOrigin: true,
      autoSelectDeviceLocation: true,
      onSelected: notifier.setPickup,
    );
  }
}
