import 'package:eventyog_mobile/models/ProfileModel.dart';
import 'package:eventyog_mobile/pages/auth/edit_profile.dart';
import 'package:eventyog_mobile/pages/auth/login.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class UserDetailPage extends StatefulWidget {
  final String username; // Or userId, depending on what you use to identify users
  
  const UserDetailPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Future<ProfileModel> fetchUserProfile(CookieRequest request) async {
  try {
    final encodedUsername = Uri.encodeComponent(widget.username);

    print('Attempting to fetch user with username: ${widget.username}'); // Debug print
    print('Encoded username: $encodedUsername'); // Debug print
    final url = "http://127.0.0.1:8000/api/admin/see_user/$encodedUsername";
    print('Request URL: $url'); // Debug print
    
    final response = await request.get(
      "http://127.0.0.1:8000/api/admin/see_user/$encodedUsername"
    );
    print('Response: $response'); // Debugging

    if (response != null && response['status'] == true) {
      final userJson = response['data'];
      return ProfileModel(
        status: true,
        message: response['message'] ?? '',
        data: Data(
          username: userJson['username'] ?? '',
          name: userJson['name'] ?? '',
          email: userJson['email'] ?? '',
          dateJoined: DateTime.parse(userJson['date_joined'] ?? DateTime.now().toIso8601String()),
          bio: userJson['bio'] ?? '',
          imageUrl: '', // userJson['image_url'] ?? '',
          categories: userJson['categories'] ?? ''
        )
      );
    } else {
      print('Unexpected response format');
      print('Response type: ${response.runtimeType}');
      throw Exception('Failed to load user profile');
    }
  } catch (e) {
    print('Error fetching user profile: $e');
    print('Detailed error: ${e.toString()}');
    throw Exception('Failed to load user profile');
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
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: profile.data.categories != null
                            ? profile.data.categories!
                                .split(',')
                                .map<Widget>((category) {
                                // Safely cast to String if possible and wrap it in a Chip widget
                                final categoryName = category.toString();
                                return Chip(
                                  label: Text(categoryName),
                                  backgroundColor: Colors.blue.shade100,
                                  labelStyle:
                                      const TextStyle(color: Colors.blue),
                                );
                              }).toList()
                            : [const Text("No categories available")],
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
                        // Perform logout operation here
                        final response = await request
                            .logout("http://10.0.2.2:8000/api/auth/logout/");
                        String message = response["message"];
                        if (context.mounted) {
                          if (response['status']) {
                            String uname = response["username"];
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("$message Goodbye, $uname."),
                            ));
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
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
