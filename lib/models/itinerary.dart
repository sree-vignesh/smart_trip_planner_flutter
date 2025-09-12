import 'package:json_annotation/json_annotation.dart';

part 'itinerary.g.dart';

@JsonSerializable(explicitToJson: true) // <-- add explicitToJson
class Itinerary {
  final String title;
  final String startDate;
  final String endDate;
  final List<Day> days;

  Itinerary({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) =>
      _$ItineraryFromJson(json);
  Map<String, dynamic> toJson() => _$ItineraryToJson(this);
}

@JsonSerializable(explicitToJson: true) // <-- add explicitToJson
class Day {
  final String date;
  final String summary;
  final List<ActivityItem> items;

  Day({required this.date, required this.summary, required this.items});

  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);
  Map<String, dynamic> toJson() => _$DayToJson(this);
}

@JsonSerializable()
class ActivityItem {
  final String time;
  final String activity;
  final String location;

  ActivityItem({
    required this.time,
    required this.activity,
    required this.location,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityItemToJson(this);
}
