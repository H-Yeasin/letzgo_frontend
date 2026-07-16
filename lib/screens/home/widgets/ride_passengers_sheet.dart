import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:letzgo_app/constants/theme.dart';
import 'package:letzgo_app/models/ride_ping.dart';
import 'package:letzgo_app/providers/api_provider.dart';

class RidePassengersSheet extends ConsumerWidget {
  const RidePassengersSheet({super.key, required this.pingId});

  final String pingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final api = ref.read(apiServiceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_outlined),
                    const SizedBox(width: 12),
                    Text(
                      'Passengers',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: api.getRidePassengers(pingId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'Passenger list is only visible to the host and accepted passengers.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final passengers = (snapshot.data ?? [])
                        .map((e) => RidePassenger.fromJson(e as Map<String, dynamic>))
                        .toList();

                    if (passengers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search, size: 48,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text('No accepted passengers yet.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: passengers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        return _PassengerTile(passenger: passengers[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PassengerTile extends StatelessWidget {
  const _PassengerTile({required this.passenger});
  final RidePassenger passenger;

  @override
  Widget build(BuildContext context) {
    final genderIcon = passenger.gender == 'female'
        ? Icons.female
        : passenger.gender == 'male'
            ? Icons.male
            : Icons.person;
    final genderColor = passenger.gender == 'female'
        ? Colors.pinkAccent
        : passenger.gender == 'male'
            ? Colors.blueAccent
            : Colors.grey;
    final genderLabel = passenger.gender == 'female'
        ? 'Female'
        : passenger.gender == 'male'
            ? 'Male'
            : 'Not specified';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: Text(
          passenger.name.isNotEmpty ? passenger.name[0].toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
      ),
      title: Text(passenger.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Row(
        children: [
          Icon(genderIcon, size: 14, color: genderColor),
          const SizedBox(width: 4),
          Text(genderLabel, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 12),
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(passenger.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: IconButton(
        onPressed: () {
          final router = GoRouter.of(context);
          Navigator.of(context).pop();
          router.push('/chat/${passenger.matchId}');
        },
        icon: const Icon(Icons.chat_bubble_outline),
        color: AppTheme.primaryColor,
        tooltip: 'Message',
      ),
    );
  }
}
