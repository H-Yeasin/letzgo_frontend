import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/defi_theme_extension.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/defi/defi_glass_card.dart';
import '../../../widgets/defi/defi_skeleton.dart';
import '../models/location_selection.dart';

/// Debounced place search that floats over the map. Queries the backend
/// geocoder and shows an animated results dropdown.
class LocationSearchField extends ConsumerStatefulWidget {
  final String hintText;
  final ValueChanged<LocationSelection> onResultSelected;

  const LocationSearchField({
    super.key,
    required this.hintText,
    required this.onResultSelected,
  });

  @override
  ConsumerState<LocationSearchField> createState() =>
      _LocationSearchFieldState();
}

class _LocationSearchFieldState extends ConsumerState<LocationSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  int _requestSeq = 0;
  List<LocationSelection> _results = const [];
  bool _isLoading = false;
  bool _showResults = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      _requestSeq++;
      setState(() {
        _results = const [];
        _isLoading = false;
        _showResults = false;
      });
      return;
    }
    _debounce = Timer(400.ms, () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    final seq = ++_requestSeq;
    setState(() {
      _isLoading = true;
      _showResults = true;
    });
    List<LocationSelection> results = const [];
    try {
      final raw =
          await ref.read(apiServiceProvider).searchLocation(query, limit: 5);
      results = raw
          .where((r) => r['lat'] is num && r['lng'] is num)
          .map(LocationSelection.fromSearchResult)
          .toList();
    } catch (_) {
      // Fall through with empty results; the dropdown shows "No places found".
    }
    if (!mounted || seq != _requestSeq) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _select(LocationSelection selection) {
    _debounce?.cancel();
    _requestSeq++;
    _controller.text = selection.label;
    _focusNode.unfocus();
    setState(() => _showResults = false);
    widget.onResultSelected(selection);
  }

  void _clear() {
    _debounce?.cancel();
    _requestSeq++;
    _controller.clear();
    setState(() {
      _results = const [];
      _isLoading = false;
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final defi = context.defi;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DefiGlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            style: TextStyle(color: defi.fg, fontSize: 15),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TextStyle(color: defi.fgMuted),
              icon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close, size: 18, color: defi.fgMuted),
                      onPressed: _clear,
                    ),
            ),
          ),
        ),
        if (_showResults) ...[
          const SizedBox(height: 8),
          DefiGlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _buildResults(defi),
          ).animate().fadeIn(duration: 150.ms).slideY(begin: -0.05),
        ],
      ],
    );
  }

  Widget _buildResults(DefiThemeExtension defi) {
    if (_isLoading) {
      return Column(
        children: List.generate(
          3,
          (i) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DefiSkeleton(height: 14),
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          'No places found',
          style: TextStyle(color: defi.fgMuted, fontSize: 14),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_results.length.clamp(0, 4), (i) {
        final result = _results[i];
        return InkWell(
          onTap: () => _select(result),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.place_outlined, size: 18, color: defi.fgMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: defi.fg, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (i * 50).ms, duration: 200.ms);
      }),
    );
  }
}
