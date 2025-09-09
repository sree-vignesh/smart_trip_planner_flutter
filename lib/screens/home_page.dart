import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, SystemUiOverlayStyle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_trip_planner/models/itinerary.dart';
import 'package:smart_trip_planner/screens/itinerary_screen.dart';
import 'package:smart_trip_planner/screens/chat_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> savedItineraries = [];

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

  // Load both JSON asset and SharedPreferences saved itineraries
  Future<void> _loadItineraries() async {
    // Load JSON asset itineraries
    final String jsonStr = await rootBundle.loadString(
      'assets/itineraries.json',
    );
    final List<dynamic> assetData = jsonDecode(jsonStr);

    // Load offline saved itineraries
    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineList =
        prefs.getStringList("saved_itineraries") ?? [];

    // Decode each offline string
    final List<Map<String, dynamic>> offlineData = offlineList.map((str) {
      final Map<String, dynamic> map = jsonDecode(str);
      // Each offline entry already has "itinerary" key
      return map.cast<String, dynamic>();
    }).toList();

    setState(() {
      savedItineraries = [
        ...offlineData,
        ...assetData.map((e) => e.cast<String, dynamic>()),
      ];
    });
  }

  // Navigate to ChatScreen and refresh on return
  void _onGeneratePressed() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(prompt: prompt)),
    );

    // Refresh saved itineraries automatically after returning
    _loadItineraries();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: const Text("Smart Trip Planner"),
          backgroundColor: const Color.fromARGB(255, 154, 185, 168),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prompt input box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    controller: _controller,
                    minLines: 4,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Enter your trip prompt",
                      border: InputBorder.none,
                    ),
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

                // List of itineraries
                Expanded(
                  child: savedItineraries.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: savedItineraries.length,
                          itemBuilder: (context, index) {
                            final itineraryMap =
                                savedItineraries[index]['itinerary'];
                            if (itineraryMap == null) return const SizedBox();

                            return Card(
                              child: ListTile(
                                title: Text(
                                  itineraryMap['title'] ?? 'No title',
                                ),
                                onTap: () {
                                  final itineraryObj = Itinerary.fromJson(
                                    itineraryMap,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItineraryScreen(
                                        itinerary: itineraryObj,
                                      ),
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
        ),
      ),
    );
  }
}
