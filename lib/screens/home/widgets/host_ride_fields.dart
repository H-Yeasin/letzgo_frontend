import 'package:flutter/material.dart';

class HostRideFields extends StatelessWidget {
  const HostRideFields({
    super.key,
    required this.pickupController,
    required this.destinationController,
    required this.fareController,
    required this.meetupController,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final TextEditingController fareController;
  final TextEditingController meetupController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: pickupController,
          decoration: const InputDecoration(
            labelText: 'Pickup Area',
            hintText: 'e.g., Gulshan 1',
            prefixIcon: Icon(Icons.trip_origin),
          ),
          validator: _required('Please enter pickup area'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: destinationController,
          decoration: const InputDecoration(
            labelText: 'Destination',
            hintText: 'e.g., Banani 11',
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: _required('Please enter destination'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: fareController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Estimated Fare (Tk)',
            hintText: 'e.g., 200',
            prefixIcon: Icon(Icons.monetization_on),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter estimated fare';
            }
            final fare = double.tryParse(value.trim());
            if (fare == null || fare <= 0) return 'Please enter a valid fare';
            if (fare > 5000) return 'Fare cannot exceed Tk 5,000';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: meetupController,
          decoration: const InputDecoration(
            labelText: 'Meetup Point (optional)',
            hintText: 'e.g., Near Starbucks',
            prefixIcon: Icon(Icons.flag),
          ),
        ),
      ],
    );
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }
}
