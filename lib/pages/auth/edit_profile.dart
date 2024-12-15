import 'dart:io';

import 'package:eventyog_mobile/models/ProfileModel.dart';
import 'package:eventyog_mobile/widgets/BottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  File? _profileImage;
  List<String> _selectedCategories = [];

  final List<String> _categories = [
    'Olahraga',
    'Seni',
    'Musik',
    'Cosplay',
    'Lingkungan',
    'Volunteer',
    'Akademis',
    'Kuliner',
    'Pariwisata',
    'Festival',
    'Film',
    'Fashion',
    'Lainnya',
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<ProfileModel> fetchUserProfile(CookieRequest request) async {
    final response =
        await request.get("http://127.0.0.1:8000/api/auth/profile/");
    return ProfileModel.fromJson(response);
  }

  Future<void> updateUserProfile(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      final response = await request.post(
        "http://127.0.0.1:8000//api/auth/profile/edit/",
        {
          'username': _usernameController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'bio': _bioController.text,
          'categories': _selectedCategories.join(','),
        },
      );
      if (response['status']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  List<Widget> _buildCategoryChips() {
    return _selectedCategories.toSet().map((category) {
      return Chip(
        label: Text(category),
        onDeleted: () {
          setState(() {
            _selectedCategories.remove(category);
          });
        },
      );
    }).toList();
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
              title: const Text("Edit Profile"),
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
          _usernameController.text = profile.data.username!;
          _nameController.text = profile.data.name!;
          _emailController.text = profile.data.email!;
          _bioController.text = profile.data.bio!;
          if (_selectedCategories.isEmpty) {
            _selectedCategories = profile.data.categories!.split(',');
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("Edit Profile"),
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
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : NetworkImage(profile.data.imageUrl)
                                as ImageProvider<Object>,
                        child: _profileImage == null
                            ? const Icon(Icons.add_a_photo, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    MultiSelectDialogField(
                      items: _categories
                          .map((category) =>
                              MultiSelectItem<String>(category, category))
                          .toList(),
                      title: const Text('Preferred Categories'),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      buttonText: const Text(
                        'Select Preferred Categories',
                        style: TextStyle(fontSize: 16),
                      ),
                      initialValue: _selectedCategories,
                      onConfirm: (values) {
                        setState(() {
                          _selectedCategories =
                              values.cast<String>().toSet().toList();
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Wrap(
                    //   spacing: 8.0,
                    //   children: _buildCategoryChips(),
                    // ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () => updateUserProfile(request),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Edit Profile"),
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
