import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/theme.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final String matchId;

  const RatingScreen({super.key, required this.matchId});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _rating = 0;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    // TODO: Submit rating via API
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Ride')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 80, color: AppTheme.warningColor),
              const SizedBox(height: 24),
              Text(
                'How was your ride?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rate your experience with your co-rider',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 48,
                      color: index < _rating
                          ? AppTheme.warningColor
                          : AppTheme.lightTextColor,
                    ),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Share your feedback (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitRating,
                  child: const Text('Submit Rating'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
