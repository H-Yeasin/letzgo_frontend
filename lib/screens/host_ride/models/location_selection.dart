/// A resolved place: a human-readable label plus coordinates.
///
/// Produced by the map pin (reverse geocode), the search field
/// (forward geocode) or the device location provider.
class LocationSelection {
  final String label;
  final double lat;
  final double lng;

  const LocationSelection({
    required this.label,
    required this.lat,
    required this.lng,
  });

  /// Builds a selection from a `/geocode/search` result row.
  factory LocationSelection.fromSearchResult(Map<String, dynamic> json) {
    return LocationSelection(
      label: shortenAddress(json['display_name'] as String? ?? 'Unknown place'),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  /// Keeps the first three comma-separated parts of a geocoder address.
  static String shortenAddress(String address) {
    final parts = address.split(',');
    final short = parts.take(3).join(',').trim();
    return short.isEmpty ? address : short;
  }
}
