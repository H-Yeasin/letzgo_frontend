import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letzgo_app/providers/api_provider.dart';
import '../models/ride_ping.dart';
import '../services/api_service.dart';

class NotificationState {
  final bool isLoading;
  final List<Notification> notifications;
  final int unreadCount;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<Notification>? notifications,
    int? unreadCount,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiService _api;

  NotificationNotifier(this._api) : super(const NotificationState());

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getNotifications();
      final items = (data['items'] as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList();
      final unread = items.where((n) => !n.isRead).length;
      state = state.copyWith(
        isLoading: false,
        notifications: items,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.markNotificationRead(notificationId);
      await fetchNotifications();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      state = state.copyWith(unreadCount: 0);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier(ref.read(apiServiceProvider));
    });
