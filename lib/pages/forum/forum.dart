import 'package:eventyog_mobile/pages/forum/add_post_page.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'forum_detail.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Map<String, dynamic>> allForumPosts = [];
  List<Map<String, dynamic>> filteredForumPosts = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String sortCriteria = 'latest';

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });

    String url = 'http://10.0.2.2:8000/api/yogforum/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          allForumPosts = List<Map<String, dynamic>>.from(
              data['results'] ?? data['forum_posts'] ?? []);
          _filterPosts(_searchController.text);
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

  void _filterPosts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredForumPosts = List.from(allForumPosts);
      } else {
        filteredForumPosts = allForumPosts
            .where((post) =>
                post['title']?.toLowerCase().contains(query.toLowerCase()) ??
                false ||
                    post['user']?.toLowerCase().contains(query.toLowerCase()) ??
                false)
            .toList();
      }
      _sortPosts();
    });
  }

  void _sortPosts() {
    if (sortCriteria == 'latest') {
      filteredForumPosts
          .sort((a, b) => b['created_at'].compareTo(a['created_at']));
    } else if (sortCriteria == 'oldest') {
      filteredForumPosts
          .sort((a, b) => a['created_at'].compareTo(b['created_at']));
    } else if (sortCriteria == 'most_liked') {
      filteredForumPosts
          .sort((a, b) => (b['likes'] ?? 0).compareTo(a['likes'] ?? 0));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community Forum',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                sortCriteria = value;
                _sortPosts();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'latest', child: Text('Latest')),
              const PopupMenuItem(value: 'oldest', child: Text('Oldest')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AnimatedBottomNavigationBar(
        currentIndex: 2,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search posts...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                      onChanged: (value) {
                        _filterPosts(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddPostPage()),
                      ).then((_) => fetchPosts());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : filteredForumPosts.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No posts found.')),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = filteredForumPosts[index];
                          final String title = post['title'] ?? 'Untitled';
                          final String user = post['user'] ?? 'Unknown user';
                          final String profilePicture =
                              post['profile_picture'] ?? '';
                          final String postTime =
                              post['created_at'] ?? DateTime.now().toString();

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    16.0), // Add horizontal padding here
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  backgroundImage: profilePicture.isNotEmpty
                                      ? NetworkImage(profilePicture)
                                      : null,
                                  child: profilePicture.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('By $user'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Posted on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(postTime))}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ForumDetailPage(postId: post['id']),
                                    ),
                                  ).then((_) => fetchPosts());
                                },
                              ),
                            ),
                          );
                        },
                        childCount: filteredForumPosts.length,
                      ),
                    ),
        ],
      ),
    );
  }
}
