// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  bool status;
  String message;
  Data data;

  ProfileModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  String username;
  String name;
  String email;
  DateTime dateJoined;
  String bio;
  String? imageUrl;
  String? categories;

  Data({
    required this.username,
    required this.name,
    required this.email,
    required this.dateJoined,
    required this.bio,
    this.imageUrl,
    this.categories,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        username: json["username"],
        name: json["name"],
        email: json["email"],
        dateJoined: DateTime.parse(json["date_joined"]),
        bio: json["bio"],
        imageUrl: json["image_url"],
        categories: json["categories"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "name": name,
        "email": email,
        "date_joined": dateJoined.toIso8601String(),
        "bio": bio,
        "image_url": imageUrl,
        "categories": categories,
      };
}
