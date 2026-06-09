import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/theme.dart';
import '../../models/create_ride_ping_request.dart';
import '../../providers/api_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/ping_provider.dart';
import 'widgets/host_ride_fields.dart';
import 'widgets/host_ride_map_picker.dart';
import 'widgets/ride_preference_controls.dart';

class HostRideScreen extends ConsumerStatefulWidget {
  const HostRideScreen({super.key});

  @override
  ConsumerState<HostRideScreen> createState() => _HostRideScreenState();
}

class _HostRideScreenState extends ConsumerState<HostRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _fareController = TextEditingController();
  final _meetupController = TextEditingController();
  String _genderPref = 'any';
  int _passengerLimit = 1;
  int _expiryMinutes = 30;
  bool _isSubmitting = false;

  static const double _fallbackLat = 23.8103;
  static const double _fallbackLng = 90.4125;

  // Map Picker State
  double? _pickupLat;
  double? _pickupLng;
  double? _destLat;
  double? _destLng;
  final _mapController = MapController();
  String _pickingMode = 'pickup';
  bool _isReverseGeocoding = false;
  double _mapCenterLat = _fallbackLat;
  double _mapCenterLng = _fallbackLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).refreshLocation();
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _fareController.dispose();
    _meetupController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _handleMapTap(LatLng point) async {
    setState(() {
      if (_pickingMode == 'pickup') {
        _pickupLat = point.latitude;
        _pickupLng = point.longitude;
        _pickupController.text = 'Loading address...';
      } else {
        _destLat = point.latitude;
        _destLng = point.longitude;
        _destinationController.text = 'Loading address...';
      }
      _isReverseGeocoding = true;
    });

    try {
      final coordStr =
          '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
      final api = ref.read(apiServiceProvider);

      String shortAddress = 'Selected Location';

      try {
        final reverseResult = await api.reverseGeocode(
          lat: point.latitude,
          lng: point.longitude,
        );
        shortAddress = _truncateAddress(reverseResult);
      } catch (_) {
        final results = await api.searchLocation(coordStr, limit: 1);
        if (results.isNotEmpty) {
          final address = results.first['display_name'] as String;
          shortAddress = _truncateAddress(address);
        }
      }

      setState(() {
        if (_pickingMode == 'pickup') {
          _pickupController.text = shortAddress;
        } else {
          _destinationController.text = shortAddress;
        }
      });
    } catch (e) {
      final coordStr =
          '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
      setState(() {
        if (_pickingMode == 'pickup') {
          _pickupController.text = 'Selected Pickup ($coordStr)';
        } else {
          _destinationController.text = 'Selected Destination ($coordStr)';
        }
      });
    } finally {
      setState(() => _isReverseGeocoding = false);
    }
  }

  void _centerMapOnLatestLocation() {
    final locationState = ref.read(locationProvider);
    final lat = locationState.latitude ?? _mapCenterLat;
    final lng = locationState.longitude ?? _mapCenterLng;
    setState(() {
      _mapCenterLat = lat;
      _mapCenterLng = lng;
    });
    _mapController.move(LatLng(lat, lng), 14.0);
  }

  void _applyLocationUpdate(UserLocationState next) {
    if (next.latitude == null || next.longitude == null) return;
    final lat = next.latitude!;
    final lng = next.longitude!;
    final shouldSetPickup = _pickupLat == null && _pickupLng == null;
    setState(() {
      _mapCenterLat = lat;
      _mapCenterLng = lng;
      if (shouldSetPickup) {
        _pickupLat = lat;
        _pickupLng = lng;
      }
    });
    _mapController.move(LatLng(lat, lng), 13.0);
    if (shouldSetPickup) {
      _pickupController.text = next.displayName ??
          '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  String _truncateAddress(String address) {
    final parts = address.split(',');
    final shortAddress = parts.take(3).join(',').trim();
    return shortAddress.isEmpty ? address : shortAddress;
  }

  Future<void> _submitRide() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isSubmitting = true);

    try {
      double? finalPickupLat = _pickupLat;
      double? finalPickupLng = _pickupLng;
      final pickupAddress = _pickupController.text.trim();

      // If map selection wasn't used or cleared, try geocoding
      if (finalPickupLat == null || finalPickupLng == null) {
        final position = await CreateRidePingRequest.geocodeAddress(
          pickupAddress,
        );
        if (position != null) {
          finalPickupLat = position.latitude;
          finalPickupLng = position.longitude;
        }
      }

      if (!mounted) return;

      if (finalPickupLat == null || finalPickupLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not find the pickup location. Please be more specific or tap the map.',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      double? finalDestLat = _destLat;
      double? finalDestLng = _destLng;
      final destAddress = _destinationController.text.trim();

      if (finalDestLat == null || finalDestLng == null) {
        try {
          final results = await ref.read(apiServiceProvider).searchLocation(
            destAddress,
            limit: 1,
          );
          if (results.isNotEmpty) {
            finalDestLat = (results.first['lat'] as num).toDouble();
            finalDestLng = (results.first['lng'] as num).toDouble();
          }
        } catch (_) {
          // Destination geocoding is optional – proceed without it
        }
      }

      if (!mounted) return;

      final request = CreateRidePingRequest(
        pickupLabel: pickupAddress,
        destinationLabel: destAddress,
        pickupLat: finalPickupLat,
        pickupLng: finalPickupLng,
        destinationLat: finalDestLat,
        destinationLng: finalDestLng,
        estimatedFare: double.parse(_fareController.text.trim()),
        genderPreference: _genderPref,
        maxPassengers: _passengerLimit,
        meetupPoint: _meetupController.text.trim().isEmpty
            ? null
            : _meetupController.text.trim(),
        expiresInMinutes: _expiryMinutes,
      );

      final ping = await ref
          .read(pingProvider.notifier)
          .createPing(request.toJson());

      if (ping != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final theme = Theme.of(context);
    ref.listen<UserLocationState>(locationProvider, (previous, next) {
      _applyLocationUpdate(next);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Host a Ride')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ride Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details about your ride',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(height: 24),

              HostRideMapPicker(
                mapController: _mapController,
                initialCenter: LatLng(_mapCenterLat, _mapCenterLng),
                pickupPoint: _pickupLat != null && _pickupLng != null
                    ? LatLng(_pickupLat!, _pickupLng!)
                    : null,
                destinationPoint: _destLat != null && _destLng != null
                    ? LatLng(_destLat!, _destLng!)
                    : null,
                pickingMode: _pickingMode,
                isLoadingAddress: _isReverseGeocoding,
                onMapTap: _handleMapTap,
                onCenterOnLocation: _centerMapOnLatestLocation,
                onPickingModeChanged: (value) =>
                    setState(() => _pickingMode = value),
              ),
              const SizedBox(height: 16),

              HostRideFields(
                pickupController: _pickupController,
                destinationController: _destinationController,
                fareController: _fareController,
                meetupController: _meetupController,
              ),
              const SizedBox(height: 24),

              RidePreferenceControls(
                genderPreference: _genderPref,
                passengerLimit: _passengerLimit,
                expiryMinutes: _expiryMinutes,
                onGenderChanged: (value) => setState(() => _genderPref = value),
                onPassengerLimitChanged: (value) =>
                    setState(() => _passengerLimit = value),
                onExpiryChanged: (value) =>
                    setState(() => _expiryMinutes = value),
              ),

              if (pingState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  pingState.error!,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitRide,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Post Ride'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
