import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          Text(
            'Account',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Get notified about matches'),
                  value: true,
                  onChanged: (_) {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Location Services'),
                  subtitle: const Text('Find nearby rides'),
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preferences
          Text(
            'Preferences',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.straighten,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Default Search Radius'),
                  trailing: const Text('2 km'),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.wc, color: AppTheme.primaryColor),
                  title: const Text('Gender Preference'),
                  trailing: const Text('Any'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About
          Text(
            'About',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('App Version'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
