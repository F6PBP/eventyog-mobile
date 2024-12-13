import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForumDetailPage extends StatefulWidget {
  final int postId;

  const ForumDetailPage({required this.postId, Key? key}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  Map<String, dynamic>? forumPost;
  List<Map<String, dynamic>> replies = [];
  bool isLoading = true;
  bool isRepliesLoading = false;

  final String baseUrl = 'http://YOUR_IP_ADDRESS:8000'; // For physical devices

  @override
  void initState() {
    super.initState();
    print("Fetching details for post ID: ${widget.postId}");
    fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/yogforum/post/${widget.postId}/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          forumPost = data;
          isLoading = false;
        });
        // Assuming replies are part of the post detail
        if (data['replies'] != null) {
          setState(() {
            replies = List<Map<String, dynamic>>.from(data['replies']);
          });
        } else {
          // If replies need to be fetched separately
          await fetchReplies();
        }
      } else {
        throw Exception('Failed to fetch forum details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching post details: $e')),
      );
    }
  }

  Future<void> fetchReplies() async {
    setState(() {
      isRepliesLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/yogforum/post/${widget.postId}/replies/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          replies = List<Map<String, dynamic>>.from(data);
          isRepliesLoading = false;
        });
      } else {
        throw Exception('Failed to fetch replies');
      }
    } catch (e) {
      setState(() {
        isRepliesLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching replies: $e')),
      );
    }
  }

  Future<void> likePost() async {
    if (forumPost == null) return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/yogforum/like_post/${forumPost!['id']}/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          setState(() {
            forumPost!['total_likes'] = data['data']['total_likes'];
          });
        }
      } else {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking post: $e')),
      );
    }
  }

  Future<void> dislikePost() async {
    if (forumPost == null) return;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/yogforum/dislike_post/${forumPost!['id']}/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          setState(() {
            forumPost!['total_dislikes'] = data['data']['total_dislikes'];
          });
        }
      } else {
        throw Exception('Failed to dislike post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error disliking post: $e')),
      );
    }
  }

  Future<void> deletePost() async {
    if (forumPost == null) return;
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/yogforum/delete_post/${forumPost!['id']}/'),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return to previous page with success
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        actions: [
          if (forumPost != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit page
                Navigator.pushNamed(context, '/edit_post', arguments: forumPost!['id']);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletePost,
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : forumPost == null
              ? const Center(child: Text('Post not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post details
                      Text(
                        forumPost!['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(forumPost!['content']),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up_alt_outlined),
                            onPressed: likePost,
                          ),
                          Text('${forumPost!['total_likes']}'),
                          IconButton(
                            icon: const Icon(Icons.thumb_down_alt_outlined),
                            onPressed: dislikePost,
                          ),
                          Text('${forumPost!['total_dislikes']}'),
                        ],
                      ),
                      const Divider(),
                      // Replies
                      const Text(
                        'Replies',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      isRepliesLoading
                          ? const Center(child: CircularProgressIndicator())
                          : replies.isEmpty
                              ? const Text('No replies yet.')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: replies.length,
                                  itemBuilder: (context, index) {
                                    final reply = replies[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: ListTile(
                                        title: Text(reply['content']),
                                        // Optionally add more details like author, timestamp
                                      ),
                                    );
                                  },
                                ),
                    ],
                  ),
                ),
    );
  }
}