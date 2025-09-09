import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smart_trip_planner/models/itinerary.dart';
import 'package:smart_trip_planner/screens/itinerary_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> savedItineraries = [];

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  Future<void> _loadItineraries() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/itineraries.json',
    );
    final List<dynamic> data = jsonDecode(jsonStr);
    setState(() {
      savedItineraries = data;
    });
  }

  void _onGeneratePressed() {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Prompt submitted: $prompt')));

    // Later: send prompt to backend/AI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Trip Planner")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prompt input
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter your trip prompt",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onGeneratePressed,
                child: const Text("Generate Itinerary"),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Saved Itineraries",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // List of saved itineraries
            Expanded(
              child: savedItineraries.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: savedItineraries.length,
                      itemBuilder: (context, index) {
                        final itinerary = savedItineraries[index]['itinerary'];
                        return Card(
                          child: ListTile(
                            title: Text(itinerary['title']),
                            // subtitle: Text(                              "${itinerary['startDate']} → ${itinerary['endDate']}",
                            // ),
                            onTap: () {
                              final itineraryObj = Itinerary.fromJson(
                                itinerary,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItineraryScreen(itinerary: itineraryObj),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
