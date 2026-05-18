import 'package:flutter/material.dart';

class HomeFilters extends StatelessWidget {
  final TextEditingController destinationFilterController;
  final String destinationFilter;
  final double radiusMeters;
  final String gender;
  final VoidCallback onClearDestination;
  final ValueChanged<String> onDestinationChanged;

  const HomeFilters({
    super.key,
    required this.destinationFilterController,
    required this.destinationFilter,
    required this.radiusMeters,
    required this.gender,
    required this.onClearDestination,
    required this.onDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: destinationFilterController,
          decoration: InputDecoration(
            hintText: 'Filter by destination or pickup',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            suffixIcon: destinationFilter.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClearDestination,
                  )
                : null,
          ),
          onChanged: onDestinationChanged,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(
              label: Text(
                'Radius ${(radiusMeters / 1000).toStringAsFixed(1)} km',
              ),
            ),
            Chip(label: Text('Gender: ${_genderLabel(gender)}')),
            if (destinationFilter.isNotEmpty)
              Chip(label: Text('Destination: "$destinationFilter"')),
          ],
        ),
      ],
    );
  }

  String _genderLabel(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return 'Any';
    }
  }
}
