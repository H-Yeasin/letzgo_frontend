import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/defi_theme_extension.dart';
import '../../../widgets/defi/defi_badge.dart';
import '../../../widgets/defi/defi_glow_text.dart';
import '../../../widgets/defi/defi_input.dart';
import '../host_ride_draft_provider.dart';
import '../widgets/selection_chip.dart';

/// Step 3 — set the per-seat fare (big numeric entry + quick amounts)
/// and an optional meetup point.
class FareStep extends ConsumerStatefulWidget {
  const FareStep({super.key});

  @override
  ConsumerState<FareStep> createState() => _FareStepState();
}

class _FareStepState extends ConsumerState<FareStep> {
  static const _quickAmounts = [50, 100, 200, 500];

  late final TextEditingController _fareController;
  late final TextEditingController _meetupController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(hostRideDraftProvider);
    _fareController = TextEditingController(text: draft.fareText);
    _meetupController = TextEditingController(text: draft.meetupPoint);
  }

  @override
  void dispose() {
    _fareController.dispose();
    _meetupController.dispose();
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _fareController.text = '$amount';
    ref.read(hostRideDraftProvider.notifier).setFareText('$amount');
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    final draft = ref.watch(hostRideDraftProvider);
    final notifier = ref.read(hostRideDraftProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DefiGlowText(
            text: 'What\'s the fare?',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated cost per seat — riders see this before hopping in.',
            style: TextStyle(fontSize: 14, color: defi.fgMuted),
          ),
          const SizedBox(height: 36),

          // Big fare entry
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '৳',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: defi.fgMuted,
                ),
              ),
              const SizedBox(width: 8),
              IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 72),
                  child: TextField(
                    controller: _fareController,
                    onChanged: notifier.setFareText,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,4}\.?\d{0,2}'),
                      ),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: defi.fg,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: defi.fgDim),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (draft.fareError != null)
            Center(
              child: Text(
                draft.fareError!,
                style: TextStyle(color: defi.danger, fontSize: 13),
              ).animate().fadeIn(duration: 200.ms),
            ),
          const SizedBox(height: 24),

          // Quick amounts
          Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_quickAmounts.length, (i) {
                final amount = _quickAmounts[i];
                return SelectionChip(
                  label: '৳$amount',
                  isSelected: draft.fareText.trim() == '$amount',
                  onTap: () => _setQuickAmount(amount),
                )
                    .animate()
                    .fadeIn(delay: (i * 80).ms, duration: 250.ms)
                    .slideX(begin: 0.1);
              }),
            ),
          ),
          const SizedBox(height: 40),

          // Meetup point (optional)
          Row(
            children: [
              Text(
                'Meetup point',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: defi.fg,
                ),
              ),
              const SizedBox(width: 8),
              const DefiBadge(
                label: 'OPTIONAL',
                variant: DefiBadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'A landmark that makes you easy to find.',
            style: TextStyle(fontSize: 12, color: defi.fgMuted),
          ),
          const SizedBox(height: 8),
          DefiInput(
            controller: _meetupController,
            hintText: 'e.g., in front of the campus gate',
            prefixIcon: const Icon(Icons.flag_outlined),
            textCapitalization: TextCapitalization.sentences,
            onChanged: notifier.setMeetupPoint,
          ),
        ],
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06),
    );
  }
}
