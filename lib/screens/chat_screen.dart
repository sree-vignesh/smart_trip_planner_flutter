import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_trip_planner/models/itinerary.dart';
import '../services/dummy_itinerary_service.dart';

class ChatScreen extends StatefulWidget {
  final String prompt;

  const ChatScreen({super.key, required this.prompt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool savedOffline = false;

  // Store the dummy itinerary data for offline save
  Map<String, dynamic>? _latestItineraryData;

  @override
  void initState() {
    super.initState();
    _addDummyAIResponse(widget.prompt);
  }

  /// Add a dummy AI response for the prompt
  void _addDummyAIResponse(String prompt) async {
    setState(() {
      messages.add({"role": "user", "text": prompt});
    });

    // Get dummy itinerary from service
    final dummyData = DummyItineraryService.generateMap(prompt);
    _latestItineraryData = dummyData;

    // Convert itinerary into readable chat text
    final itinerary = Itinerary.fromJson(dummyData['itinerary']);
    final itineraryText = StringBuffer();
    for (var day in itinerary.days) {
      itineraryText.writeln("${day.date} - ${day.summary}");
      for (var item in day.items) {
        itineraryText.writeln("${item.time} - ${item.activity}");
      }
      itineraryText.writeln(""); // blank line between days
    }

    setState(() {
      messages.add({"role": "ai", "text": itineraryText.toString()});
    });
  }

  /// Handle follow-up messages
  void _sendFollowUp() {
    final text = _controller.text.trim();
    if (text.isEmpty || savedOffline) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      messages.add(DummyItineraryService.followUpMap(text));
    });
    _controller.clear();
  }

  /// Save the itinerary offline to SharedPreferences
  Future<void> _saveOffline() async {
    final prefs = await SharedPreferences.getInstance();

    // Create itinerary in the full JSON schema
    final itinerary = {
      "itinerary": {
        "title": widget.prompt,
        "startDate": DateTime.now().toIso8601String(),
        "endDate": DateTime.now()
            .add(const Duration(days: 2))
            .toIso8601String(),
        "days": [
          {
            "date": DateTime.now().toIso8601String().split("T").first,
            "summary": "Dummy day based on your prompt",
            "items": messages
                .map(
                  (m) => {
                    "time": "09:00",
                    "activity": m['text'] ?? '',
                    "location": "0.0000,0.0000",
                  },
                )
                .toList(),
          },
        ],
      },
    };

    List<String> saved = prefs.getStringList("saved_itineraries") ?? [];
    saved.add(jsonEncode(itinerary));
    await prefs.setStringList("saved_itineraries", saved);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Itinerary saved offline!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Chat")),
      body: SafeArea(
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        msg['text'] ?? "",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Follow-up input
            if (!savedOffline)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type follow-up",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _sendFollowUp,
                      child: const Text("Send"),
                    ),
                  ],
                ),
              ),

            // Save offline button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: savedOffline ? null : _saveOffline,
                child: Text(
                  savedOffline ? "Saved (Read-only)" : "Save Offline",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
