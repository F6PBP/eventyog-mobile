import 'package:eventyog_mobile/pages/forum/reply_detail.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

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

  String? username; // Akan kita ambil dari CookieRequest

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      username = request.jsonData['username'];
      fetchPostDetail();
    });
  }

  Future<void> fetchPostDetail() async {
    if (username == null || username!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Username not found. Make sure you are logged in.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/yogforum/post/${widget.postId}/'),
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
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:8000/api/yogforum/like_post/${widget.postId}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
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

  Future<void> toggleDislikePost() async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:8000/api/yogforum/dislike_post/${widget.postId}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          setState(() {
            forumPost!['total_likes'] = data['total_likes'];
            forumPost!['total_dislikes'] = data['total_dislikes'];
          });
        } else {
          throw Exception('Gagal melakukan dislike: ${data['message']}');
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

  Future<void> likeReply(int replyId) async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/yogforum/like_reply/$replyId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          fetchPostDetail();
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
        Uri.parse('http://10.0.2.2:8000/api/yogforum/dislike_reply/$replyId/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          fetchPostDetail();
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

  Future<void> editPost(String newTitle, String newContent) async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:8000/api/yogforum/edit/${forumPost!['id']}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'title': newTitle,
          'content': newContent,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          fetchPostDetail();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post edited successfully!')),
          );
        } else {
          throw Exception('Failed to edit post: ${data['message']}');
        }
      } else {
        throw Exception('Failed to edit post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing post: $e')),
      );
    }
  }

  Future<void> postReply(String content, [int? replyTo]) async {
    if (username == null || username!.isEmpty) return;
    try {
      final body = <String, dynamic>{
        'content': content,
        'username': username,
      };
      if (replyTo != null) {
        body['reply_to'] = replyTo;
      }

      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:8000/api/yogforum/post/${forumPost!['id']}/add_reply/'),
        body: jsonEncode(body),
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

  Future<void> deletePost() async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:8000/api/yogforum/post/${forumPost!['id']}/delete/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully!')),
          );
          Navigator.pop(context);
        } else {
          throw Exception('Failed to delete post: ${data['message']}');
        }
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  Future<void> deleteReply(int replyId) async {
    if (username == null || username!.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/yogforum/reply/$replyId/delete/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reply deleted successfully!')),
          );
          fetchPostDetail();
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

  Widget buildReplies(List<Map<String, dynamic>> replyList, {int depth = 0}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: replyList.length,
      itemBuilder: (context, index) {
        final reply = replyList[index];
        final isReplyAuthor = username != null && reply['user'] == username;

        return Padding(
          padding: EdgeInsets.only(left: depth * 16.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: depth % 2 == 0 ? Colors.grey[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (reply['replies'] != null &&
                          reply['replies'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: buildReplies(
                              List<Map<String, dynamic>>.from(reply['replies']),
                              depth: depth + 1),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.open_in_new, color: Colors.green),
                        tooltip: 'View this Reply as a Post',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReplyDetailPage(replyId: reply['id']),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up, color: Colors.blue),
                        onPressed: () {
                          likeReply(reply['id']);
                        },
                      ),
                      Text('${reply['total_likes'] ?? 0}'),
                      IconButton(
                        icon: const Icon(Icons.thumb_down, color: Colors.red),
                        onPressed: () {
                          dislikeReply(reply['id']);
                        },
                      ),
                      Text('${reply['total_dislikes'] ?? 0}'),
                      IconButton(
                        icon: const Icon(Icons.reply, color: Colors.blue),
                        onPressed: () {
                          showReplyDialog(reply['id']);
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
                                  content: const Text(
                                      'Are you sure you want to delete this reply?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        deleteReply(reply['id']);
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
              ],
            ),
          ),
        );
      },
    );
  }

  // Ubah showReplyDialog agar menerima int? replyToId
  void showReplyDialog(int? replyToId) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(replyToId == null ? 'Reply to Post' : 'Reply to Comment'),
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

  void showEditDialog() {
    final titleController = TextEditingController(text: forumPost!['title']);
    final contentController =
        TextEditingController(text: forumPost!['content']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                editPost(titleController.text, contentController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                deletePost();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor =
        forumPost != null && username != null && forumPost!['user'] == username;

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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Ganti menjadi Card
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        forumPost!['title'],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isAuthor)
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.grey),
                                            onPressed: () {
                                              showEditDialog();
                                            },
                                          ),
                                        if (isAuthor)
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              showDeleteDialog();
                                            },
                                          ),
                                      ],
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
                                        toggleDislikePost();
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
                                    showReplyDialog(null);
                                  },
                                  icon: const Icon(Icons.reply, size: 20),
                                  label: const Text('Reply to this Post'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 15),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
