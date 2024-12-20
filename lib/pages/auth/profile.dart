import 'package:eventyog_mobile/models/ProfileModel.dart';
import 'package:eventyog_mobile/pages/auth/edit_profile.dart';
import 'package:eventyog_mobile/pages/auth/login.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(secondary: Colors.deepPurple[400]),
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<ProfileModel> fetchUserProfile(CookieRequest request) async {
    final response =
        await request.get("http://127.0.0.1:8000/api/auth/profile/");
    return ProfileModel.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder<ProfileModel>(
      future: fetchUserProfile(request),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            bottomNavigationBar: AnimatedBottomNavigationBar(
              currentIndex: 4,
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            bottomNavigationBar: const AnimatedBottomNavigationBar(
              currentIndex: 4,
            ),
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
            bottomNavigationBar: const AnimatedBottomNavigationBar(
              currentIndex: 4,
            ),
            appBar: AppBar(
              title: const Text("Profile"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profile.data.imageUrl!),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    profile.data.username!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.data.name!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.data.email!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (profile.data.bio != null && profile.data.bio!.isNotEmpty)
                    Text(
                      profile.data.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 30),
                  if (profile.data.categories != null &&
                      profile.data.categories!.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: profile.data.categories!
                            .split(',')
                            .map<Widget>((category) {
                          return Chip(
                            label: Text(category.trim()),
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: const TextStyle(color: Colors.blue),
                            shape: const StadiumBorder(),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final response = await request
                              .logout("http://127.0.0.1:8000/api/auth/logout/");
                          String message = response["message"];
                          if (context.mounted) {
                            if (response['status']) {
                              String uname = response["username"];
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("$message Goodbye, $uname."),
                                ),
                              );
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
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile"),
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
