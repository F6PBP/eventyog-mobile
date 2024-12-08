// To parse this JSON data, do
//
//     final friendListModel = friendListModelFromJson(jsonString);

import 'dart:convert';

FriendListModel friendListModelFromJson(String str) =>
    FriendListModel.fromJson(json.decode(str));

String friendListModelToJson(FriendListModel data) =>
    json.encode(data.toJson());

class FriendListModel {
  bool status;
  String message;
  Data data;

  FriendListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FriendListModel.fromJson(Map<String, dynamic> json) =>
      FriendListModel(
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
  List<Friend> friends;
  List<Friend> friendsRecommendation;

  Data({
    required this.friends,
    required this.friendsRecommendation,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        friends:
            List<Friend>.from(json["friends"].map((x) => Friend.fromJson(x))),
        friendsRecommendation: List<Friend>.from(
            json["friends_recommendation"].map((x) => Friend.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "friends": List<dynamic>.from(friends.map((x) => x.toJson())),
        "friends_recommendation":
            List<dynamic>.from(friendsRecommendation.map((x) => x.toJson())),
      };
}

class Friend {
  int id;
  String profilePicture;
  String username;
  String email;
  List<dynamic> categories;

  Friend({
    required this.id,
    required this.profilePicture,
    required this.username,
    required this.email,
    required this.categories,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        id: json["id"],
        profilePicture: json["profile_picture"],
        username: json["username"],
        email: json["email"],
        categories: List<dynamic>.from(json["categories"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "profile_picture": profilePicture,
        "username": username,
        "email": email,
        "categories": List<dynamic>.from(categories.map((x) => x)),
      };
}
