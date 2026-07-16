import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/defi_theme_extension.dart';
import '../../../widgets/defi/defi_glow_text.dart';
import '../host_ride_draft_provider.dart';
import '../widgets/review_summary_card.dart';

/// Step 5 — summary of the whole draft before posting.
class ReviewStep extends ConsumerWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defi = context.defi;
    final draft = ref.watch(hostRideDraftProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DefiGlowText(
            text: 'Ready to post?',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Double-check the details — riders nearby will see this ping.',
            style: TextStyle(fontSize: 14, color: defi.fgMuted),
          ),
          const SizedBox(height: 24),
          ReviewSummaryCard(draft: draft),
          if (draft.submitError != null) ...[
            const SizedBox(height: 16),
            Text(
              draft.submitError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: defi.danger, fontSize: 13),
            ).animate().fadeIn(duration: 200.ms),
          ],
        ],
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06),
    );
  }
}
