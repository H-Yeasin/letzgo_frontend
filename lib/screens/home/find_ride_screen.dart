import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';
import '../../providers/ping_provider.dart';
import '../../widgets/ride_ping_card.dart';

class FindRideScreen extends ConsumerStatefulWidget {
  const FindRideScreen({super.key});

  @override
  ConsumerState<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends ConsumerState<FindRideScreen> {
  final _destinationController = TextEditingController();
  double? _destLat;
  double? _destLng;
  bool _useGps = true;
  double _currentLat = 23.8103; // Default Dhaka
  double _currentLng = 90.4125;

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _detectCurrentLocation() {
    // In production, use Geolocator package to get actual GPS position.
    // For now, we use default Dhaka coordinates and let user know GPS is simulated.
    setState(() {
      _currentLat = 23.8103;
      _currentLng = 90.4125;
    });
  }

  void _searchRides() {
    if (_destLat == null || _destLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    ref
        .read(pingProvider.notifier)
        .findRides(
          currentLat: _currentLat,
          currentLng: _currentLng,
          destinationLat: _destLat!,
          destinationLng: _destLng!,
          radius: 500.0,
        );
  }

  void _onDestinationChanged(String value) {
    // MVP: For demo, parse "lat,lng" format or use hardcoded lookup.
    // In production, integrate with a geocoding service (e.g., Google Maps API).
    if (value.contains(',')) {
      final parts = value.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          setState(() {
            _destLat = lat;
            _destLng = lng;
          });
          return;
        }
      }
    }

    // Fallback: common Dhaka destinations
    final destinations = {
      'mirpur': (23.8223, 90.3685),
      'uttara': (23.8759, 90.3795),
      'gulshan': (23.7925, 90.4078),
      'banani': (23.7949, 90.4067),
      'dhanmondi': (23.7465, 90.3742),
      'motijheel': (23.7331, 90.4172),
      'farmgate': (23.7572, 90.3905),
      'mohakhali': (23.7779, 90.4057),
    };

    final key = value.trim().toLowerCase();
    if (destinations.containsKey(key)) {
      final coords = destinations[key]!;
      setState(() {
        _destLat = coords.$1;
        _destLng = coords.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Ride'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _detectCurrentLocation,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Input section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current location
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Location',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _useGps ? 'GPS' : 'Manual',
                      style: TextStyle(
                        fontSize: 12,
                        color: _useGps
                            ? AppTheme.successColor
                            : AppTheme.lightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Divider with arrow
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: theme.dividerColor),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: AppTheme.secondaryColor,
                        size: 16,
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: theme.dividerColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Destination input
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.secondaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          hintText: 'Enter destination area (e.g. Mirpur)',
                          hintStyle: TextStyle(
                            color: AppTheme.lightTextColor.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _onDestinationChanged,
                        onSubmitted: (_) => _searchRides(),
                      ),
                    ),
                    if (_destLat != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Set',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: pingState.isFindLoading ? null : _searchRides,
                    icon: pingState.isFindLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      pingState.isFindLoading ? 'Searching...' : 'Find Rides',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Hint text
                if (_destLat == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Try: Mirpur, Gulshan, Uttara, Dhanmondi, Farmgate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Results section
          Expanded(child: _buildResults(theme, pingState)),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme, PingState pingState) {
    if (pingState.isFindLoading && pingState.findResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pingState.findResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 80,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No matching rides found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different destination or expand your search radius',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.push('/host-ride'),
                icon: const Icon(Icons.add),
                label: const Text('Host a Ride Instead'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pingState.findResults.length,
      itemBuilder: (context, index) {
        final ping = pingState.findResults[index];
        return RidePingCard(
          ping: ping,
          onTap: () => context.push('/ride-details/${ping.id}'),
        );
      },
    );
  }
}
