import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import '../../constants/theme.dart';
import '../../models/create_ride_ping_request.dart';
import '../../providers/ping_provider.dart';

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

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _fareController.dispose();
    _meetupController.dispose();
    super.dispose();
  }

  Future<void> _submitRide() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    // Resolve pickup area to coordinates via geocoding
    final pickupAddress = _pickupController.text.trim();
    final position = await CreateRidePingRequest.geocodeAddress(pickupAddress);

    if (!mounted) return;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not find the pickup location. Please be more specific.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Optional: try to geocode destination as well
    double? destLat;
    double? destLng;
    try {
      final destLocations = await locationFromAddress(
        _destinationController.text.trim(),
      );
      if (destLocations.isNotEmpty) {
        destLat = destLocations.first.latitude;
        destLng = destLocations.first.longitude;
      }
    } catch (_) {
      // Destination geocoding is optional – proceed without it
    }

    if (!mounted) return;

    final request = CreateRidePingRequest(
      pickupArea: pickupAddress,
      destinationText: _destinationController.text.trim(),
      pickupLat: position.latitude,
      pickupLng: position.longitude,
      destinationLat: destLat,
      destinationLng: destLng,
      estimatedFare: double.parse(_fareController.text.trim()),
      genderPreference: _genderPref,
      passengerLimit: _passengerLimit,
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
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final theme = Theme.of(context);

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
                  onPressed: pingState.isLoading ? null : _submitRide,
                  child: pingState.isLoading
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
