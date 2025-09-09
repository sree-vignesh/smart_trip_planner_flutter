import 'package:flutter/material.dart';
import 'package:smart_trip_planner/screens/home_page.dart';
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
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}
