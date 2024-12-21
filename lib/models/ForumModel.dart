import 'dart:convert';

class ForumPostModel {
  int id;
  String title;
  String content;
  String user;
  String createdAt;
  String profilePicture;
  int totalLike;
  int totalDislike;
  int commentCount;

  ForumPostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.createdAt,
    required this.profilePicture,
    required this.totalLike,
    required this.totalDislike,
    required this.commentCount,
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) => ForumPostModel(
        id: json["id"] ?? 0,
        title: json["title"] ?? "Untitled",
        content: json["content"] ?? "No content available",
        user: json["user"] ?? "Anonymous",
        createdAt: json["created_at"] ?? "",
        profilePicture: json["profile_picture"] ?? "",
        totalLike: json["totalLike"] ?? 0,
        totalDislike: json["totalDislike"] ?? 0,
        commentCount: json["comment_count"] ?? 0,
      );
}

class ForumDetailModel {
  ForumPostModel forumPost;
  List<ForumReplyModel> replies;
  bool showNavbar;
  bool showFooter;

  ForumDetailModel({
    required this.forumPost,
    required this.replies,
    required this.showNavbar,
    required this.showFooter,
  });

  factory ForumDetailModel.fromJson(Map<String, dynamic> json) =>
      ForumDetailModel(
        forumPost: ForumPostModel.fromJson(json["forum_post"] ?? {}),
        replies: json["replies"] != null
            ? List<ForumReplyModel>.from(
                json["replies"].map((x) => ForumReplyModel.fromJson(x)))
            : [],
        showNavbar: json["show_navbar"] ?? false,
        showFooter: json["show_footer"] ?? false,
      );
}

class ForumReplyModel {
  int id;
  String content;
  String user;
  String createdAt;
  String profilePicture;
  int totalLike;
  int totalDislike;

  ForumReplyModel({
    required this.id,
    required this.content,
    required this.user,
    required this.createdAt,
    required this.profilePicture,
    required this.totalLike,
    required this.totalDislike,
  });

  factory ForumReplyModel.fromJson(Map<String, dynamic> json) =>
      ForumReplyModel(
        id: json["id"] ?? 0,
        content: json["content"] ?? "No reply content available",
        user: json["user"] ?? "Anonymous",
        createdAt: json["created_at"] ?? "",
        profilePicture: json["profile_picture"] ?? "",
        totalLike: json["totalLike"] ?? 0,
        totalDislike: json["totalDislike"] ?? 0,
      );
}
