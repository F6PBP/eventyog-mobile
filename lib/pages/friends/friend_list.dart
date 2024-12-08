import 'package:eventyog_mobile/models/FriendListModel.dart';
import 'package:eventyog_mobile/pages/friends/friend_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    Future<FriendListModel> fetchFriendList(CookieRequest request) async {
      final response =
          await request.get("${dotenv.env['HOSTNAME']}:8000/api/friend/list/");

      return FriendListModel.fromJson(response);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Friends',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'List of your friends',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              const SizedBox(height: 32.0),
              FutureBuilder<FriendListModel>(
                future: fetchFriendList(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData ||
                      snapshot.data!.data.friends.isEmpty) {
                    return const Text('No friends found.');
                  } else {
                    final friends = snapshot.data!.data.friends;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(friends[index].username),
                            subtitle: Text(friends[index].email),
                            leading: CircleAvatar(
                              child: Text(friends[index].username[0]),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendDetailPage(
                                    name: friends[index].username,
                                    email: friends[index].email,
                                    phone: "1234567890",
                                    address: "123, Street Name",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FriendRecommendationPage extends StatefulWidget {
  const FriendRecommendationPage({super.key});

  @override
  State<FriendRecommendationPage> createState() =>
      _FriendRecommendationPageState();
}

class _FriendRecommendationPageState extends State<FriendRecommendationPage> {
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    Future<FriendListModel> fetchFriendRecommendations(
        CookieRequest request) async {
      final response = await request
          .get("${dotenv.env['HOSTNAME']}:8000/api/friend/recommendations/");

      return FriendListModel.fromJson(response);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Recommendations'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'List of friend recommendations',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              const SizedBox(height: 32.0),
              FutureBuilder<FriendListModel>(
                future: fetchFriendRecommendations(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData ||
                      snapshot.data!.data.friends.isEmpty) {
                    return const Text('No recommendations found.');
                  } else {
                    final friends = snapshot.data!.data.friends;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(friends[index].username),
                            subtitle: Text(friends[index].email),
                            leading: CircleAvatar(
                              child: Text(friends[index].username[0]),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendDetailPage(
                                    name: friends[index].username,
                                    email: friends[index].email,
                                    phone: "1234567890",
                                    address: "123, Street Name",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
