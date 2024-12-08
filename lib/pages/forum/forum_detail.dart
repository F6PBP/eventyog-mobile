import 'package:eventyog_mobile/models/ForumModel.dart';
import 'package:eventyog_mobile/pages/forum/services/forum_service.dart';
import 'package:flutter/material.dart';

class ForumDetailPage extends StatefulWidget {
  final int postId;

  const ForumDetailPage({required this.postId, Key? key}) : super(key: key);

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  late Future<ForumDetailModel> _forumDetail;

  @override
  void initState() {
    super.initState();
    _forumDetail = fetchForumDetail(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Detail"),
      ),
      body: FutureBuilder<ForumDetailModel>(
        future: _forumDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Post not found"));
          }

          final forumDetail = snapshot.data!;
          final forumPost = forumDetail.forumPost;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(forumPost.profilePicture.isNotEmpty
                          ? forumPost.profilePicture
                          : "https://res.cloudinary.com/mxgpapp/image/upload/v1729588463/ux6rsms8ownd5oxxuqjr.png"),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            forumPost.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "By ${forumPost.user}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          // Navigate to edit post
                        } else if (value == "delete") {
                          // Handle delete
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                        const PopupMenuItem(value: "delete", child: Text("Delete")),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Post Content
                Text(
                  forumPost.content,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${forumPost.createdAt}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                          onPressed: () {
                            // Handle like
                          },
                        ),
                        Text("${forumPost.totalLike}"),
                        IconButton(
                          icon: const Icon(Icons.thumb_down_alt_outlined),
                          onPressed: () {
                            // Handle dislike
                          },
                        ),
                        Text("${forumPost.totalDislike}"),
                      ],
                    ),
                  ],
                ),
                const Divider(),

                // Replies Section
                const Text(
                  "Replies",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: forumDetail.replies.length,
                  itemBuilder: (context, index) {
                    final reply = forumDetail.replies[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(reply.profilePicture.isNotEmpty
                                  ? reply.profilePicture
                                  : "https://res.cloudinary.com/mxgpapp/image/upload/v1729588463/ux6rsms8ownd5oxxuqjr.png"),
                              radius: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reply.user,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(reply.content),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                                        onPressed: () {
                                          // Handle like
                                        },
                                      ),
                                      Text("${reply.totalLike}"),
                                      IconButton(
                                        icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
                                        onPressed: () {
                                          // Handle dislike
                                        },
                                      ),
                                      Text("${reply.totalDislike}"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}