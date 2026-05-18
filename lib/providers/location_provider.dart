import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letzgo_app/providers/ping_provider.dart';

const _copyWithErrorSentinel = Object();

class UserLocationState {
  final double? latitude;
  final double? longitude;
  final String? displayName;
  final bool isLoading;
  final String? error;
  final bool permissionGranted;

  const UserLocationState({
    this.latitude,
    this.longitude,
    this.displayName,
    this.isLoading = false,
    this.error,
    this.permissionGranted = false,
  });

  UserLocationState copyWith({
    double? latitude,
    double? longitude,
    String? displayName,
    bool? isLoading,
    Object? error = _copyWithErrorSentinel,
    bool? permissionGranted,
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
    );
  }
}

class LocationNotifier extends StateNotifier<UserLocationState> {
  final Ref _ref;

  LocationNotifier(this._ref) : super(const UserLocationState());

  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    bool permissionGranted = false;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled.',
          permissionGranted: false,
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
          error: 'Location permission is required.',
          permissionGranted: false,
        );
        return;
      }

      permissionGranted = true;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

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
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _formatError(error),
        permissionGranted: permissionGranted,
      );
    }
  }

  Future<String> _resolveAddress(double lat, double lng) async {
    try {
      final api = _ref.read(apiServiceProvider);
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
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, UserLocationState>(
      (ref) => LocationNotifier(ref),
    );
