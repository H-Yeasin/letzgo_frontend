import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';
import '../../models/location_selection.dart';
import '../../models/ride_ping.dart';
import '../../providers/location_provider.dart';
import '../../providers/ping_provider.dart';
import '../../widgets/defi/defi_button.dart';
import '../../widgets/defi/defi_glass_card.dart';
import '../../widgets/defi/defi_skeleton.dart';
import '../../widgets/location/location_picker.dart';
import '../../widgets/ride_ping_card.dart';

/// Find a Ride — two phases:
///  1. Pick a destination with the shared [LocationPicker] (pin + search).
///  2. Browse matching rides on the map + a draggable results sheet.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const double _fallbackLat = 23.8103; // Dhaka
  static const double _fallbackLng = 90.4125;

  final _resultsMapController = MapController();

  LocationSelection? _destination;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).refreshLocation();
    });
  }

  @override
  void dispose() {
    _resultsMapController.dispose();
    super.dispose();
  }

  void _findRides() {
    final destination = _destination;
    if (destination == null) return;
    setState(() => _showResults = true);

    final location = ref.read(locationProvider);
    ref.read(pingProvider.notifier).findRides(
          currentLat: location.latitude ?? _fallbackLat,
          currentLng: location.longitude ?? _fallbackLng,
          destinationLat: destination.lat,
          destinationLng: destination.lng,
          radius: 500.0,
        );
  }

  void _editDestination() => setState(() => _showResults = false);

  /// Frames the destination plus all result pins in one shot.
  void _fitToResults(List<RidePing> results) {
    final destination = _destination;
    if (destination == null) return;
    final points = <LatLng>[
      LatLng(destination.lat, destination.lng),
      for (final ping in results) LatLng(ping.pickupLat, ping.pickupLng),
    ];
    try {
      if (points.length > 1) {
        _resultsMapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.fromLTRB(48, 140, 48, 320),
          ),
        );
      } else {
        _resultsMapController.move(points.first, 14);
      }
    } catch (_) {
      // Map not rendered yet; initial center already points at the destination.
    }
  }

  void _goToMyLocation() {
    final location = ref.read(locationProvider);
    ref.read(locationProvider.notifier).refreshLocation();
    if (location.latitude != null && location.longitude != null) {
      try {
        _resultsMapController.move(
          LatLng(location.latitude!, location.longitude!),
          14.5,
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    ref.listen<PingState>(pingProvider, (previous, next) {
      if (!_showResults) return;
      final finishedLoading =
          (previous?.isFindLoading ?? false) && !next.isFindLoading;
      if (finishedLoading) _fitToResults(next.findResults);
    });

    return Scaffold(
      backgroundColor: defi.bg,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: 300.ms,
          child: _showResults
              ? _buildResultsPhase(context, key: const ValueKey('results'))
              : _buildPickerPhase(context, key: const ValueKey('picker')),
        ),
      ),
    );
  }

  // ─── Phase 1: destination picking ────────────────────────────

  Widget _buildPickerPhase(BuildContext context, {required Key key}) {
    return Column(
      key: key,
      children: [
        Expanded(
          child: LocationPicker(
            title: 'Where do you\nwant to go?',
            searchHint: 'Search destination',
            initialSelection: _destination,
            heroTag: 'discover_locate',
            onSelected: (selection) =>
                setState(() => _destination = selection),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: DefiButton(
            label: 'Find rides',
            icon: Icons.travel_explore,
            fullWidth: true,
            onPressed: _destination != null ? _findRides : null,
          ),
        ),
      ],
    );
  }

  // ─── Phase 2: results ────────────────────────────────────────

  Widget _buildResultsPhase(BuildContext context, {required Key key}) {
    final defi = context.defi;
    final pingState = ref.watch(pingProvider);
    final location = ref.watch(locationProvider);
    final destination = _destination!;

    return Stack(
      key: key,
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: _resultsMapController,
            options: MapOptions(
              initialCenter: LatLng(destination.lat, destination.lng),
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.letzgo.app',
              ),
              MarkerLayer(
                markers: [
                  // Current location
                  if (location.latitude != null && location.longitude != null)
                    Marker(
                      point: LatLng(location.latitude!, location.longitude!),
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
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
                  // Destination
                  Marker(
                    point: LatLng(destination.lat, destination.lng),
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                      size: 40,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                    ),
                  ),
                  // Ride pins
                  for (final ping in pingState.findResults)
                    Marker(
                      point: LatLng(ping.pickupLat, ping.pickupLng),
                      width: 38,
                      height: 38,
                      child: GestureDetector(
                        onTap: () => context.push('/ride-details/${ping.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: defi.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary),
                            boxShadow: [
                              BoxShadow(
                                color: defi.primaryGlow,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Destination pill — tap to edit.
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: _editDestination,
            child: DefiGlassCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOING TO',
                          style: TextStyle(
                            color: defi.fgMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: defi.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.3),
        ),

        // My-location FAB, above the sheet's resting height.
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).size.height * 0.38 + 12,
          child: FloatingActionButton.small(
            heroTag: 'discover_my_location',
            onPressed: _goToMyLocation,
            backgroundColor: defi.surfaceElevated,
            child: const Icon(
              Icons.my_location,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),

        // Results sheet.
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.18,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: defi.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: defi.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: defi.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Rides heading your way',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: defi.fg,
                        ),
                      ),
                      const Spacer(),
                      if (!pingState.isFindLoading)
                        Text(
                          '${pingState.findResults.length} found',
                          style: TextStyle(color: defi.fgMuted, fontSize: 13),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildSheetBody(pingState, defi),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildSheetBody(PingState pingState, DefiThemeExtension defi) {
    if (pingState.isFindLoading) {
      return List.generate(
        3,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: DefiSkeleton(height: 96, borderRadius: 16),
        ),
      );
    }
    if (pingState.findResults.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: defi.fgDim),
              const SizedBox(height: 12),
              Text(
                'No rides heading there yet.',
                style: TextStyle(color: defi.fgMuted, fontSize: 14),
              ),
              const SizedBox(height: 16),
              DefiButton(
                label: 'Host a ride instead',
                icon: Icons.add,
                variant: DefiButtonVariant.outline,
                onPressed: () => context.push('/host-ride'),
              ),
            ],
          ),
        ),
      ];
    }
    return List.generate(pingState.findResults.length, (i) {
      final ping = pingState.findResults[i];
      return RidePingCard(
        ping: ping,
        onTap: () => context.push('/ride-details/${ping.id}'),
      ).animate().fadeIn(delay: (i * 60).ms, duration: 250.ms).slideY(
            begin: 0.1,
          );
    });
  }
}
