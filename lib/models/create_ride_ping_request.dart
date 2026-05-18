import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class CreateRidePingRequest {
  final String pickupLabel;
  final String destinationLabel;
  final double pickupLat;
  final double pickupLng;
  final double? destinationLat;
  final double? destinationLng;
  final double estimatedFare;
  final String genderPreference;
  final int maxPassengers;
  final String? meetupPoint;
  final int expiresInMinutes;

  CreateRidePingRequest({
    required this.pickupLabel,
    required this.destinationLabel,
    required this.pickupLat,
    required this.pickupLng,
    this.destinationLat,
    this.destinationLng,
    required this.estimatedFare,
    this.genderPreference = 'any',
    this.maxPassengers = 1,
    this.meetupPoint,
    this.expiresInMinutes = 30,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'pickup_label': pickupLabel,
      'destination_label': destinationLabel,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'estimated_fare': estimatedFare,
      'gender_preference': genderPreference,
      'max_passengers': maxPassengers,
      'expires_in_minutes': expiresInMinutes,
    };
    if (destinationLat != null) map['destination_lat'] = destinationLat;
    if (destinationLng != null) map['destination_lng'] = destinationLng;
    if (meetupPoint != null && meetupPoint!.isNotEmpty) {
      map['meetup_point'] = meetupPoint;
    }
    return map;
  }

  /// Try to geocode a text address to coordinates using backend geocoder.
  /// Returns null if geocoding fails (caller should use a fallback or stop).
  static Future<Position?> geocodeAddress(String address) async {
    try {
      final results = await ApiService().searchLocation(address, limit: 1);
      if (results.isNotEmpty) {
        final lat = (results.first['lat'] as num).toDouble();
        final lng = (results.first['lng'] as num).toDouble();
        return Position(
          longitude: lng,
          latitude: lat,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (_) {
      // Geocoding failed – return null so the caller can handle it.
    }
    return null;
  }
}
