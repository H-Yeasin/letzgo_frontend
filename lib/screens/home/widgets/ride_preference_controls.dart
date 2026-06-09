import 'package:flutter/material.dart';

class RidePreferenceControls extends StatelessWidget {
  const RidePreferenceControls({
    super.key,
    required this.genderPreference,
    required this.passengerLimit,
    required this.expiryMinutes,
    required this.onGenderChanged,
    required this.onPassengerLimitChanged,
    required this.onExpiryChanged,
  });

  final String genderPreference;
  final int passengerLimit;
  final int expiryMinutes;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<int> onPassengerLimitChanged;
  final ValueChanged<int> onExpiryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender Preference',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'any', label: Text('Any')),
            ButtonSegment(value: 'male', label: Text('Male')),
            ButtonSegment(value: 'female', label: Text('Female')),
          ],
          selected: {genderPreference},
          onSelectionChanged: (set) => onGenderChanged(set.first),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Passenger Limit: $passengerLimit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: passengerLimit > 1
                  ? () => onPassengerLimitChanged(passengerLimit - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$passengerLimit', style: theme.textTheme.titleLarge),
            IconButton(
              onPressed: passengerLimit < 5
                  ? () => onPassengerLimitChanged(passengerLimit + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Expires in: $expiryMinutes minutes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: expiryMinutes.toDouble(),
          min: 10,
          max: 120,
          divisions: 11,
          label: '$expiryMinutes min',
          onChanged: (value) => onExpiryChanged(value.toInt()),
        ),
      ],
    );
  }
}
