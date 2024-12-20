import 'package:eventyog_mobile/const.dart';
import 'package:eventyog_mobile/models/FriendListModel.dart';
import 'package:eventyog_mobile/pages/friends/friend_detail.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
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
      final response = await request.get("$fetchUrl/api/friend/list/");
      return FriendListModel.fromJson(response);
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Friends List', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: const AnimatedBottomNavigationBar(
        currentIndex: 3,
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
                                    id: friends[index].id,
                                    name: friends[index].username,
                                    email: friends[index].email,
                                    phone: "1234567890",
                                    address: "123, Street Name",
                                    isFriend: friends[index].is_friend,
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
              const SizedBox(height: 32.0),
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
                future: fetchFriendList(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData ||
                      snapshot.data!.data.friendsRecommendation.isEmpty) {
                    return const Text('No recommendations found.');
                  } else {
                    final friends = snapshot.data!.data.friendsRecommendation;
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
                                    id: friends[index].id,
                                    name: friends[index].username,
                                    email: friends[index].email,
                                    phone: "1234567890",
                                    address: "123, Street Name",
                                    isFriend: friends[index].is_friend,
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
