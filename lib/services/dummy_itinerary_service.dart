// lib/services/dummy_itinerary_service.dart
class DummyItineraryService {
  // Existing async method
  static Future<Map<String, dynamic>> getItinerary(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      "itinerary": {
        "title": "Dummy Trip for: $prompt",
        "startDate": "2025-09-10",
        "endDate": "2025-09-12",
        "days": [
          {
            "date": "2025-09-10",
            "summary": "Arrival and first day activities",
            "items": [
              {
                "time": "09:00",
                "activity": "Arrive at destination and check in",
                "location": "0.0000,0.0000",
              },
              {
                "time": "11:00",
                "activity": "Sightseeing in the city center",
                "location": "0.0001,0.0001",
              },
              {
                "time": "18:00",
                "activity": "Dinner at a local restaurant",
                "location": "0.0002,0.0002",
              },
            ],
          },
          {
            "date": "2025-09-11",
            "summary": "Second day activities",
            "items": [
              {
                "time": "08:00",
                "activity": "Breakfast at hotel",
                "location": "0.0000,0.0000",
              },
              {
                "time": "10:00",
                "activity": "Visit famous landmarks",
                "location": "0.0003,0.0003",
              },
              {
                "time": "15:00",
                "activity": "Relax at the park",
                "location": "0.0004,0.0004",
              },
              {
                "time": "19:00",
                "activity": "Evening cultural event",
                "location": "0.0005,0.0005",
              },
            ],
          },
          {
            "date": "2025-09-12",
            "summary": "Departure",
            "items": [
              {
                "time": "09:00",
                "activity": "Check out and depart",
                "location": "0.0000,0.0000",
              },
            ],
          },
        ],
      },
    };
  }

  // Synchronous version for chat display
  static Map<String, dynamic> generateMap(String prompt) {
    return {
      "itinerary": {
        "title": "Dummy Trip for: $prompt",
        "startDate": "2025-09-10",
        "endDate": "2025-09-12",
        "days": [
          {
            "date": "2025-09-10",
            "summary": "Arrival and first day activities",
            "items": [
              {
                "time": "09:00",
                "activity": "Arrive at destination and check in",
                "location": "0.0000,0.0000",
              },
              {
                "time": "11:00",
                "activity": "Sightseeing in the city center",
                "location": "0.0001,0.0001",
              },
              {
                "time": "18:00",
                "activity": "Dinner at a local restaurant",
                "location": "0.0002,0.0002",
              },
            ],
          },
          // ... repeat for other days if needed
        ],
      },
    };
  }

  static Map<String, String> followUpMap(String text) {
    return {"role": "ai", "text": "Dummy follow-up reply to: \"$text\""};
  }
}
