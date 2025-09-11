import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_trip_planner/core/colors.dart';
import 'dart:convert';
import 'package:smart_trip_planner/models/itinerary.dart';
import 'package:smart_trip_planner/screens/user_screen.dart';
import 'package:smart_trip_planner/services/search_service.dart';
import '../services/itinerary_api_service.dart';

class ChatScreen extends StatefulWidget {
  final String prompt;

  const ChatScreen({super.key, required this.prompt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class DotsIndicator extends StatefulWidget {
  const DotsIndicator({super.key});

  @override
  State<DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<DotsIndicator> {
  int dotCount = 1;

  @override
  void initState() {
    super.initState();
    // Animate every 400ms
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return false;
      setState(() => dotCount = (dotCount + 1) % 4);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        dotCount,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.5),
          child: Text(".", style: TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final SearchService _searchService = SearchService();

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool savedOffline = false;
  bool isLoading = false; // Track API request state
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _latestItineraryData;
  final ItineraryApiService apiService = ItineraryApiService(
    baseUrl: 'https://smart-trip-planner-server.vercel.app/itinerary',
    // baseUrl: 'http://192.168.31.162:8080/itinerary',
  );
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchAIResponse(widget.prompt);
  }

  /// Fetch itinerary from real API
  void _fetchAIResponse(String prompt) async {
    setState(() {
      messages.add({"role": "user", "text": prompt});
      messages.add({"role": "status", "text": "Thinking"});
      isLoading = true;
    });

    try {
      _searchService.logUserSearch(prompt);
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        messages.removeWhere((m) => m['role'] == 'status');
        messages.add({
          "role": "ai",
          "text": "Oops! The LLM failed to generate answer. Please regenerate.",
          "type": "error",
        });
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Handle follow-up messages
  void _sendFollowUp() async {
    final text = _controller.text.trim();
    if (text.isEmpty || savedOffline || isLoading) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      messages.add({"role": "status", "text": "Rethinking"});
      isLoading = true;
    });

    _controller.clear();

    try {
      _searchService.logUserSearch(_latestItineraryData.toString());

      final data = await apiService.fetchItinerary(
        text,
        prevItinerary: _latestItineraryData,
      );
      if (!mounted) return; // ensure widget is still alive

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return; // ensure widget is still alive
      setState(() {
        messages.removeWhere((m) => m['role'] == 'status');
        messages.add({
          "role": "ai",
          "text": "Oops! The LLM failed to generate answer. Please regenerate.",
          "type": "error",
        });
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _buildFormattedItinerary(String text) {
    final lines = text
        .split("\n")
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.contains(" - ") &&
            RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(line)) {
          // Day header (date + summary)
          return Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
            child: Text(
              line,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        } else if (RegExp(r'^\d{2}:\d{2}').hasMatch(line)) {
          // Time + activity
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("•  "),
                Expanded(
                  child: Text(
                    line,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Fallback plain text
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              line,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }
      }).toList(),
    );
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
    final user = FirebaseAuth.instance.currentUser;
    final userPhoto = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        // toolbarHeight
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(userPhoto!),

                // optional: backgroundImage: NetworkImage(user.photoURL ?? ''),
              ),
            ),
          ),
        ],
        toolbarHeight: 100,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final role = msg['role'];
                  final isUser = role == 'user';
                  final isStatus = role == 'status';
                  final isError = role == 'type';
                  print(
                    'msg type: ${msg['type']}',
                  ); // see what value it actually has

                  return Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 300, // minimum width of the message box
                        maxWidth: 300, // maximum width of the message box
                        minHeight: 100,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar + name row
                            Row(
                              children: [
                                // Circle avatar
                                const SizedBox(height: 50),
                                msg['role'] == 'user'
                                    ? CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(
                                          userPhoto!,
                                        ),

                                        // optional: backgroundImage: NetworkImage(user.photoURL ?? ''),
                                      )
                                    : Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.secondary,
                                        ),
                                        child: Icon(
                                          Icons.message_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),

                                const SizedBox(width: 16),
                                // Name
                                Text(
                                  msg['role'] == 'user'
                                      ? '${user?.displayName}'
                                      : 'Itinera AI',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Message text
                            if (isStatus)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      year2023: false,
                                      color: Colors.cyanAccent,
                                      backgroundColor: Colors.greenAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    msg['text'] ?? "",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      // fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const DotsIndicator(),
                                ],
                              )
                            else if (role == "ai")
                              _buildFormattedItinerary(msg['text'] ?? "")
                            else
                              Text(
                                msg['text'] ?? "",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,

                                  color:
                                      (msg['type']?.toString() ?? '') == 'error'
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
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
                          contentPadding: EdgeInsets.only(left: 30),
                          filled: true,
                          fillColor: isLoading
                              ? Colors.grey.shade100
                              : Colors.white,
                          hintText: isLoading
                              ? "Awaiting response..."
                              : "Type follow-up",
                          hintStyle: TextStyle(
                            // fontFamily: 'mono',
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120),
                            borderSide: const BorderSide(
                              width: 2,
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120),
                            borderSide: const BorderSide(
                              width: 2,
                              color: AppColors
                                  .primary, // different color when focused
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      child: InkWell(
                        onTap: isLoading ? null : _sendFollowUp,
                        borderRadius: BorderRadius.circular(120),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(120),
                          ),
                          padding: EdgeInsets.zero,
                          child: Icon(
                            Icons.telegram_outlined,
                            size: 56,
                            color: !isLoading ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Save offline button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: savedOffline ? null : _saveOffline,
                child: Text(
                  savedOffline ? "Saved (Read-only)" : "Save Offline",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: savedOffline ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
