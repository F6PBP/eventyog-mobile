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
      appBar: AppBar(title: const Text("Post Detail")),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forumDetail.forumPost.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("By ${forumDetail.forumPost.user}"),
                const SizedBox(height: 16),
                Text(forumDetail.forumPost.content),
                const Divider(),
                const Text("Replies", style: TextStyle(fontSize: 18)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: forumDetail.replies.length,
                  itemBuilder: (context, index) {
                    final reply = forumDetail.replies[index];
                    return ListTile(
                      title: Text(reply.user),
                      subtitle: Text(reply.content),
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
