import 'package:eventyog_mobile/pages/friends/friend_detail.dart';
import 'package:flutter/material.dart';

class FriendListPage extends StatelessWidget {
  const FriendListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> friends = [
      {'name': 'John Doe', 'email': 'john@example.com'},
      {'name': 'Jane Smith', 'email': 'jane@example.com'},
      {'name': 'Alice Johnson', 'email': 'alice@example.com'},
      {'name': 'Bob Brown', 'email': 'bob@example.com'},
    ];

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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(friends[index]['name']!),
                      subtitle: Text(friends[index]['email']!),
                      leading: CircleAvatar(
                        child: Text(friends[index]['name']![0]),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendDetailPage(
                              name: friends[index]['name']!,
                              email: friends[index]['email']!,
                              phone: '1234567890',
                              address: '123 Main St, City',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
