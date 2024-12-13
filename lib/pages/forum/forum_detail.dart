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

  @override
  void initState() {
    super.initState();
    fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/yogforum/post/${widget.postId}/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          setState(() {
            forumPost = data['forum_post'];
            replies = List<Map<String, dynamic>>.from(data['replies']);
            isLoading = false;
          });
        } else {
          throw Exception('Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load post details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading post: $e')),
      );
    }
  }

  Future<void> toggleLikePost() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:8000/api/yogforum/like_post/${widget.postId}/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          setState(() {
            forumPost!['total_likes'] = data['total_likes'];
            forumPost!['total_dislikes'] = data['total_dislikes'];
          });
        } else {
          throw Exception('Gagal melakukan like: ${data['message']}');
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

  Future<void> postReply(String content, [int? replyTo]) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:8000/api/yogforum/post/${forumPost!['id']}/add_reply/'),
        body: jsonEncode({'content': content, 'reply_to': replyTo}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 && jsonDecode(response.body)['success']) {
        fetchPostDetail(); 
      } else {
        throw Exception('Failed to post reply');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting reply: $e')),
      );
    }
  }

  Widget buildReplies(List<Map<String, dynamic>> replyList, {int depth = 0}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: replyList.length,
      itemBuilder: (context, index) {
        final reply = replyList[index];
        return Padding(
          padding: EdgeInsets.only(left: depth * 16.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: depth % 2 == 0 ? Colors.grey[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  reply['content'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '– ${reply['user']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (reply['replies'] != null && reply['replies'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: buildReplies(
                          List<Map<String, dynamic>>.from(reply['replies']),
                          depth: depth + 1),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.reply, color: Colors.blue),
                onPressed: () {
                  showReplyDialog(reply['id']);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void showReplyDialog(int replyToId) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reply to Comment'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Post Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
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
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_left, color: Colors.grey),
                        label: const Text('Back',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    forumPost!['title'],
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'by ${forumPost!['user']}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              forumPost!['content'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.thumb_up,
                                      color: Colors.blue),
                                  onPressed: () {
                                    toggleLikePost();
                                  },
                                ),
                                Text('${forumPost!['total_likes']}'),
                                IconButton(
                                  icon: const Icon(Icons.thumb_down,
                                      color: Colors.red),
                                  onPressed: () {
                                  },
                                ),
                                Text('${forumPost!['total_dislikes']}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              forumPost!['created_at'],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                showReplyDialog(forumPost!['id']);
                              },
                              icon: const Icon(Icons.reply),
                              label: const Text('Reply to this Post'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Replies',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      replies.isEmpty
                          ? const Text('No replies yet.')
                          : buildReplies(replies),
                    ],
                  ),
                ),
    );
  }
}
