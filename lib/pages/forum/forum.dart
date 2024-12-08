import 'package:eventyog_mobile/models/ForumModel.dart';
import 'package:eventyog_mobile/pages/forum/services/forum_service.dart';
import 'forum_detail.dart';
import 'add_post_page.dart'; // Import AddPostPage
import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Map<String, dynamic>> forumPosts = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchForumPosts('');
  }

  void _fetchForumPosts(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final posts = await fetchForumPosts(query);
      setState(() {
        forumPosts = posts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
      ),
      body: Column(
        children: [
          // Search Bar & Add Post Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search posts...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onChanged: (value) {
                      _fetchForumPosts(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Add Post Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPostPage(),
                      ),
                    ).then((_) {
                      _fetchForumPosts(''); // Refresh after adding a post
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Post'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Forum Posts List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : forumPosts.isEmpty
                    ? const Center(child: Text('No posts found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: forumPosts.length,
                        itemBuilder: (context, index) {
                          final post = forumPosts[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to Post Detail Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ForumDetailPage(postId: post['id']),
                                ),
                              ).then((_) {
                                _fetchForumPosts(''); // Refresh after returning
                              });
                            },
                            child: Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            post['profile_picture'] ??
                                                "https://res.cloudinary.com/mxgpapp/image/upload/v1729588463/ux6rsms8ownd5oxxuqjr.png",
                                          ),
                                          radius: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "By ${post['user']}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.thumb_up_alt_outlined,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text("${post['totalLike']}"),
                                            const SizedBox(width: 16),
                                            const Icon(
                                              Icons.thumb_down_alt_outlined,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text("${post['totalDislike']}"),
                                            const SizedBox(width: 16),
                                            const Icon(
                                              Icons.comment,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text("${post['comment_count']}"),
                                          ],
                                        ),
                                        Text(
                                          post['created_at'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}