import 'package:eventyog_mobile/models/ProfileModel.dart';
import 'package:eventyog_mobile/pages/auth/edit_profile.dart';
import 'package:eventyog_mobile/pages/auth/login.dart';
import 'package:eventyog_mobile/pages/admin/user_list.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class UserDetailPage extends StatefulWidget {
  final String username; // Or userId, depending on what you use to identify user
  const UserDetailPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Future<ProfileModel> fetchUserProfile(CookieRequest request) async {
    //final String username;
    try {
      final encodedUsername = Uri.encodeComponent(widget.username);
      print('Attempting to fetch user with username: ${widget.username}');
      final url = "http://127.0.0.1:8000/api/admin/see_user/$encodedUsername";
      print('Request URL: $url');
      
      final response = await request.get(url);
      print('Response: $response');

      final userJson = response['data']?[0];

      // Check if the response structure is correct
      if (response['status'] == true && response['data'] != null) {
        //print('success' + userJson['username']);
        return ProfileModel(
          status: userJson['status'] ?? false,
          message: userJson['message'] ?? '',
          data: Data(
            username: userJson['username'] ?? '', // Using name as username since API doesn't seem to have a username
            name: userJson['name'] ?? '',
            email: userJson['email'] ?? '',
            dateJoined: DateTime.parse(userJson['date_joined'] ?? DateTime.now().toString()), // Default to current time since date_joined is not in API response
            bio: userJson['bio'] ?? '', // Empty bio since it's not in API response
            imageUrl: '',//userJson['profile_picture'] ?? '', // Empty image URL since it's not in API response
            categories: userJson['categories'] // Using role as categories
          ),
        );
      } else {
        throw Exception('Invalid or missing data in response');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow; // Pass the error to be handled by FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder<ProfileModel>(
      future: fetchUserProfile(request),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData) {
          final profile = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            bottomNavigationBar: const AnimatedBottomNavigationBar(
              currentIndex: 4,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(profile.data.imageUrl!),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      profile.data.username!,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.data.name!,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.data.email!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.data.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                        children: [
                          // Check if categories are available and conditionally display
                          if (profile.data.categories != null &&
                              profile.data.categories!.isNotEmpty) ...[
                            const Text(
                              "Categories:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8.0), // Add spacing below "Categories:"
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: profile.data.categories!
                                  .split(',')
                                  .map<Widget>((category) {
                                final categoryName = category.trim(); // Trim spaces
                                return Chip(
                                  label: Text(categoryName),
                                  backgroundColor: Colors.blue.shade100,
                                  labelStyle: const TextStyle(color: Colors.blue),
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            const Text(
                              "This user hasn't chosen any category",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to the edit profile page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Step 1: Confirm Deletion
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                  'Are you sure you want to delete your account? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmDelete != true) return;

                        // Step 2: Perform Delete API Call
                        try {
                          // Replace with your actual delete API endpoint and logic
                          final encodedUsername = Uri.encodeComponent(widget.username);
                          final response = await request.get("http://127.0.0.1:8000/api/admin/delete_user/$encodedUsername");

                          // Step 3: Handle Response
                          if (response['status_code'] == 200) {
                            // Assume successful deletion
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Account deleted successfully.')),
                            );

                            // Step 4: Log the user out or redirect
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const AdminUserListPage()),
                              (route) => false,
                            );
                          } else {
                            throw Exception('Failed to delete account: ${response}');
                          }
                        } catch (error) {
                          // Handle error
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting account: $error')),
                          );
                          print('Error delete user profile: $error');
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Account'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: const Center(
              child: Text('No profile data found'),
            ),
          );
        }
      },
    );
  }
}
