import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/create_ride_ping_request.dart';
import '../../models/ride_ping.dart';
import '../../providers/ping_provider.dart';
import 'models/location_selection.dart';

/// Everything the host-ride wizard gathers across its steps.
/// Ephemeral UI state (controllers, map, debounce timers) stays in widgets.
class HostRideDraft {
  final LocationSelection? pickup;
  final LocationSelection? destination;
  final String fareText;
  final String meetupPoint;
  final int maxPassengers;
  final String genderPreference; // 'any' | 'male' | 'female'
  final int expiresInMinutes;
  final bool isSubmitting;
  final String? submitError;

  const HostRideDraft({
    this.pickup,
    this.destination,
    this.fareText = '',
    this.meetupPoint = '',
    this.maxPassengers = 1,
    this.genderPreference = 'any',
    this.expiresInMinutes = 30,
    this.isSubmitting = false,
    this.submitError,
  });

  static const double maxFare = 5000;

  double? get fare => double.tryParse(fareText.trim());

  /// Live inline error for the fare step; null while empty or valid.
  String? get fareError {
    if (fareText.trim().isEmpty) return null;
    final value = fare;
    if (value == null) return 'Enter a valid amount';
    if (value <= 0) return 'Fare must be greater than 0';
    if (value > maxFare) return 'Fare cannot exceed Tk 5,000';
    return null;
  }

  bool get isPickupValid => pickup != null;
  bool get isDestinationValid => destination != null;
  bool get isFareValid {
    final value = fare;
    return value != null && value > 0 && value <= maxFare;
  }

  /// Note: [submitError] is always replaced (pass null to clear), so any
  /// field edit clears a stale submission error.
  HostRideDraft copyWith({
    LocationSelection? pickup,
    LocationSelection? destination,
    String? fareText,
    String? meetupPoint,
    int? maxPassengers,
    String? genderPreference,
    int? expiresInMinutes,
    bool? isSubmitting,
    String? submitError,
  }) {
    return HostRideDraft(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      fareText: fareText ?? this.fareText,
      meetupPoint: meetupPoint ?? this.meetupPoint,
      maxPassengers: maxPassengers ?? this.maxPassengers,
      genderPreference: genderPreference ?? this.genderPreference,
      expiresInMinutes: expiresInMinutes ?? this.expiresInMinutes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }
}

class HostRideDraftNotifier extends AutoDisposeNotifier<HostRideDraft> {
  @override
  HostRideDraft build() => const HostRideDraft();

  void setPickup(LocationSelection value) =>
      state = state.copyWith(pickup: value);

  void setDestination(LocationSelection value) =>
      state = state.copyWith(destination: value);

  void setFareText(String value) => state = state.copyWith(fareText: value);

  void setMeetupPoint(String value) =>
      state = state.copyWith(meetupPoint: value);

  void setMaxPassengers(int value) =>
      state = state.copyWith(maxPassengers: value.clamp(1, 5));

  void setGenderPreference(String value) =>
      state = state.copyWith(genderPreference: value);

  void setExpiry(int minutes) =>
      state = state.copyWith(expiresInMinutes: minutes.clamp(10, 120));

  /// Builds the ping request from the draft and posts it.
  /// Returns the created ping, or null on failure (error kept in state).
  Future<RidePing?> submit() async {
    final draft = state;
    final pickup = draft.pickup;
    final destination = draft.destination;
    final fare = draft.fare;
    if (pickup == null || destination == null || !draft.isFareValid) {
      return null;
    }

    state = state.copyWith(isSubmitting: true, submitError: null);

    final request = CreateRidePingRequest(
      pickupLabel: pickup.label,
      destinationLabel: destination.label,
      pickupLat: pickup.lat,
      pickupLng: pickup.lng,
      destinationLat: destination.lat,
      destinationLng: destination.lng,
      estimatedFare: fare!,
      genderPreference: draft.genderPreference,
      maxPassengers: draft.maxPassengers,
      meetupPoint:
          draft.meetupPoint.trim().isEmpty ? null : draft.meetupPoint.trim(),
      expiresInMinutes: draft.expiresInMinutes,
    );

    final ping =
        await ref.read(pingProvider.notifier).createPing(request.toJson());

    if (ping == null) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: ref.read(pingProvider).error ??
            'Could not post your ride. Please try again.',
      );
    } else {
      state = state.copyWith(isSubmitting: false);
    }
    return ping;
  }
}

final hostRideDraftProvider =
    NotifierProvider.autoDispose<HostRideDraftNotifier, HostRideDraft>(
  HostRideDraftNotifier.new,
);
