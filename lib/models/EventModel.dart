// To parse this JSON data, do
//
//     final event = eventFromJson(jsonString);

import 'dart:convert';

List<Event> eventFromJson(String str) =>
    List<Event>.from(json.decode(str).map((x) => Event.fromJson(x)));

String eventToJson(List<Event> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Event {
  Model model;
  String pk;
  Fields fields;

  Event({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  String title;
  String description;
  String category;
  DateTime startTime;
  DateTime? endTime;
  String? location;
  DateTime createdAt;
  DateTime updatedAt;
  String? imageUrls;
  List<dynamic> userRating;

  Fields({
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrls,
    required this.userRating,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        description: json["description"],
        category: json["category"],
        startTime: DateTime.parse(json["start_time"]),
        endTime:
            json["end_time"] == null ? null : DateTime.parse(json["end_time"]),
        location: json["location"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        imageUrls: json["image_urls"],
        userRating: List<dynamic>.from(json["user_rating"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "category": category,
        "start_time": startTime.toIso8601String(),
        "end_time": endTime?.toIso8601String(),
        "location": location,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "image_urls": imageUrls,
        "user_rating": List<dynamic>.from(userRating.map((x) => x)),
      };
}

enum Model { MAIN_EVENT }

final modelValues = EnumValues({"main.event": Model.MAIN_EVENT});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
