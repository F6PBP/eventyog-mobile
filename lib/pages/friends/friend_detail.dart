import 'dart:convert';

import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class FriendDetailPage extends StatelessWidget {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool isFriend;

  const FriendDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.isFriend,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    Future<void> addFriend(CookieRequest request) async {
      try {
        final response = await request.postJson(
          "http://10.0.2.2:8000/api/friend/add/$id",
          jsonEncode(<String, String>{}),
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Friend added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add friend.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    Future<void> removeFriend(CookieRequest request) async {
      try {
        final response = await request.postJson(
          "http://10.0.2.2:8000/api/friend/remove/$id",
          jsonEncode(<String, String>{}),
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Friend removed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove friend.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Detail'),
      ),
      bottomNavigationBar: const AnimatedBottomNavigationBar(
        currentIndex: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          child: Text(
                            name[0],
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailItem(Icons.person, 'Name', name),
                      _buildDetailItem(Icons.email, 'Email', email),
                      _buildDetailItem(Icons.phone, 'Phone', phone),
                      _buildDetailItem(Icons.home, 'Address', address),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            isFriend
                ? ElevatedButton.icon(
                    onPressed: () {
                      removeFriend(request);
                    },
                    icon: Icon(Icons.person_remove),
                    label: Text("Remove Friend"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.redAccent,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      addFriend(request);
                    },
                    icon: Icon(Icons.person_add),
                    label: Text("Add Friend"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
