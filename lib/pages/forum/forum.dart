import 'package:flutter/material.dart';
import 'package:eventyog_mobile/pages/forum/services/forum_service.dart';
import 'forum_detail.dart';

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
        title: const Text('Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigasi ke halaman tambah post
              Navigator.pushNamed(context, '/add_post').then((_) {
                _fetchForumPosts(''); // Refresh setelah menambah post
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                _fetchForumPosts(value);
              },
            ),
          ),
          // Daftar Post
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : forumPosts.isEmpty
                    ? const Center(child: Text('No posts found.'))
                    : ListView.builder(
                        itemCount: forumPosts.length,
                        itemBuilder: (context, index) {
                          final post = forumPosts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            child: ListTile(
                              title: Text(post['title']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Likes: ${post['totalLike']}'),
                                  Text(
                                    'Created by: ${post['user']}',
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () {
                                // Navigasi ke detail post
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ForumDetailPage(postId: post['id']),
                                  ),
                                ).then((_) {
                                  _fetchForumPosts(''); // Refresh setelah kembali
                                });
                              },
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
