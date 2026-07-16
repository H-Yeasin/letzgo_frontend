import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../host_ride_draft_provider.dart';
import '../widgets/location_picker.dart';

/// Step 2 — choose where the ride is headed. Shows the pickup point
/// as a marker so the trip visually takes shape.
class DestinationLocationStep extends ConsumerWidget {
  const DestinationLocationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(hostRideDraftProvider);
    final notifier = ref.read(hostRideDraftProvider.notifier);

    return LocationPicker(
      title: 'Where are you headed?',
      searchHint: 'Search destination',
      initialSelection: draft.destination,
      otherPoint: draft.pickup,
      onSelected: notifier.setDestination,
    );
  }
}
