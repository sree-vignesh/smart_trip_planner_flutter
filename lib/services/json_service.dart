import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/itinerary.dart';

class JsonService {
  Future<Itinerary> loadItinerary() async {
    final data = await rootBundle.loadString('assets/itinerary.json');
    final jsonData = json.decode(data);
    return Itinerary.fromJson(jsonData['itinerary']);
  }
}
