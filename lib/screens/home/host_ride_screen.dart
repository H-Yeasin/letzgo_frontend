import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/theme.dart';
import '../../models/create_ride_ping_request.dart';
import '../../providers/location_provider.dart';
import '../../providers/ping_provider.dart';
import '../../services/api_service.dart';

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
      final api = ApiService();

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
          final results = await ApiService().searchLocation(
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

              // Interactive Map Picker
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(_mapCenterLat, _mapCenterLng),
                              initialZoom: 13.0,
                              onTap: (tapPosition, point) =>
                                  _handleMapTap(point),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.letzgo.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  // Pickup Marker (Green)
                                  if (_pickupLat != null && _pickupLng != null)
                                    Marker(
                                      point: LatLng(_pickupLat!, _pickupLng!),
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.topCenter,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.green,
                                        size: 36,
                                      ),
                                    ),
                                  // Destination Marker (Red/Secondary)
                                  if (_destLat != null && _destLng != null)
                                    Marker(
                                      point: LatLng(_destLat!, _destLng!),
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.topCenter,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppTheme.secondaryColor,
                                        size: 36,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          // Loading indicator when reverse geocoding
                          if (_isReverseGeocoding)
                            Container(
                              color: Colors.black26,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          // Floating Reset/My Location Button on the map
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: FloatingActionButton.small(
                              heroTag: 'host_my_location',
                              onPressed: _centerMapOnLatestLocation,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.my_location,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Selecting Mode Controller
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tap map to set:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: SegmentedButton<String>(
                              showSelectedIcon: false,
                              style: SegmentedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              segments: const [
                                ButtonSegment(
                                  value: 'pickup',
                                  label: Text(
                                    'Pickup',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: Icon(
                                    Icons.trip_origin,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                ),
                                ButtonSegment(
                                  value: 'destination',
                                  label: Text(
                                    'Dest',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  icon: Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ],
                              selected: {_pickingMode},
                              onSelectionChanged: (set) =>
                                  setState(() => _pickingMode = set.first),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pickupController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Area',
                  hintText: 'e.g., Gulshan 1',
                  prefixIcon: Icon(Icons.trip_origin),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter pickup area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'e.g., Banani 11',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter destination';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fareController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimated Fare (৳)',
                  hintText: 'e.g., 200',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter estimated fare';
                  }
                  final fare = double.tryParse(value.trim());
                  if (fare == null || fare <= 0) {
                    return 'Please enter a valid fare';
                  }
                  if (fare > 5000) {
                    return 'Fare cannot exceed ৳5,000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _meetupController,
                decoration: const InputDecoration(
                  labelText: 'Meetup Point (optional)',
                  hintText: 'e.g., Near Starbucks',
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: 24),

              // Gender preference
              Text(
                'Gender Preference',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'any', label: Text('Any')),
                  ButtonSegment(value: 'male', label: Text('Male')),
                  ButtonSegment(value: 'female', label: Text('Female')),
                ],
                selected: {_genderPref},
                onSelectionChanged: (set) =>
                    setState(() => _genderPref = set.first),
              ),
              const SizedBox(height: 24),

              // Passenger limit
              Row(
                children: [
                  Text(
                    'Passenger Limit: $_passengerLimit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _passengerLimit > 1
                        ? () => setState(() => _passengerLimit--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_passengerLimit', style: theme.textTheme.titleLarge),
                  IconButton(
                    onPressed: _passengerLimit < 5
                        ? () => setState(() => _passengerLimit++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Expiry time
              Text(
                'Expires in: $_expiryMinutes minutes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: _expiryMinutes.toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                label: '$_expiryMinutes min',
                onChanged: (v) => setState(() => _expiryMinutes = v.toInt()),
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
