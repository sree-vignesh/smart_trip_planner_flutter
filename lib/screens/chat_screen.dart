import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_trip_planner/core/colors.dart';
import 'dart:convert';
import 'package:smart_trip_planner/models/itinerary.dart';
import 'package:smart_trip_planner/screens/user_screen.dart';
import 'package:smart_trip_planner/services/search_service.dart';
import 'package:url_launcher/url_launcher.dart';
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
  // final List<Map<String, String>> messages = [];
  List<Map<String, dynamic>> messages = [];

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

  Future<void> _openMap(
    BuildContext context,
    String location,
    String activity,
  ) async {
    if (location.isEmpty) location = "0,0";
    final latLng = location.split(',');
    final lat = latLng[0];
    final lng = latLng[1];
    // print(activity);

    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($activity)');
    final browserUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      // Try launching geo URI directly
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // fallback to browser
      await launchUrl(browserUri, mode: LaunchMode.externalApplication);
    }
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
        messages.add({
          "role": "ai",
          "text": itinerary.toJson(),
          "itinerary": itinerary.toJson(),
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
  void _sendFollowUp({bool isRegenerate = false}) async {
    final text = _controller.text.trim();

    // If it's a normal send, require text
    if (!isRegenerate && (text.isEmpty || savedOffline || isLoading)) return;

    // If regenerate, use last user message instead of controller
    final prompt = isRegenerate
        ? messages.lastWhere((m) => m['role'] == 'user')['text'] as String
        : text;

    setState(() {
      if (!isRegenerate) {
        messages.add({"role": "user", "text": text});
      }
      messages.add({"role": "status", "text": "Rethinking"});
      messages.removeWhere((m) => m['type'] == 'error');

      isLoading = true;
    });

    if (!isRegenerate) _controller.clear();

    try {
      _searchService.logUserSearch(_latestItineraryData.toString());

      final data = await apiService.fetchItinerary(
        prompt,
        prevItinerary: _latestItineraryData,
      );
      if (!mounted) return;

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
        messages.removeWhere((m) => m['type'] == 'error');

        messages.add({
          "role": "ai",
          "text": itinerary.toJson(),
          "itinerary": itinerary.toJson(),
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
    } catch (e) {
      if (!mounted) return;
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

  bool isSaved = false;
  Widget _buildItineraryFromJson(Map<String, dynamic> itineraryJson) {
    final itinerary = Itinerary.fromJson(itineraryJson);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // All days
        ...itinerary.days.map((day) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day header
                Text(
                  "${day.date} \n",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  "${day.summary}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Activities
                ...day.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• "),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${item.time}  ",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                TextSpan(
                                  text: item.activity,
                                  style: GoogleFonts.inter(
                                    height: 1.4,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // const SizedBox(height: 12),
              ],
            ),
          );
        }).toList(),

        // --- Single Map & Actions Card at the end ---
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 0,
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      final firstLoc = itinerary.days
                          .expand((d) => d.items)
                          .firstWhere((i) => i.location.isNotEmpty)
                          .location;
                      print(firstLoc);
                      // final url =
                      //     "https://www.google.com/maps/search/?api=1&query=$firstLoc";
                      // launchUrl(Uri.parse(url));
                      // print(itinerary.title);
                      _openMap(context, firstLoc, itinerary.title);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "📍  Open in Maps",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3D90F5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${itinerary.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ], // Buttons row
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Divider(),

        SizedBox(
          width: double.infinity,
          height: 33,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Open in Maps (first activity with location)

              // Copy all itinerary text
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ), // ✅ reduce padding
                  minimumSize: const Size(0, 33), // ✅ compact height
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: FaIcon(
                  FontAwesomeIcons.solidCopy,
                  size: 12,
                  color: Colors.grey,
                ),
                onPressed: () {
                  final message = itinerary.days
                      .expand((d) => d.items)
                      .map((i) => "${i.time} - ${i.activity}")
                      .join("\n");
                  Clipboard.setData(ClipboardData(text: message));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied to clipboard")),
                  );
                },
                label: Text(
                  "Copy",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(width: 25),
              // Save offline
              SizedBox(
                // fit: BoxFit.scaleDown,
                width: 80,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ), // ✅ reduce padding
                    minimumSize: const Size(0, 33), // ✅ compact height
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: isSaved
                      ? FaIcon(FontAwesomeIcons.check)
                      : FaIcon(
                          FontAwesomeIcons.download,
                          size: 12,
                          color: isSaved ? Colors.black : Colors.grey,
                        ),
                  onPressed: () async {
                    print("Before save: $isSaved");

                    final result = await _saveOffline(itineraryJson);
                    print("Save result: $result");

                    if (!mounted) return; // safety: widget may be disposed
                    setState(() {
                      isSaved = result;
                    });

                    print("After save: $isSaved");
                  },
                  label: Text(
                    isSaved ? "Saved" : "Save",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      // color: Colors.grey,
                      color: isSaved ? Colors.black : Colors.grey,

                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // TextButton.icon(
              //   style: TextButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 6,
              //     ), // ✅ reduce padding
              //     minimumSize: const Size(0, 33), // ✅ compact height
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   ),
              //   icon: FaIcon(
              //     FontAwesomeIcons.arrowRotateLeft,
              //     size: 12,
              //     color: Colors.grey,
              //   ),
              //   onPressed: () {
              //     _sendFollowUp(isRegenerate: true);
              //     // Call _sendFollowUp or regenerate API
              //   },
              //   label: Text(
              //     "Regenerate",
              //     style: GoogleFonts.inter(
              //       fontWeight: FontWeight.bold,
              //       color: Colors.grey,
              //       fontSize: 12,
              //       height: 1,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _saveOffline(Map<String, dynamic> itineraryJsonToSave) async {
    // if (itineraryJsonToSave == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> saved = prefs.getStringList("saved_itineraries") ?? [];
      saved.add(jsonEncode(itineraryJsonToSave));
      await prefs.setStringList("saved_itineraries", saved);

      setState(() {
        // savedOffline = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Itinerary saved offline!")));
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Try Again!")));
      return false;
    }
  }

  /// Save the latest itinerary offline
  // Future<void> _saveOffline() async {
  //   if (_latestItineraryData == null) return;

  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> saved = prefs.getStringList("saved_itineraries") ?? [];
  //   saved.add(jsonEncode(_latestItineraryData));
  //   await prefs.setStringList("saved_itineraries", saved);

  //   setState(() {
  //     savedOffline = true;
  //   });

  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text("Itinerary saved offline!")));
  // }

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
                radius: 20,
                // backgroundImage: NetworkImage(userPhoto!),
                backgroundImage: userPhoto != null
                    ? NetworkImage(userPhoto!)
                    : null,
                child: userPhoto == null
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,

                // optional: backgroundImage: NetworkImage(user.photoURL ?? ''),
              ),
            ),
          ),
        ],
        toolbarHeight: 75,
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
                              Column(
                                children: [
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
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              )
                            // else if (role == "ai")
                            //   _buildFormattedItinerary(msg['text'] ?? "")
                            else if (role == "ai" && msg['itinerary'] != null)
                              _buildItineraryFromJson(msg['itinerary'])
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // msg['text'] ?? "",
                                    msg['text']?.toString() ?? "",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,

                                      color:
                                          (msg['type']?.toString() ?? '') ==
                                              'error'
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(),

                                  // Copy all itinerary text
                                  SizedBox(
                                    height: 33,
                                    child: TextButton.icon(
                                      icon: FaIcon(
                                        (msg['type'] == 'error')
                                            ? FontAwesomeIcons.arrowRotateLeft
                                            : FontAwesomeIcons.solidCopy,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        if (msg['type'] == 'error') {
                                          // _fetchAIResponse(
                                          _sendFollowUp(isRegenerate: true);
                                        } else {
                                          final message =
                                              msg['text']?.toString() ?? "";
                                          Clipboard.setData(
                                            ClipboardData(text: message),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Copied to clipboard",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      label: Text(
                                        (msg['type'] == 'error')
                                            ? "Regenarate"
                                            : "Copy",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.1,
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            // const SizedBox(height: 24),
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
            const SizedBox(height: 15),
            // // Save offline button
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: TextButton(
            //     onPressed: savedOffline ? null : _saveOffline,
            //     child: Text(
            //       savedOffline ? "Saved (Read-only)" : "Save Offline",
            //       style: GoogleFonts.inter(
            //         fontSize: 18,
            //         color: savedOffline ? Colors.grey : Colors.black,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
