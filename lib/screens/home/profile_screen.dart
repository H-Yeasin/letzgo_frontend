import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.phone ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBadge(
                      icon: Icons.star,
                      value: '${user?.ratingAvg ?? 0.0}',
                      label: 'Rating',
                    ),
                    const SizedBox(width: 24),
                    _StatBadge(
                      icon: Icons.directions_car,
                      value: '${user?.completedRidesCount ?? 0}',
                      label: 'Rides',
                    ),
                    const SizedBox(width: 24),
                    _StatBadge(
                      icon: Icons.verified,
                      value: user?.isVerified ?? false ? 'Yes' : 'No',
                      label: 'Verified',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Menu items
          _MenuTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () => context.push('/edit-profile'),
          ),
          _MenuTile(
            icon: Icons.directions_car_outlined,
            title: 'My Rides',
            onTap: () => context.push('/my-rides'),
          ),
          _MenuTile(
            icon: Icons.history,
            title: 'Ride History',
            onTap: () => context.push('/ride-history'),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: Text(
              '${ref.watch(notificationCountProvider)}',
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
            onTap: () => context.push('/notifications'),
          ),
          const Divider(height: 32),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'About LetzGo',
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.logout,
            title: 'Sign Out',
            iconColor: AppTheme.errorColor,
            titleColor: AppTheme.errorColor,
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/phone-input');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.lightTextColor, fontSize: 12),
        ),
      ],
    );
  }
}

final notificationCountProvider = Provider<int>((ref) {
  final notifState = ref.watch(notificationProvider);
  return notifState.unreadCount;
});
