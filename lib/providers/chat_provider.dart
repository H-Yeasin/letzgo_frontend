import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ride_ping.dart';
import '../services/api_service.dart';
import 'ping_provider.dart';

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
      final items = (data['items'] as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, messages: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> sendMessage(String matchId, String content) async {
    try {
      await _api.sendMessage(matchId, content);
      await fetchMessages(matchId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
