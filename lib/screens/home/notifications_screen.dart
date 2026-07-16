import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:letzgo_app/providers/api_provider.dart';
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
  final Set<String> _processedRequests = {};
  final Set<String> _processingRequests = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
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
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: notifState.notifications.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notif = notifState.notifications[index];
                  final isMatchRequest =
                      notif.type == 'match_request' && notif.requestId != null;

                  final isProcessed = notif.requestId != null && _processedRequests.contains(notif.requestId);
                  final isProcessing = notif.requestId != null && _processingRequests.contains(notif.requestId);

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notif.isRead
                              ? theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.1,
                                )
                              : AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            _getNotificationIcon(notif.type),
                            color: notif.isRead
                                ? theme.colorScheme.onSurfaceVariant
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
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          if (!notif.isRead) {
                            ref
                                .read(notificationProvider.notifier)
                                .markAsRead(notif.id);
                          }
                          if (notif.relatedId != null && !isMatchRequest) {
                            context.push('/ride-details/${notif.relatedId}');
                          }
                        },
                      ),
                      if (isMatchRequest && !isProcessed)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 72,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: isProcessing ? null : () async {
                                  setState(() => _processingRequests.add(notif.requestId!));
                                  try {
                                    await ref
                                        .read(apiServiceProvider)
                                        .acceptMatchRequest(notif.requestId!);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request accepted'),
                                        ),
                                      );
                                      setState(() => _processedRequests.add(notif.requestId!));
                                      ref
                                          .read(notificationProvider.notifier)
                                          .fetchNotifications();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      setState(() => _processedRequests.add(notif.requestId!)); // Hide if it was already processed
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(content: Text('Request already processed or an error occurred.')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _processingRequests.remove(notif.requestId!));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: isProcessing 
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Accept'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: isProcessing ? null : () async {
                                  setState(() => _processingRequests.add(notif.requestId!));
                                  try {
                                    await ref
                                        .read(apiServiceProvider)
                                        .declineMatchRequest(notif.requestId!);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request declined'),
                                        ),
                                      );
                                      setState(() => _processedRequests.add(notif.requestId!));
                                      ref
                                          .read(notificationProvider.notifier)
                                          .fetchNotifications();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      setState(() => _processedRequests.add(notif.requestId!));
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(content: Text('Request already processed or an error occurred.')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _processingRequests.remove(notif.requestId!));
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: isProcessing 
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Decline'),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  if (!notif.isRead) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .markAsRead(notif.id);
                                  }
                                  context.push(
                                    '/chat/${notif.requestId}?isRequest=true',
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline),
                                color: AppTheme.primaryColor,
                                tooltip: 'Message',
                              ),
                            ],
                          ),
                        ),
                    ],
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
