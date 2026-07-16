import 'dart:async';
import 'dart:math' show cos, sqrt, asin, sin, pow;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letzgo_app/providers/api_provider.dart';

const _copyWithErrorSentinel = Object();

/// Time limit for a high-accuracy GPS fix. Beyond this, use what we have
/// rather than leaving the user waiting.
const _locationTimeout = Duration(seconds: 8);

class UserLocationState {
  final double? latitude;
  final double? longitude;
  final String? displayName;
  final bool isLoading;
  final String? error;
  final bool permissionGranted;
  final bool permissionDeniedForever;

  const UserLocationState({
    this.latitude,
    this.longitude,
    this.displayName,
    this.isLoading = false,
    this.error,
    this.permissionGranted = false,
    this.permissionDeniedForever = false,
  });

  UserLocationState copyWith({
    double? latitude,
    double? longitude,
    String? displayName,
    bool? isLoading,
    Object? error = _copyWithErrorSentinel,
    bool? permissionGranted,
    bool? permissionDeniedForever,
  }) {
    return UserLocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      displayName: displayName ?? this.displayName,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _copyWithErrorSentinel)
          ? this.error
          : error as String?,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      permissionDeniedForever:
          permissionDeniedForever ?? this.permissionDeniedForever,
    );
  }
}

class LocationNotifier extends Notifier<UserLocationState> {
  @override
  UserLocationState build() => const UserLocationState();

  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    bool permissionGranted = false;

    try {
      // ── 1. Try last-known position for instant display ─────────
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        state = state.copyWith(
          latitude: lastKnown.latitude,
          longitude: lastKnown.longitude,
          permissionGranted: true,
        );
        // Start reverse geocode in background — if it completes before
        // the fresh fix, the user sees a name immediately.
        _resolveAddress(lastKnown.latitude, lastKnown.longitude)
            .then((name) {
          if (name.isNotEmpty) {
            // ignore: no-cli-dev, this is the only valid path
            // (notifier might be disposed; setting state on a disposed
            //  provider throws only in debug mode — wrap to stay safe)
            // ignore: avoid-async-catch
            try {
              state = state.copyWith(displayName: name);
            } catch (_) {}
          }
        });
      }

      // ── 2. Check services & permission ─────────────────────────
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled.',
          permissionGranted: false,
          permissionDeniedForever: false,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: permission == LocationPermission.deniedForever
              ? 'Location permission is permanently denied.'
              : 'Location permission is required.',
          permissionGranted: false,
          permissionDeniedForever:
              permission == LocationPermission.deniedForever,
        );
        return;
      }

      permissionGranted = true;

      // ── 3. Fresh position with timeout and lower accuracy ───────
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _locationTimeout,
        ),
      ).timeout(_locationTimeout, onTimeout: () {
        // If GPS fix times out, keep the last-known position we already set
        throw TimeoutException('Location request timed out.');
      });

      // Only update if the new fix is more precise or coordinates differ
      // significantly (>100m) — avoids unnecessary rebuild + API call churn
      final old = state;
      final stale = _metersBetween(
            old.latitude, old.longitude, position.latitude, position.longitude,
          ) > 100;
      if (old.latitude == null || stale || old.displayName == null) {
        final displayName = await _resolveAddress(
          position.latitude,
          position.longitude,
        );

        state = state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          displayName: displayName,
          isLoading: false,
          error: null,
          permissionGranted: permissionGranted,
          permissionDeniedForever: false,
        );
      } else {
        // Fresh fix is within 100m of cached value — don't churn UI/API
        state = state.copyWith(
          isLoading: false,
          permissionGranted: true,
          permissionDeniedForever: false,
        );
      }
    } catch (error) {
      // If we already had a last-known position, don't clear it on error
      if (state.latitude == null) {
        state = state.copyWith(
          isLoading: false,
          error: _formatError(error),
          permissionGranted: permissionGranted,
          permissionDeniedForever: permissionGranted
              ? false
              : state.permissionDeniedForever,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          permissionGranted: true,
          permissionDeniedForever: false,
        );
      }
    }
  }

  Future<String> _resolveAddress(double lat, double lng) async {
    try {
      final api = ref.read(apiServiceProvider);
      final displayName = await api.reverseGeocode(lat: lat, lng: lng);
      final shortened = _shortenAddress(displayName);
      if (shortened.isNotEmpty) {
        return shortened;
      }
    } catch (_) {}

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts =
            [
                  placemark.street,
                  placemark.subLocality,
                  placemark.locality,
                  placemark.administrativeArea,
                ]
                .whereType<String>()
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList();
        final result = parts.take(3).join(', ');
        if (result.isNotEmpty) {
          return result;
        }
      }
    } catch (_) {}

    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  String _shortenAddress(String value) {
    final parts = value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    return parts.length <= 3 ? parts.join(', ') : parts.take(3).join(', ');
  }

  String _formatError(Object error) {
    if (error is PermissionDeniedException) {
      return 'Location permission was denied.';
    }
    if (error is LocationServiceDisabledException) {
      return 'Location services are turned off.';
    }
    if (error is TimeoutException) {
      return 'Location request timed out.';
    }
    final message = error.toString();
    if (message.isNotEmpty) {
      return message;
    }
    return 'Could not determine your location.';
  }

  /// Approximate Haversine distance in meters between two lat/lng points.
  double _metersBetween(double? lat1, double? lng1, double lat2, double lng2) {
    if (lat1 == null || lng1 == null) return double.infinity;
    const r = 6371000.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = pow(sin(dLat / 2), 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * pow(sin(dLng / 2), 2);
    return r * 2 * asin(sqrt(a));
  }

  double _toRad(double deg) => deg * (3.141592653589793 / 180);
}

final locationProvider =
    NotifierProvider<LocationNotifier, UserLocationState>(LocationNotifier.new);
