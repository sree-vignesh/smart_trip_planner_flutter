import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_trip_planner/core/colors.dart';
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
    final String jsonStr = await rootBundle.loadString(
      'assets/itineraries.json',
    );
    final List<dynamic> assetData = jsonDecode(jsonStr);

    final prefs = await SharedPreferences.getInstance();
    final List<String> offlineList =
        prefs.getStringList("saved_itineraries") ?? [];

    final List<Map<String, dynamic>> offlineData = offlineList.map((str) {
      final Map<String, dynamic> map = jsonDecode(str);
      return map.cast<String, dynamic>();
    }).toList();

    setState(() {
      savedItineraries = [
        ...offlineData,
        ...assetData.map((e) => e.cast<String, dynamic>()),
      ];
    });
  }

  void _onGeneratePressed() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(prompt: prompt)),
    );

    _loadItineraries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        // centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(17.5),
          child: const Text("Hey"),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's your vision for this trip?",
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Prompt input box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary),
                  // border
                ),
                // width: 200,
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
              const SizedBox(height: 20),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onGeneratePressed,
                  child: const Text("Generate Itinerary"),
                ),
              ),
              const SizedBox(height: 36),
              Center(
                child: const Text(
                  "Offline Saved Itineraries",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              // List of itineraries
              Expanded(
                child: savedItineraries.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        reverse: true,
                        itemCount: savedItineraries.length,
                        itemBuilder: (context, index) {
                          final itineraryMap =
                              savedItineraries[index]['itinerary'];
                          if (itineraryMap == null) return const SizedBox();

                          return Card(
                            color: AppColors.cardBackground,
                            margin: EdgeInsets.all(10),

                            child: ListTile(
                              title: Text(
                                itineraryMap['title'] ?? 'No title',
                                maxLines: 1, // restricts to 1 line
                                overflow: TextOverflow
                                    .ellipsis, // adds "..." if too long
                              ),
                              minTileHeight: 5,
                              // tileColor: AppColors.cardBackground,
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
    );
  }
}
