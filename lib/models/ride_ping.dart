import 'user.dart';

class RidePing {
  final String id;
  final String hostId;
  final String pickupArea;
  final String destinationText;
  final double pickupLat;
  final double pickupLng;
  final double? destinationLat;
  final double? destinationLng;
  final double estimatedFare;
  final double? finalFare;
  final String genderPreference;
  final int passengerLimit;
  final String? meetupPoint;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final PublicUserProfile? host;

  RidePing({
    required this.id,
    required this.hostId,
    required this.pickupArea,
    required this.destinationText,
    required this.pickupLat,
    required this.pickupLng,
    this.destinationLat,
    this.destinationLng,
    required this.estimatedFare,
    this.finalFare,
    this.genderPreference = 'any',
    this.passengerLimit = 1,
    this.meetupPoint,
    this.status = 'open',
    required this.expiresAt,
    required this.createdAt,
    this.host,
  });

  factory RidePing.fromJson(Map<String, dynamic> json) {
    return RidePing(
      id: json['id'] as String,
      hostId: json['host_id'] as String,
      pickupArea: json['pickup_area'] as String,
      destinationText: json['destination_text'] as String,
      pickupLat: (json['pickup_lat'] as num).toDouble(),
      pickupLng: (json['pickup_lng'] as num).toDouble(),
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationLng: (json['destination_lng'] as num?)?.toDouble(),
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      finalFare: (json['final_fare'] as num?)?.toDouble(),
      genderPreference: json['gender_preference'] as String? ?? 'any',
      passengerLimit: json['passenger_limit'] as int? ?? 1,
      meetupPoint: json['meetup_point'] as String?,
      status: json['status'] as String? ?? 'open',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      host: json['host'] != null
          ? PublicUserProfile.fromJson(json['host'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Match {
  final String id;
  final String rideId;
  final String hostId;
  final String guestId;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final RidePing? ride;

  Match({
    required this.id,
    required this.rideId,
    required this.hostId,
    required this.guestId,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    this.ride,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      rideId: json['ride_id'] as String,
      hostId: json['host_id'] as String,
      guestId: json['guest_id'] as String,
      status: json['status'] as String,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      ride: json['ride'] != null
          ? RidePing.fromJson(json['ride'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MatchRequest {
  final String id;
  final String rideId;
  final String guestId;
  final String status;
  final DateTime createdAt;

  MatchRequest({
    required this.id,
    required this.rideId,
    required this.guestId,
    required this.status,
    required this.createdAt,
  });

  factory MatchRequest.fromJson(Map<String, dynamic> json) {
    return MatchRequest(
      id: json['id'] as String,
      rideId: json['ride_id'] as String,
      guestId: json['guest_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ChatMessage {
  final String id;
  final String matchId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Notification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      relatedId: json['related_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
