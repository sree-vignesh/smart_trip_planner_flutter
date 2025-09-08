import 'package:flutter/material.dart';
import 'screens/itinerary_screen.dart';
import 'models/itinerary.dart';
import 'services/json_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Trip Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<Itinerary>(
        future: JsonService().loadItinerary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return ItineraryScreen(itinerary: snapshot.data!);
          }
        },
      ),
    );
  }
}
