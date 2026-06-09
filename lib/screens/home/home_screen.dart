import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/ping_provider.dart';
import 'widgets/home_filters.dart';
import 'widgets/home_header.dart';
import 'widgets/my_rides_section.dart';
import 'widgets/nearby_rides_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double _defaultRadiusMeters = 2000.0;
  static const double _minRadiusMeters = 500.0;
  static const double _maxRadiusMeters = 5000.0;
  static const double _fallbackLat = 23.8103;
  static const double _fallbackLng = 90.4125;

  double _selectedRadiusMeters = _defaultRadiusMeters;
  String _selectedGender = 'any';
  String _destinationFilter = '';
  late final TextEditingController _destinationFilterController;
  double _refreshRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _destinationFilterController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).refreshLocation();
      _loadNearbyRides();
      _loadMyRides();
    });
  }

  @override
  void dispose() {
    _destinationFilterController.dispose();
    super.dispose();
  }

  void _loadNearbyRides({double? lat, double? lng}) {
    final locationState = ref.read(locationProvider);
    final resolvedLat = lat ?? locationState.latitude ?? _fallbackLat;
    final resolvedLng = lng ?? locationState.longitude ?? _fallbackLng;
    ref
        .read(pingProvider.notifier)
        .fetchNearbyPings(
          lat: resolvedLat,
          lng: resolvedLng,
          radius: _selectedRadiusMeters,
          gender: _selectedGender == 'any' ? null : _selectedGender,
        );
  }

  void _triggerLocationRefresh() {
    setState(() => _refreshRotation += 1);
    ref.read(locationProvider.notifier).refreshLocation();
  }

  void _loadMyRides() {
    ref.read(pingProvider.notifier).fetchMyPings();
  }

  void _showNearbyFilterSheet(BuildContext context) {
    double tempRadius = _selectedRadiusMeters;
    String tempGender = _selectedGender;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby filters',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                'Radius (${(tempRadius / 1000).toStringAsFixed(1)} km)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                min: _minRadiusMeters,
                max: _maxRadiusMeters,
                value: tempRadius,
                divisions: ((_maxRadiusMeters - _minRadiusMeters) / 500)
                    .round(),
                label: '${(tempRadius / 1000).toStringAsFixed(1)} km',
                onChanged: (value) => setModalState(() {
                  tempRadius = value;
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Gender preference',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tempGender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setModalState(() {
                  tempGender = value ?? 'any';
                }),
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('Any')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        tempRadius = _defaultRadiusMeters;
                        tempGender = 'any';
                      });
                      setState(() {
                        _selectedRadiusMeters = _defaultRadiusMeters;
                        _selectedGender = 'any';
                      });
                      _loadNearbyRides();
                    },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedRadiusMeters = tempRadius;
                        _selectedGender = tempGender;
                      });
                      Navigator.pop(ctx);
                      _loadNearbyRides();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(UserLocationState locationState) {
    final displayName =
        locationState.displayName ??
        (locationState.latitude != null && locationState.longitude != null
            ? '${locationState.latitude!.toStringAsFixed(4)}, ${locationState.longitude!.toStringAsFixed(4)}'
            : 'Dhaka, Bangladesh');
    final statusMessage =
        locationState.error ??
        (locationState.permissionGranted
            ? 'Live updates are active'
            : 'Enable location to refine nearby rides');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Location',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (locationState.isLoading)
                  Shimmer.fromColors(
                    baseColor: AppTheme.lightTextColor.withOpacity(0.6),
                    highlightColor: Colors.white,
                    child: Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTextColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  )
                else
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextColor,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  statusMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: _refreshRotation,
            duration: const Duration(milliseconds: 600),
            child: IconButton(
              iconSize: 28,
              onPressed: locationState.isLoading
                  ? null
                  : _triggerLocationRefresh,
              icon: locationState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final locationState = ref.watch(locationProvider);
    final pingState = ref.watch(pingProvider);
    ref.listen<UserLocationState>(locationProvider, (previous, next) {
      if (next.latitude != null && next.longitude != null) {
        _loadNearbyRides(lat: next.latitude, lng: next.longitude);
      }
    });
    final user = authState.user;
    final now = DateTime.now();
    const activeStatuses = {'open', 'matched'};
    final activeMyRides = pingState.myPings
        .where(
          (ping) =>
              activeStatuses.contains(ping.status) &&
              ping.expiresAt.isAfter(now),
        )
        .toList();
    final nearbyActive = pingState.nearbyPings
        .where(
          (ping) =>
              activeStatuses.contains(ping.status) &&
              ping.expiresAt.isAfter(now),
        )
        .toList();
    final filteredNearby = _destinationFilter.isEmpty
        ? nearbyActive
        : nearbyActive.where((ping) {
            final destination = ping.destinationLabel.toLowerCase();
            final pickup = (ping.pickupLabel).toLowerCase();
            final query = _destinationFilter.toLowerCase();
            return destination.contains(query) || pickup.contains(query);
          }).toList();
    final userName = user?.name ?? '';
    final displayName = userName.isNotEmpty ? userName : 'User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('LetzGo'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: false,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadNearbyRides();
          _loadMyRides();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HomeHeader(
              displayName: displayName,
              initial: userInitial,
              rating: user?.ratingAvg ?? 0.0,
              onHostRide: () => context.push('/host-ride'),
              onFindRide: () => context.push('/discover'),
            ),
            const SizedBox(height: 24),
            _buildLocationCard(locationState),
            const SizedBox(height: 24),
            HomeFilters(
              destinationFilterController: _destinationFilterController,
              destinationFilter: _destinationFilter,
              radiusMeters: _selectedRadiusMeters,
              gender: _selectedGender,
              onClearDestination: () {
                _destinationFilterController.clear();
                setState(() {
                  _destinationFilter = '';
                });
              },
              onDestinationChanged: (value) {
                setState(() {
                  _destinationFilter = value.trim();
                });
              },
            ),
            const SizedBox(height: 24),
            MyRidesSection(
              activeRides: activeMyRides,
              onRideTap: (id) => context.push('/ride-details/$id'),
            ),
            NearbyRidesSection(
              nearbyPings: nearbyActive,
              filteredNearby: filteredNearby,
              isLoading: pingState.isLoading,
              onFiltersPressed: () => _showNearbyFilterSheet(context),
              onSeeAll: () => context.push('/discover'),
              onRideTap: (id) => context.push('/ride-details/$id'),
            ),
          ],
        ),
      ),
    );
  }
}
