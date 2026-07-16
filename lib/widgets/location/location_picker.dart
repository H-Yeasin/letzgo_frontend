import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/app_colors.dart';
import '../../constants/defi_theme_extension.dart';
import '../../models/location_selection.dart';
import '../../providers/api_provider.dart';
import '../../providers/location_provider.dart';
import '../defi/defi_glass_card.dart';
import '../defi/defi_glow_text.dart';
import '../defi/defi_skeleton.dart';
import '../location_settings_dialog.dart';
import 'location_search_field.dart';
import 'map_pin_icon.dart';

/// Full-height map picker with a fixed center pin: pan the map to drop the
/// pin, tap to jump, search, or use the device location. Resolves the pin
/// position to an address and reports it via [onSelected].
class LocationPicker extends ConsumerStatefulWidget {
  final String title;
  final String searchHint;
  final LocationSelection? initialSelection;

  /// The already-chosen counterpart point (e.g. pickup while picking the
  /// destination), rendered as a marker so the trip visually forms.
  final LocationSelection? otherPoint;

  /// Origin styling (green trip-origin icon) vs destination styling.
  final bool isOrigin;

  /// Auto-fill the selection from the device location when nothing is
  /// chosen yet (pickup step behavior).
  final bool autoSelectDeviceLocation;

  /// Unique hero tag for the my-location FAB (avoid collisions when
  /// multiple pickers can be on screen across routes).
  final String? heroTag;

  final ValueChanged<LocationSelection> onSelected;

  const LocationPicker({
    super.key,
    required this.title,
    required this.searchHint,
    required this.onSelected,
    this.initialSelection,
    this.otherPoint,
    this.isOrigin = false,
    this.autoSelectDeviceLocation = false,
    this.heroTag,
  });

  @override
  ConsumerState<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends ConsumerState<LocationPicker> {
  static const double _fallbackLat = 23.8103; // Dhaka
  static const double _fallbackLng = 90.4125;

  final _mapController = MapController();
  StreamSubscription<MapEvent>? _mapEventsSub;
  Timer? _resolveDebounce;
  int _resolveSeq = 0;

  LocationSelection? _selection;
  bool _isPanning = false;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection;
    _mapEventsSub = _mapController.mapEventStream.listen(_onMapEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.autoSelectDeviceLocation && _selection == null) {
        _applyDeviceLocation(ref.read(locationProvider));
      }
    });
  }

  @override
  void dispose() {
    _resolveDebounce?.cancel();
    _mapEventsSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _initialCenter {
    final selection = _selection;
    if (selection != null) return LatLng(selection.lat, selection.lng);
    final location = ref.read(locationProvider);
    if (location.latitude != null && location.longitude != null) {
      return LatLng(location.latitude!, location.longitude!);
    }
    return const LatLng(_fallbackLat, _fallbackLng);
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveStart || event is MapEventFlingAnimationStart) {
      if (!_isPanning) setState(() => _isPanning = true);
      return;
    }
    if (event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventDoubleTapZoomEnd ||
        event is MapEventScrollWheelZoom) {
      if (_isPanning) setState(() => _isPanning = false);
      _scheduleResolve(event.camera.center);
    }
  }

  /// Debounced pin-position -> address resolution. Skips when the center
  /// already matches the current selection (programmatic moves).
  void _scheduleResolve(LatLng center) {
    _resolveDebounce?.cancel();
    final selection = _selection;
    if (selection != null &&
        (center.latitude - selection.lat).abs() < 1e-6 &&
        (center.longitude - selection.lng).abs() < 1e-6) {
      return;
    }
    _resolveDebounce = Timer(500.ms, () => _resolveCenter(center));
  }

  Future<void> _resolveCenter(LatLng center) async {
    final seq = ++_resolveSeq;
    setState(() => _isResolving = true);

    String label;
    try {
      final api = ref.read(apiServiceProvider);
      try {
        final address = await api.reverseGeocode(
          lat: center.latitude,
          lng: center.longitude,
        );
        label = LocationSelection.shortenAddress(address);
      } catch (_) {
        final coordStr = '${center.latitude.toStringAsFixed(6)}, '
            '${center.longitude.toStringAsFixed(6)}';
        final results = await ref
            .read(apiServiceProvider)
            .searchLocation(coordStr, limit: 1);
        label = results.isNotEmpty
            ? LocationSelection.shortenAddress(
                results.first['display_name'] as String)
            : coordStr;
      }
    } catch (_) {
      label = '${center.latitude.toStringAsFixed(4)}, '
          '${center.longitude.toStringAsFixed(4)}';
    }

    if (!mounted || seq != _resolveSeq) return;
    final selection = LocationSelection(
      label: label,
      lat: center.latitude,
      lng: center.longitude,
    );
    setState(() {
      _selection = selection;
      _isResolving = false;
    });
    widget.onSelected(selection);
  }

  void _onSearchSelected(LocationSelection selection) {
    _resolveDebounce?.cancel();
    _resolveSeq++; // invalidate any in-flight reverse geocode
    setState(() {
      _selection = selection;
      _isResolving = false;
    });
    widget.onSelected(selection);
    _moveMap(LatLng(selection.lat, selection.lng), 16);
  }

  void _onMapTap(LatLng point) {
    _moveMap(point, _mapController.camera.zoom);
    _scheduleResolve(point);
  }

  void _goToMyLocation() {
    final location = ref.read(locationProvider);
    if (location.permissionDeniedForever) {
      showLocationSettingsDialog(context);
      return;
    }
    ref.read(locationProvider.notifier).refreshLocation();
    if (location.latitude != null && location.longitude != null) {
      _applyDeviceLocation(location, force: true);
    }
  }

  void _applyDeviceLocation(UserLocationState location, {bool force = false}) {
    final lat = location.latitude;
    final lng = location.longitude;
    if (lat == null || lng == null) return;
    if (!force && _selection != null) return;
    final point = LatLng(lat, lng);
    _moveMap(point, 16);
    if (location.displayName != null && location.displayName!.isNotEmpty) {
      _resolveDebounce?.cancel();
      _resolveSeq++;
      final selection = LocationSelection(
        label: location.displayName!,
        lat: lat,
        lng: lng,
      );
      setState(() {
        _selection = selection;
        _isResolving = false;
      });
      widget.onSelected(selection);
    } else {
      _scheduleResolve(point);
    }
  }

  void _moveMap(LatLng point, double zoom) {
    try {
      _mapController.move(point, zoom);
    } catch (_) {
      // Map not rendered yet; the initial center handles this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    final accent = widget.isOrigin ? defi.success : AppColors.secondary;

    ref.listen<UserLocationState>(locationProvider, (previous, next) {
      if (!widget.autoSelectDeviceLocation || _selection != null) return;
      _applyDeviceLocation(next);
    });

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 15,
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.letzgo.app',
              ),
              if (widget.otherPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        widget.otherPoint!.lat,
                        widget.otherPoint!.lng,
                      ),
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: defi.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: defi.success.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Fixed center pin — the tip points at the map center.
        Center(
          child: IgnorePointer(
            child: _CenterPin(lifted: _isPanning, color: accent),
          ),
        ),

        // Readability scrim behind the title + search overlay.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 150,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    defi.bg.withValues(alpha: 0.85),
                    defi.bg.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Title + search.
        Positioned(
          top: 8,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefiGlowText(
                text: widget.title,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.2),
              const SizedBox(height: 12),
              LocationSearchField(
                hintText: widget.searchHint,
                onResultSelected: _onSearchSelected,
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            ],
          ),
        ),

        // My-location FAB + resolved address card.
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: widget.heroTag ??
                    'locate_${widget.isOrigin ? 'pickup' : 'destination'}',
                onPressed: _goToMyLocation,
                backgroundColor: defi.surfaceElevated,
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              _AddressCard(
                key: ValueKey(_isResolving ? '...' : _selection?.label),
                selection: _selection,
                isResolving: _isResolving,
                isOrigin: widget.isOrigin,
                accent: accent,
              ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterPin extends StatelessWidget {
  final bool lifted;
  final Color color;

  const _CenterPin({required this.lifted, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      // Lift the artwork so the pin tip sits at the map center.
      offset: const Offset(0, -26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSlide(
            offset: lifted ? const Offset(0, -0.18) : Offset.zero,
            duration: 150.ms,
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MapPinIcon(
                  size: 46,
                  color: color,
                ),
                AnimatedContainer(
                  duration: 150.ms,
                  width: lifted ? 14 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().scale(
            begin: const Offset(0.4, 0.4),
            curve: Curves.easeOutBack,
            duration: 400.ms,
          ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final LocationSelection? selection;
  final bool isResolving;
  final bool isOrigin;
  final Color accent;

  const _AddressCard({
    super.key,
    required this.selection,
    required this.isResolving,
    required this.isOrigin,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    return DefiGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOrigin ? Icons.trip_origin : Icons.location_on,
              size: 18,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrigin ? 'PICKUP' : 'DESTINATION',
                  style: TextStyle(
                    color: defi.fgMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (isResolving)
                  const DefiSkeleton(height: 14, width: 180)
                else
                  Text(
                    selection?.label ?? 'Move the map to drop your pin',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selection != null ? defi.fg : defi.fgMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (selection != null && !isResolving)
            Icon(Icons.check_circle, size: 20, color: defi.success),
        ],
      ),
    );
  }
}
