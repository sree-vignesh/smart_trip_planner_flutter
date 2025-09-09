import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/itinerary.dart';

class JsonService {
  Future<List<Itinerary>> loadItineraries() async {
    final data = await rootBundle.loadString('assets/itineraries.json');
    final List<dynamic> jsonList = jsonDecode(data);

    return jsonList.map((e) {
      final itineraryJson = e['itinerary']; // 👈 pick nested object
      return Itinerary.fromJson(itineraryJson);
    }).toList();
  }
}
