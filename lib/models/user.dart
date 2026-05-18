class User {
  final String id;
  final String phone;
  final String name;
  final String? gender;
  final String? avatarUrl;
  final double ratingAvg;
  final int completedRidesCount;
  final bool isVerified;
  final bool isOnboardingComplete;
  final DateTime createdAt;

  User({
    required this.id,
    required this.phone,
    required this.name,
    this.gender,
    this.avatarUrl,
    this.ratingAvg = 0.0,
    this.completedRidesCount = 0,
    this.isVerified = false,
    this.isOnboardingComplete = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0.0,
      completedRidesCount:
          (json['completed_rides_count'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isOnboardingComplete: json['is_onboarding_complete'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'gender': gender,
      'avatar_url': avatarUrl,
      'rating_avg': ratingAvg,
      'completed_rides_count': completedRidesCount,
      'is_verified': isVerified,
      'is_onboarding_complete': isOnboardingComplete,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PublicUserProfile {
  final String id;
  final String name;
  final String? gender;
  final String? avatarUrl;
  final double ratingAvg;
  final int completedRidesCount;
  final bool isVerified;

  PublicUserProfile({
    required this.id,
    required this.name,
    this.gender,
    this.avatarUrl,
    this.ratingAvg = 0.0,
    this.completedRidesCount = 0,
    this.isVerified = false,
  });

  factory PublicUserProfile.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String?;
    final fallbackName = json['full_name'] as String?;
    final normalized = (rawName ?? fallbackName)?.trim();
    final name = normalized != null && normalized.isNotEmpty
        ? normalized
        : 'Rider';

    final ratingValue =
        (json['rating_avg'] ?? json['rating']) as num?;

    return PublicUserProfile(
      id: json['id'] as String,
      name: name,
      gender: json['gender'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      ratingAvg: ratingValue?.toDouble() ?? 0.0,
      completedRidesCount:
          (json['completed_rides_count'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
