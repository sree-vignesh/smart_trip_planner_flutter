import 'package:flutter/material.dart';
import 'package:smart_trip_planner/core/colors.dart';
import '../models/itinerary.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryScreen extends StatelessWidget {
  final Itinerary itinerary;
  const ItineraryScreen({required this.itinerary, super.key});

  // Helper function
  Future<void> _openMap(BuildContext context, String location) async {
    final loc = location.isNotEmpty ? location : "0,0";
    final encodedLocation = Uri.encodeComponent(loc);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedLocation',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening map: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromRGBO(255, 250, 247, 1),
      appBar: AppBar(
        title: Text(
          itinerary.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black87,
        // centerTitle: true,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        // ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemCount: itinerary.days.length,
        itemBuilder: (context, index) {
          final day = itinerary.days[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Card(
              color: AppColors.cardBackground,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                // collapsedBackgroundColor: Colors.white,
                // backgroundColor: Colors.white,
                iconColor: AppColors.primary,
                collapsedIconColor: Colors.grey[600],
                title: Text(
                  day.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    day.summary,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                children: day.items.map((activity) {
                  final location = activity.location.isNotEmpty
                      ? activity.location
                      : "0,0";
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          activity.time,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        activity.activity,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.map_rounded,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _openMap(context, activity.location),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
