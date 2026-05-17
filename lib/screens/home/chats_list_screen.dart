import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';
import '../../providers/match_provider.dart';
import '../../providers/auth_provider.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(matchProvider.notifier).fetchMyMatches();
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final theme = Theme.of(context);

    // Filter only matched/in_progress matches (active chats)
    final activeMatches = matchState.myMatches
        .where((m) => m.status == 'matched' || m.status == 'in_progress')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(matchProvider.notifier).fetchMyMatches(),
        child: matchState.isLoading && activeMatches.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : activeMatches.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active chats',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Match with a ride to start chatting',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeMatches.length,
                itemBuilder: (context, index) {
                  final match = activeMatches[index];
                  final isHost =
                      match.hostId == ref.read(authProvider).user?.id;
                  final name = match.ride?.host?.name ?? 'Rider';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        isHost ? name : 'Rider',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${match.ride?.pickupLabel ?? ''} → ${match.ride?.destinationLabel ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Chip(
                        label: Text(
                          match.status == 'matched' ? 'Pending' : 'Active',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: match.status == 'in_progress'
                            ? AppTheme.statusOpen.withValues(alpha: 0.1)
                            : AppTheme.statusMatched.withValues(alpha: 0.1),
                      ),
                      onTap: () => context.push('/chat/${match.id}'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
