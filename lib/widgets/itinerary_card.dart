import 'package:flutter/material.dart';
import 'package:smart_trip_planner/models/itinerary.dart';

class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;

  const ItineraryCard({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itinerary.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("📅 ${itinerary.startDate} → ${itinerary.endDate}"),
            const Divider(),
            ...itinerary.days.map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• ${day.summary}"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
