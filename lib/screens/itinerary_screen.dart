import 'package:flutter/material.dart';
import 'package:smart_trip_planner/core/colors.dart';
import '../models/itinerary.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryScreen extends StatelessWidget {
  final Itinerary itinerary;
  const ItineraryScreen({required this.itinerary, super.key});

  Future<void> _openMap(
    BuildContext context,
    String location,
    String activity,
  ) async {
    if (location.isEmpty) location = "0,0";
    final latLng = location.split(',');
    final lat = latLng[0];
    final lng = latLng[1];
    print(activity);

    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($activity)');
    final browserUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      // Try launching geo URI directly
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // fallback to browser
      await launchUrl(browserUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        title: Text(
          itinerary.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: itinerary.days.length,
        itemBuilder: (context, index) {
          final day = itinerary.days[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day Header
                  Text(
                    "Day ${index + 1} - ${day.date}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    day.summary,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const Divider(height: 20, thickness: 1),

                  // Activities (all inside this card)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: day.items.map((activity) {
                      final location = activity.location.isNotEmpty
                          ? activity.location
                          : "0,0";
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "• ",
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${activity.time} — ${activity.activity}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.map_rounded,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () => _openMap(
                                          context,
                                          activity.location,
                                          activity.activity,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
