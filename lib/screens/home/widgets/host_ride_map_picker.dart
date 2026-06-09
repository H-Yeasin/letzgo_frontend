import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../constants/theme.dart';

class HostRideMapPicker extends StatelessWidget {
  const HostRideMapPicker({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.pickupPoint,
    required this.destinationPoint,
    required this.pickingMode,
    required this.isLoadingAddress,
    required this.onMapTap,
    required this.onCenterOnLocation,
    required this.onPickingModeChanged,
  });

  final MapController mapController;
  final LatLng initialCenter;
  final LatLng? pickupPoint;
  final LatLng? destinationPoint;
  final String pickingMode;
  final bool isLoadingAddress;
  final ValueChanged<LatLng> onMapTap;
  final VoidCallback onCenterOnLocation;
  final ValueChanged<String> onPickingModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 13.0,
                    onTap: (_, point) => onMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.letzgo.app',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
                if (isLoadingAddress)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'host_my_location',
                    onPressed: onCenterOnLocation,
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
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tap map to set:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: 'pickup',
                        label: Text('Pickup', style: TextStyle(fontSize: 12)),
                        icon: Icon(
                          Icons.trip_origin,
                          size: 14,
                          color: Colors.green,
                        ),
                      ),
                      ButtonSegment(
                        value: 'destination',
                        label: Text('Dest', style: TextStyle(fontSize: 12)),
                        icon: Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                    selected: {pickingMode},
                    onSelectionChanged: (set) =>
                        onPickingModeChanged(set.first),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> get _markers => [
        if (pickupPoint != null)
          Marker(
            point: pickupPoint!,
            width: 40,
            height: 40,
            alignment: Alignment.topCenter,
            child: const Icon(
              Icons.location_on,
              color: Colors.green,
              size: 36,
            ),
          ),
        if (destinationPoint != null)
          Marker(
            point: destinationPoint!,
            width: 40,
            height: 40,
            alignment: Alignment.topCenter,
            child: const Icon(
              Icons.location_on,
              color: AppTheme.secondaryColor,
              size: 36,
            ),
          ),
      ];
}
