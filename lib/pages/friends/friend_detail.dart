import 'dart:convert';

import 'package:eventyog_mobile/const.dart';
import 'package:eventyog_mobile/pages/friends/friend_list.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
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
          "$fetchUrl/api/friend/add/$id",
          jsonEncode(<String, String>{}),
        );

        if (response['status'] == true) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => FriendListPage()));

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
          "$fetchUrl/api/friend/remove/$id",
          jsonEncode(<String, String>{}),
        );

        if (response['status'] == true) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => FriendListPage()));

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: Text(
                  name[0],
                  style: TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 24.0),
              _buildDetailItem(Icons.person, 'Name', name),
              _buildDetailItem(Icons.email, 'Email', email),
              _buildDetailItem(Icons.phone, 'Phone', phone),
              _buildDetailItem(Icons.home, 'Address', address),
              const SizedBox(height: 24.0),
              isFriend
                  ? ElevatedButton.icon(
                      onPressed: () {
                        removeFriend(request);
                      },
                      icon: Icon(Icons.person_remove, color: Colors.white),
                      label: Text("Remove Friend",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        addFriend(request);
                      },
                      icon: Icon(Icons.person_add, color: Colors.white),
                      label: Text("Add Friend",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
            ],
          ),
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
