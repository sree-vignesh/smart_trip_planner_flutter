import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_trip_planner/models/itinerary.dart';
import '../services/itinerary_api_service.dart';

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
  bool isLoading = false; // Track API request state

  Map<String, dynamic>? _latestItineraryData;
  final ItineraryApiService apiService = ItineraryApiService(
    baseUrl: 'http://192.168.31.162:8080/itinerary',
  );

  @override
  void initState() {
    super.initState();
    _fetchAIResponse(widget.prompt);
  }

  /// Fetch itinerary from real API
  void _fetchAIResponse(String prompt) async {
    setState(() {
      messages.add({"role": "user", "text": prompt});
      messages.add({"role": "status", "text": "Sending..."});
      isLoading = true;
    });

    try {
      final data = await apiService.fetchItinerary(prompt);
      _latestItineraryData = data;

      final itinerary = Itinerary.fromJson(data['itinerary']);
      final itineraryText = StringBuffer();

      for (var day in itinerary.days) {
        itineraryText.writeln("${day.date} - ${day.summary}");
        for (var item in day.items) {
          itineraryText.writeln("${item.time} - ${item.activity}");
        }
        itineraryText.writeln("");
      }

      setState(() {
        // Remove status message and add AI response
        messages.removeWhere((m) => m['role'] == 'status');
        messages.add({"role": "ai", "text": itineraryText.toString()});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.removeWhere((m) => m['role'] == 'status');
        messages.add({"role": "ai", "text": "Server unreachable or error: $e"});
        isLoading = false;
      });
    }
  }

  /// Handle follow-up messages
  void _sendFollowUp() async {
    final text = _controller.text.trim();
    if (text.isEmpty || savedOffline || isLoading) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      messages.add({"role": "status", "text": "Sending..."});
      isLoading = true;
    });

    _controller.clear();

    try {
      final data = await apiService.fetchItinerary(text);
      _latestItineraryData = data;

      final itinerary = Itinerary.fromJson(data['itinerary']);
      final itineraryText = StringBuffer();

      for (var day in itinerary.days) {
        itineraryText.writeln("${day.date} - ${day.summary}");
        for (var item in day.items) {
          itineraryText.writeln("${item.time} - ${item.activity}");
        }
        itineraryText.writeln("");
      }

      setState(() {
        messages.removeWhere((m) => m['role'] == 'status');
        messages.add({"role": "ai", "text": itineraryText.toString()});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.removeWhere((m) => m['role'] == 'status');
        messages.add({"role": "ai", "text": "Server unreachable or error: $e"});
        isLoading = false;
      });
    }
  }

  /// Save the latest itinerary offline
  Future<void> _saveOffline() async {
    if (_latestItineraryData == null) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList("saved_itineraries") ?? [];
    saved.add(jsonEncode(_latestItineraryData));
    await prefs.setStringList("saved_itineraries", saved);

    setState(() {
      savedOffline = true;
    });

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
                  final role = msg['role'];
                  final isUser = role == 'user';
                  final isStatus = role == 'status';

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.blue[200]
                            : isStatus
                            ? Colors.orange[200]
                            : Colors.grey[300],
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
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: isLoading
                              ? "Awaiting response..."
                              : "Type follow-up",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading ? null : _sendFollowUp,
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
