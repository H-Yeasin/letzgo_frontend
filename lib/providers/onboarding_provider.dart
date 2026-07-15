import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How a rider expects to use LetzGo. There are no fixed roles on the
/// platform — this is a device-local hint used to personalize copy and CTAs.
enum RideIntent { host, join, both }

RideIntent? rideIntentFromName(String? name) {
  if (name == null) return null;
  try {
    return RideIntent.values.byName(name);
  } catch (_) {
    return null;
  }
}

class OnboardingPrefs {
  final bool hasSeenIntro;

  /// null means the rider never chose — treat as [RideIntent.both].
  final RideIntent? rideIntent;

  /// Index into [DefiInitialsAvatar.palette].
  final int avatarStyle;

  const OnboardingPrefs({
    this.hasSeenIntro = false,
    this.rideIntent,
    this.avatarStyle = 0,
  });

  OnboardingPrefs copyWith({
    bool? hasSeenIntro,
    RideIntent? rideIntent,
    int? avatarStyle,
  }) {
    return OnboardingPrefs(
      hasSeenIntro: hasSeenIntro ?? this.hasSeenIntro,
      rideIntent: rideIntent ?? this.rideIntent,
      avatarStyle: avatarStyle ?? this.avatarStyle,
    );
  }
}

/// Locally persisted onboarding state. The backend stores none of this;
/// the splash screen must await [load] before auth resolution so the
/// router redirect sees real values on first navigation.
class OnboardingPrefsNotifier extends Notifier<OnboardingPrefs> {
  static const _intentKey = 'ride_intent';
  static const _avatarKey = 'avatar_style';

  @override
  OnboardingPrefs build() => const OnboardingPrefs();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = OnboardingPrefs(
      // hasSeenIntro defaults to false every cold start — the intro
      // keeps showing until the user authenticates (the router redirect
      // checks isAuthenticated before hasSeenIntro).
      rideIntent: rideIntentFromName(prefs.getString(_intentKey)),
      avatarStyle: prefs.getInt(_avatarKey) ?? 0,
    );
  }

  // Sets the in-memory flag so the current session doesn't re-route
  // back to intro after Skip/Get Started. Never persisted.
  Future<void> markIntroSeen() async {
    state = state.copyWith(hasSeenIntro: true);
  }

  Future<void> setRideIntent(RideIntent intent) async {
    state = state.copyWith(rideIntent: intent);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_intentKey, intent.name);
  }

  Future<void> setAvatarStyle(int styleIndex) async {
    state = state.copyWith(avatarStyle: styleIndex);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_avatarKey, styleIndex);
  }
}

final onboardingPrefsProvider =
    NotifierProvider<OnboardingPrefsNotifier, OnboardingPrefs>(
      OnboardingPrefsNotifier.new,
    );
