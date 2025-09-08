import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryScreen extends StatelessWidget {
  final Itinerary itinerary;
  const ItineraryScreen({required this.itinerary, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(itinerary.title)),
      body: ListView.builder(
        itemCount: itinerary.days.length,
        itemBuilder: (context, index) {
          final day = itinerary.days[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text('${day.date} - ${day.summary}'),
              children: day.items.map((activity) {
                return ListTile(
                  title: Text(activity.activity),
                  subtitle: Text(activity.time),
                  trailing: IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${activity.location}',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open map')),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
