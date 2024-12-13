import 'package:eventyog_mobile/pages/forum/add_post_page.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'forum_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Map<String, dynamic>> forumPosts = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchPosts(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/yogforum/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          forumPosts = List<Map<String, dynamic>>.from(data['forum_posts']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load posts');
      }
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
  void initState() {
    super.initState();
    fetchPosts('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Forum'),
      ),
      bottomNavigationBar: const AnimatedBottomNavigationBar(
        currentIndex: 2,
      ),
      body: Column(
        children: [
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
                      fetchPosts(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPostPage()),
                    ).then((_) => fetchPosts(''));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Post'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: forumPosts.length,
                    itemBuilder: (context, index) {
                      final post = forumPosts[index];
                      return ListTile(
                        title: Text(post['title']),
                        subtitle: Text('By ${post['user']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForumDetailPage(postId: post['id']),
                            ),
                          ).then((_) => fetchPosts(''));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}