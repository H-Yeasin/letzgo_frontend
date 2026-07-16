import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ride_ping.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

class MatchState {
  final bool isLoading;
  final List<Match> myMatches;
  final List<MatchRequest> pendingRequests;
  final Set<String> requestedRideIds;
  final Match? activeMatch;
  final String? error;

  const MatchState({
    this.isLoading = false,
    this.myMatches = const [],
    this.pendingRequests = const [],
    this.requestedRideIds = const <String>{},
    this.activeMatch,
    this.error,
  });

  MatchState copyWith({
    bool? isLoading,
    List<Match>? myMatches,
    List<MatchRequest>? pendingRequests,
    Set<String>? requestedRideIds,
    Match? activeMatch,
    String? error,
    bool clearError = false,
  }) {
    return MatchState(
      isLoading: isLoading ?? this.isLoading,
      myMatches: myMatches ?? this.myMatches,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      requestedRideIds: requestedRideIds ?? this.requestedRideIds,
      activeMatch: activeMatch ?? this.activeMatch,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MatchNotifier extends Notifier<MatchState> {
  late final ApiService _api = ref.read(apiServiceProvider);

  @override
  MatchState build() => const MatchState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _handleError(Object e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response!.data is Map) {
        final detail = e.response!.data['detail'];
        if (detail != null) return detail.toString();
      }
      return 'Network error: ${e.response?.statusCode ?? e.message}';
    }
    return e.toString();
  }

  Future<void> fetchMyMatches() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _api.getMyMatches();
      final items = data
          .map((e) => Match.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, myMatches: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _handleError(e));
    }
  }

  Future<Match?> getMatchDetails(String matchId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _api.getMatchDetails(matchId);
      final match = Match.fromJson(data);
      state = state.copyWith(isLoading: false, activeMatch: match);
      return match;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _handleError(e));
      return null;
    }
  }

  Future<bool> requestMatch(String rideId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.requestMatch(rideId);
      final updated = {...state.requestedRideIds, rideId};
      state = state.copyWith(isLoading: false, requestedRideIds: updated);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final updated = {...state.requestedRideIds, rideId};
        state = state.copyWith(isLoading: false, requestedRideIds: updated);
        return true;
      }
      state = state.copyWith(isLoading: false, error: _handleError(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _handleError(e));
      return false;
    }
  }

  Future<void> fetchPendingRequests(String rideId) async {
    state = state.copyWith(pendingRequests: [], clearError: true);
    try {
      final data = await _api.getMatchRequests(rideId);
      final items = data
          .map((e) => MatchRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(pendingRequests: items, clearError: true);
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
    }
  }

  Future<bool> respondToRequest(String requestId, String status) async {
    try {
      await _api.respondToRequest(requestId, status);
      await fetchMyMatches();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  Future<bool> startMatch(String matchId) async {
    try {
      final data = await _api.startMatch(matchId);
      final match = Match.fromJson(data);
      state = state.copyWith(activeMatch: match);
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  Future<bool> completeMatch(String matchId, double finalFare) async {
    try {
      await _api.completeMatch(matchId, finalFare);
      await fetchMyMatches();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  Future<bool> cancelMatch(String matchId) async {
    try {
      await _api.cancelMatch(matchId);
      await fetchMyMatches();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }
}

final matchProvider =
    NotifierProvider<MatchNotifier, MatchState>(MatchNotifier.new);
