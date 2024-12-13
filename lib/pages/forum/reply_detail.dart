import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'reply_detail.dart'; // Pastikan file ini mengimpor ReplyDetailPage jika diperlukan

class ReplyDetailPage extends StatefulWidget {
  final int replyId;

  const ReplyDetailPage({required this.replyId, Key? key}) : super(key: key);

  @override
  State<ReplyDetailPage> createState() => _ReplyDetailPageState();
}

class _ReplyDetailPageState extends State<ReplyDetailPage> {
  Map<String, dynamic>? replyData;
  bool isLoading = true;
  String? username;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      username = request.jsonData['username'];
      fetchReplyDetail();
    });
  }

  Future<void> fetchReplyDetail() async {
    if (username == null || username!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username not found. Make sure you are logged in.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/yogforum/reply/${widget.replyId}/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          setState(() {
            replyData = data['reply'];
            isLoading = false;
          });
        } else {
          throw Exception('Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load reply details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reply: $e')),
      );
    }
  }

  Future<void> likeReply(int replyId) async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/yogforum/like_reply/$replyId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          fetchReplyDetail();
        } else {
          throw Exception('Failed to like reply: ${data['message']}');
        }
      } else {
        throw Exception('Failed to like reply');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking reply: $e')),
      );
    }
  }

  Future<void> dislikeReply(int replyId) async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/yogforum/dislike_reply/$replyId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          fetchReplyDetail();
        } else {
          throw Exception('Failed to dislike reply: ${data['message']}');
        }
      } else {
        throw Exception('Failed to dislike reply');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error disliking reply: $e')),
      );
    }
  }

  Future<void> postReply(String content, int? replyTo) async {
    if (username == null || username!.isEmpty) return;
    try {
      final body = <String, dynamic>{
        'content': content,
        'username': username,
      };
      if (replyTo != null) {
        body['reply_to'] = replyTo;
      }

      // Karena ini ReplyDetailPage, kita punya info forum_id di replyData['forum_id']
      final forumId = replyData!['forum_id'];

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/yogforum/post/$forumId/add_reply/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 && jsonDecode(response.body)['success']) {
        fetchReplyDetail();
      } else {
        throw Exception('Failed to post reply');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting reply: $e')),
      );
    }
  }

  Future<void> deleteReply(int replyId) async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/yogforum/reply/$replyId/delete/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reply deleted successfully!')),
          );
          fetchReplyDetail();
        } else {
          throw Exception('Failed to delete reply: ${data['message']}');
        }
      } else {
        throw Exception('Failed to delete reply');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting reply: $e')),
      );
    }
  }

  void showReplyDialog(int? replyToId) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(replyToId == null ? 'Reply to this Reply' : 'Reply to Comment'),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Enter your reply...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                postReply(replyController.text, replyToId);
                Navigator.pop(context);
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = replyData != null && username != null && replyData!['user'] == username;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply Detail'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : replyData == null
              ? const Center(child: Text('Reply not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replyData!['content'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text('by ${replyData!['user']}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up, color: Colors.blue, size: 20),
                                onPressed: () {
                                  likeReply(replyData!['id']);
                                },
                              ),
                              Text('${replyData!['total_likes']}'),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.thumb_down, color: Colors.red, size: 20),
                                onPressed: () {
                                  dislikeReply(replyData!['id']);
                                },
                              ),
                              Text('${replyData!['total_dislikes']}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            replyData!['created_at'],
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          // Tombol untuk membalas reply ini
                          ElevatedButton.icon(
                            onPressed: () {
                              // Reply ke reply ini
                              showReplyDialog(replyData!['id']);
                            },
                            icon: const Icon(Icons.reply),
                            label: const Text('Reply to this Reply'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Replies to this Reply:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          replyData!['replies'] == null || replyData!['replies'].isEmpty
                              ? const Text('No replies yet.')
                              : buildNestedReplies(List<Map<String, dynamic>>.from(replyData!['replies'])),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget buildNestedReplies(List<Map<String, dynamic>> replies, {int depth = 0}) {
    return ListView.builder(
      itemCount: replies.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final rep = replies[index];
        final isReplyAuthor = username != null && rep['user'] == username;
        return Padding(
          padding: EdgeInsets.only(left: depth * 16.0, bottom: 8.0),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            color: depth % 2 == 0 ? Colors.grey[100] : Colors.grey[200],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(rep['content'], style: const TextStyle(fontSize: 16)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('– ${rep['user']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (rep['replies'] != null && rep['replies'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: buildNestedReplies(List<Map<String, dynamic>>.from(rep['replies']), depth: depth + 1),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new, color: Colors.green),
                    tooltip: 'View this Reply as a Post',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReplyDetailPage(replyId: rep['id']),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_up, color: Colors.blue),
                    onPressed: () {
                      likeReply(rep['id']);
                    },
                  ),
                  Text('${rep['total_likes'] ?? 0}'),
                  IconButton(
                    icon: const Icon(Icons.thumb_down, color: Colors.red),
                    onPressed: () {
                      dislikeReply(rep['id']);
                    },
                  ),
                  Text('${rep['total_dislikes'] ?? 0}'),
                  IconButton(
                    icon: const Icon(Icons.reply, color: Colors.blue),
                    onPressed: () {
                      showReplyDialog(rep['id']);
                    },
                  ),
                  if (isReplyAuthor)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text('Delete Reply'),
                              content: const Text('Are you sure you want to delete this reply?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    deleteReply(rep['id']);
                                  },
                                  child: const Text('Delete'),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
