import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letzgo_app/models/ride_ping.dart';
import 'package:letzgo_app/providers/api_provider.dart';
import 'package:letzgo_app/services/api_service.dart';

class ChatState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final String? error;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _api;

  ChatNotifier(this._api) : super(const ChatState());

  Future<void> fetchMessages(String matchId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getMessages(matchId);
      final items = data
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, messages: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Silent refresh — does NOT set isLoading, used for polling so the UI
  /// doesn't flash a spinner on every tick.
  Future<void> silentRefresh(String matchId) async {
    try {
      final data = await _api.getMessages(matchId);
      final incoming = data
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      // Only update state if there are new messages
      if (incoming.length != state.messages.length) {
        state = state.copyWith(messages: incoming);
      }
    } catch (_) {
      // Swallow errors during background polling
    }
  }

  Future<bool> sendMessage(String matchId, String content, String currentUserId) async {
    // Optimistic update: add a temporary message immediately so the UI
    // responds at once — no waiting for the network round-trip.
    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      matchId: matchId,
      senderId: currentUserId,
      message: content,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, tempMsg]);

    try {
      await _api.sendMessage(matchId, content);
      // Silent refresh to get the real server message (replaces the temp one)
      await silentRefresh(matchId);
      return true;
    } catch (e) {
      // Roll back the optimistic message on failure
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempMsg.id).toList(),
        error: e.toString(),
      );
      return false;
    }
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>((
      ref,
      matchId,
    ) {
      return ChatNotifier(ref.read(apiServiceProvider));
    });
