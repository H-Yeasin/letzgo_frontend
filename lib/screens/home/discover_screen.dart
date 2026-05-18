import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/theme.dart';
import '../../providers/location_provider.dart';
import '../../providers/ping_provider.dart';
import '../../widgets/ride_ping_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _destinationController = TextEditingController();
  final _mapController = MapController();

  double? _destLat;
  double? _destLng;
  static const double _fallbackLat = 23.8103;
  static const double _fallbackLng = 90.4125;
  double _currentLat = _fallbackLat;
  double _currentLng = _fallbackLng;
  bool _hasSearched = false;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectCurrentLocation();
      ref.read(locationProvider.notifier).refreshLocation();
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _detectCurrentLocation() {
    final locationState = ref.read(locationProvider);
    final lat = locationState.latitude ?? _currentLat;
    final lng = locationState.longitude ?? _currentLng;
    setState(() {
      _currentLat = lat;
      _currentLng = lng;
    });
    _mapController.move(LatLng(lat, lng), 14.0);
  }

  Future<void> _geocodeAndSearch(String query) async {
    final value = query.trim();
    if (value.isEmpty) return;

    // Direct lat,lng check
    if (value.contains(',')) {
      final parts = value.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          _setDestination(lat, lng);
          return;
        }
      }
    }

    setState(() => _isGeocoding = true);

    try {
      final api = ref.read(apiServiceProvider);
      final results = await api.searchLocation(value);

      if (results.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not find location: $value')),
          );
        }
        return;
      }

      // Use the first result
      final result = results.first;
      final lat = (result['lat'] as num).toDouble();
      final lng = (result['lng'] as num).toDouble();

      _setDestination(lat, lng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find location: $value')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeocoding = false);
      }
    }
  }

  void _setDestination(double lat, double lng) {
    setState(() {
      _destLat = lat;
      _destLng = lng;
    });

    // Move map to center on destination
    _mapController.move(LatLng(lat, lng), 14.0);

    _searchRides();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    _destinationController.text =
        '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
    _setDestination(point.latitude, point.longitude);
  }

  void _searchRides() {
    if (_destLat == null || _destLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination first')),
      );
      return;
    }

    setState(() => _hasSearched = true);

    ref
        .read(pingProvider.notifier)
        .findRides(
          currentLat: ref.read(locationProvider).latitude ?? _currentLat,
          currentLng: ref.read(locationProvider).longitude ?? _currentLng,
          destinationLat: _destLat!,
          destinationLng: _destLng!,
          radius: 500.0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final pingState = ref.watch(pingProvider);
    final theme = Theme.of(context);
    ref.listen<UserLocationState>(locationProvider, (previous, next) {
      if (!mounted) return;
      if (next.latitude != null && next.longitude != null) {
        setState(() {
          _currentLat = next.latitude!;
          _currentLng = next.longitude!;
        });
        _mapController.move(
          LatLng(next.latitude!, next.longitude!),
          13.5,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Ride'),
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_currentLat, _currentLng),
              initialZoom: 13.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.letzgo.app',
              ),
              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    point: LatLng(_currentLat, _currentLng),
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Destination marker
                  if (_destLat != null && _destLng != null)
                    Marker(
                      point: LatLng(_destLat!, _destLng!),
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.secondaryColor,
                        size: 40,
                      ),
                    ),
                  // Nearby Ride pins (Results)
                  for (final ping in pingState.findResults)
                    Marker(
                      point: LatLng(ping.pickupLat, ping.pickupLng),
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => context.push('/ride-details/${ping.id}'),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Top Search Bar (Floating)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildFloatingSearchBar(theme),
          ),

          // 3. My Location Button
          Positioned(
            right: 16,
            bottom: _hasSearched
                ? (MediaQuery.of(context).size.height * 0.4) + 16
                : 16,
            child: FloatingActionButton(
              heroTag: 'my_location',
              onPressed: _detectCurrentLocation,
              backgroundColor: theme.colorScheme.surface,
              child: const Icon(
                Icons.my_location,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          // 4. Bottom Results Sheet
          if (_hasSearched)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildDraggableResults(theme, pingState),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.secondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Where to? (e.g. Mirpur)',
                border: InputBorder.none,
                isDense: false,
                hintStyle: TextStyle(
                  color: AppTheme.lightTextColor.withValues(alpha: 0.6),
                ),
              ),
              onSubmitted: _geocodeAndSearch,
            ),
          ),
          if (_isGeocoding)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: AppTheme.primaryColor),
              onPressed: () => _geocodeAndSearch(_destinationController.text),
            ),
        ],
      ),
    );
  }

  Widget _buildDraggableResults(ThemeData theme, PingState pingState) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: pingState.isFindLoading
                ? const Center(child: CircularProgressIndicator())
                : pingState.findResults.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('No rides found here.'),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/host-ride'),
                            icon: const Icon(Icons.add),
                            label: const Text('Host a Ride Instead'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: pingState.findResults.length,
                    itemBuilder: (context, index) {
                      final ping = pingState.findResults[index];
                      return RidePingCard(
                        ping: ping,
                        onTap: () => context.push('/ride-details/${ping.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
