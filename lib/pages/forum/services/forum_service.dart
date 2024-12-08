import 'dart:convert';
import 'package:eventyog_mobile/models/ForumModel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<ForumDetailModel> fetchForumDetail(int postId) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/post/$postId/";

  try {
    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ForumDetailModel.fromJson(data["data"]);
    } else {
      throw Exception('Failed to load post details. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching post details: $e');
  }
}

// Add new post
Future<bool> addForumPost(String title, String content) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/add-post/";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "content": content}),
    );

    return response.statusCode == 200; // Returns true if post is successfully added
  } catch (e) {
    throw Exception('Error adding post: $e');
  }
}

// Edit existing post
Future<bool> editForumPost(int postId, String title, String content) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/edit/$postId/";

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "content": content}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to edit post: ${errorData['message']}');
    }
  } catch (e) {
    throw Exception('Error editing post: $e');
  }
}

// Delete post
Future<bool> deleteForumPost(int postId) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/post/$postId/delete/";

  try {
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to delete post: ${errorData['message']}');
    }
  } catch (e) {
    throw Exception('Error deleting post: $e');
  }
}

// Add reply to a post
Future<bool> addReply(int postId, String content) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/post/$postId/add_reply/";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"content": content}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to add reply: ${errorData['message']}');
    }
  } catch (e) {
    throw Exception('Error adding reply: $e');
  }
}

// Like post
Future<bool> likePost(int postId) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/like_post/$postId/";

  try {
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    throw Exception('Error liking post: $e');
  }
}

// Dislike post
Future<bool> dislikePost(int postId) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/dislike_post/$postId/";

  try {
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    throw Exception('Error disliking post: $e');
  }
}

// Like reply
Future<bool> likeReply(int replyId) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/like_reply/$replyId/";

  try {
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    throw Exception('Error liking reply: $e');
  }
}

// Dislike reply
Future<bool> dislikeReply(int replyId) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = "$hostname:8000/api/yogforum/dislike_reply/$replyId/";

  try {
    final response = await http.post(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    throw Exception('Error disliking reply: $e');
  }
}

// Fetch all forum posts
Future<List<Map<String, dynamic>>> fetchForumPosts(String query) async {
  final hostname = dotenv.env['HOSTNAME'] ?? 'http://localhost';
  final url = query.isEmpty
      ? "$hostname:8000/api/yogforum/get_forum_by_ajax/"
      : "$hostname:8000/api/yogforum/get_forum_by_ajax/?search=$query";

  try {
    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['forum_posts']);
    } else {
      throw Exception('Failed to load forum posts. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching forum posts: $e');
  }
}
