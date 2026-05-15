import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ride_ping.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class PingState {
  final bool isLoading;
  final List<RidePing> nearbyPings;
  final RidePing? selectedPing;
  final List<RidePing> myPings;
  final String? error;

  const PingState({
    this.isLoading = false,
    this.nearbyPings = const [],
    this.selectedPing,
    this.myPings = const [],
    this.error,
  });

  PingState copyWith({
    bool? isLoading,
    List<RidePing>? nearbyPings,
    RidePing? selectedPing,
    List<RidePing>? myPings,
    String? error,
  }) {
    return PingState(
      isLoading: isLoading ?? this.isLoading,
      nearbyPings: nearbyPings ?? this.nearbyPings,
      selectedPing: selectedPing ?? this.selectedPing,
      myPings: myPings ?? this.myPings,
      error: error,
    );
  }
}

class PingNotifier extends StateNotifier<PingState> {
  final ApiService _api;

  PingNotifier(this._api) : super(const PingState());

  Future<void> fetchNearbyPings({
    required double lat,
    required double lng,
    double radius = 500.0,
    String? gender,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getNearbyPings(
        lat: lat,
        lng: lng,
        radius: radius,
        gender: gender,
      );
      final items = (data['items'] as List)
          .map((e) => RidePing.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, nearbyPings: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<RidePing?> getPingDetails(String pingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getPingDetails(pingId);
      final ping = RidePing.fromJson(data);
      state = state.copyWith(isLoading: false, selectedPing: ping);
      return ping;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<RidePing?> createPing(Map<String, dynamic> pingData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.createPing(pingData);
      final ping = RidePing.fromJson(data);
      state = state.copyWith(isLoading: false);
      return ping;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> cancelPing(String pingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.cancelPing(pingId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final pingProvider = StateNotifierProvider<PingNotifier, PingState>((ref) {
  return PingNotifier(ref.read(apiServiceProvider));
});
