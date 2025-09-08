// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Itinerary _$ItineraryFromJson(Map<String, dynamic> json) => Itinerary(
  title: json['title'] as String,
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String,
  days: (json['days'] as List<dynamic>)
      .map((e) => Day.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ItineraryToJson(Itinerary instance) => <String, dynamic>{
  'title': instance.title,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'days': instance.days,
};

Day _$DayFromJson(Map<String, dynamic> json) => Day(
  date: json['date'] as String,
  summary: json['summary'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DayToJson(Day instance) => <String, dynamic>{
  'date': instance.date,
  'summary': instance.summary,
  'items': instance.items,
};

ActivityItem _$ActivityItemFromJson(Map<String, dynamic> json) => ActivityItem(
  time: json['time'] as String,
  activity: json['activity'] as String,
  location: json['location'] as String,
);

Map<String, dynamic> _$ActivityItemToJson(ActivityItem instance) =>
    <String, dynamic>{
      'time': instance.time,
      'activity': instance.activity,
      'location': instance.location,
    };
