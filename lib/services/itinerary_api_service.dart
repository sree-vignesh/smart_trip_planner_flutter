import 'dart:convert';
import 'package:http/http.dart' as http;

class ItineraryApiService {
  final String baseUrl;

  ItineraryApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchItinerary(String prompt) async {
    final uri = Uri.parse(baseUrl);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch itinerary: ${response.statusCode}');
    }
  }
}
