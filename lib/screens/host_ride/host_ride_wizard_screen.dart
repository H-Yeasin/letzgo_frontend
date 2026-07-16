import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/defi_theme_extension.dart';
import '../../providers/location_provider.dart';
import '../../widgets/defi/defi_button.dart';
import '../../widgets/defi/defi_grid_background.dart';
import 'host_ride_draft_provider.dart';
import 'steps/destination_location_step.dart';
import 'steps/fare_step.dart';
import 'steps/pickup_location_step.dart';
import 'steps/preferences_step.dart';
import 'steps/review_step.dart';
import 'widgets/ride_posted_overlay.dart';
import 'widgets/wizard_progress_header.dart';

/// Multi-step "host a ride" wizard: pickup → destination → fare →
/// preferences → review. Driven by Continue buttons, no swipe.
class HostRideWizardScreen extends ConsumerStatefulWidget {
  const HostRideWizardScreen({super.key});

  @override
  ConsumerState<HostRideWizardScreen> createState() =>
      _HostRideWizardScreenState();
}

class _HostRideWizardScreenState extends ConsumerState<HostRideWizardScreen> {
  static const _totalSteps = 5;

  final _pageController = PageController();
  int _step = 0;
  bool _posted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).refreshLocation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _back() {
    if (_step > 0) {
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOut);
    }
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
    }
  }

  Future<void> _submit() async {
    final ping = await ref.read(hostRideDraftProvider.notifier).submit();
    if (ping != null && mounted) {
      setState(() => _posted = true);
    }
  }

  String get _buttonLabel {
    if (_step == 0) return 'Confirm pickup';
    if (_step == 1) return 'Confirm destination';
    if (_step == _totalSteps - 1) return 'Post ride';
    return 'Continue';
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;
    final draft = ref.watch(hostRideDraftProvider);

    final bool canContinue;
    switch (_step) {
      case 0:
        canContinue = draft.isPickupValid;
      case 1:
        canContinue = draft.isDestinationValid;
      case 2:
        canContinue = draft.isFareValid;
      default:
        canContinue = true;
    }

    final isLastStep = _step == _totalSteps - 1;
    final VoidCallback? onPressed = isLastStep
        ? (draft.isSubmitting ? null : _submit)
        : (canContinue ? _next : null);

    return PopScope(
      canPop: _step == 0 && !draft.isSubmitting && !_posted,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0 && !draft.isSubmitting && !_posted) _back();
      },
      child: Scaffold(
        backgroundColor: defi.bg,
        body: Stack(
          children: [
            DefiGridBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    WizardProgressHeader(
                      step: _step,
                      total: _totalSteps,
                      onBack: _back,
                      onClose: () => context.pop(),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) => setState(() => _step = i),
                        children: const [
                          PickupLocationStep(),
                          DestinationLocationStep(),
                          FareStep(),
                          PreferencesStep(),
                          ReviewStep(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                      child: DefiButton(
                        label: _buttonLabel,
                        fullWidth: true,
                        loading: isLastStep && draft.isSubmitting,
                        onPressed: onPressed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_posted)
              Positioned.fill(
                child: RidePostedOverlay(
                  onDone: () {
                    if (mounted) context.pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
