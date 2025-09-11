import 'dart:convert';
import 'package:http/http.dart' as http;

class ItineraryApiService {
  final String baseUrl;

  ItineraryApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchItinerary(
    String prompt, {
    Map<String, dynamic>? prevItinerary, // <-- add optional previous itinerary
  }) async {
    final uri = Uri.parse(baseUrl);

    final body = {
      'prompt': prompt,
      if (prevItinerary != null)
        'prevItinerary': prevItinerary, // include if available
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch itinerary: ${response.statusCode}');
    }
  }
}
