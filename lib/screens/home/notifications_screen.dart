import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';
import '../../providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(notificationProvider.notifier).fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationProvider.notifier).fetchNotifications(),
        child: notifState.isLoading && notifState.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : notifState.notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: notifState.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notif = notifState.notifications[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notif.isRead
                          ? AppTheme.lightTextColor.withValues(alpha: 0.1)
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        _getNotificationIcon(notif.type),
                        color: notif.isRead
                            ? AppTheme.lightTextColor
                            : AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notif.body, maxLines: 2),
                    trailing: Text(
                      DateFormat('MMM d').format(notif.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                    onTap: () {
                      if (!notif.isRead) {
                        ref
                            .read(notificationProvider.notifier)
                            .markAsRead(notif.id);
                      }
                      if (notif.relatedId != null) {
                        context.push('/ride-details/${notif.relatedId}');
                      }
                    },
                  );
                },
              ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'match_request':
        return Icons.handshake;
      case 'match_accepted':
        return Icons.check_circle;
      case 'match_declined':
        return Icons.cancel;
      case 'ride_started':
        return Icons.directions_car;
      case 'ride_completed':
        return Icons.check;
      case 'new_message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
}
