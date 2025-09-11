import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_trip_planner/core/colors.dart';
import 'package:smart_trip_planner/models/itinerary.dart';
import 'package:smart_trip_planner/screens/itinerary_screen.dart';
import 'package:smart_trip_planner/screens/chat_screen.dart';
import 'package:smart_trip_planner/screens/user_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> savedItineraries = [];
  Set<int> selectedIndices = {}; // Track selected items
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadItineraries();
  }

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
        // ...assetData.map((e) => e.cast<String, dynamic>()),
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

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }

  void _deleteSelected() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedItineraries.removeWhere(
        (item) => selectedIndices.contains(savedItineraries.indexOf(item)),
      );
      selectedIndices.clear();
    });
    final offlineList = savedItineraries.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList("saved_itineraries", offlineList);
  }

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = selectedIndices.isNotEmpty;
    final user = FirebaseAuth.instance.currentUser;
    // final userPhoto = user?.photoURL ?? null;

    return Scaffold(
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          isSelectionMode
              ? "${selectedIndices.length} selected"
              : "Hey ${user?.displayName} !",
        ),
        actions: [
          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: _deleteSelected,
              ),
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300], // fallback background
                  //   backgroundImage: userPhoto != null
                  //       ? NetworkImage(userPhoto!)
                  //       : null,
                  //   child: userPhoto == null
                  //       ? const Icon(Icons.person, color: Colors.black)
                  //       : null,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prompt input section
                // const SizedBox(height: 30),
                Text(
                  "What's your vision for this trip?",
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onGeneratePressed,
                    child: const Text("Generate Itinerary"),
                  ),
                ),
                const SizedBox(height: 36),
                const Center(
                  child: Text(
                    "Offline Saved Itineraries",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),

                // List of itineraries
                savedItineraries.isEmpty
                    ? const Center(child: Text("Nothing yet."))
                    : ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: savedItineraries.length,
                        itemBuilder: (context, index) {
                          final itineraryMap =
                              savedItineraries[index]['itinerary'];
                          if (itineraryMap == null) return const SizedBox();

                          final isSelected = selectedIndices.contains(index);

                          return GestureDetector(
                            onLongPress: () => _toggleSelection(index),
                            onTap: () {
                              if (isSelectionMode) {
                                _toggleSelection(index);
                              } else {
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
                              }
                            },
                            child: Card(
                              color: isSelected
                                  ? AppColors.error
                                  : AppColors.cardBackground,
                              margin: const EdgeInsets.all(5),
                              child: ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: const Color.fromARGB(
                                    171,
                                    108,
                                    231,
                                    196,
                                  ),
                                  child: const CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Color(0xFF35AF8D),
                                  ),
                                ),
                                title: Text(
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),

                                  itineraryMap['title'] ?? 'No title',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
