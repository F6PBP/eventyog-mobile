import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool isLoading = false;

  Future<void> addPost() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Ambil request dari provider
      final request = context.read<CookieRequest>();
      // Ambil username yang sudah disimpan saat login
      final String? username = request.jsonData['username'];

      if (username == null || username.isEmpty) {
        throw Exception('Username not found. Make sure you are logged in.');
      }

      final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/yogforum/add-post/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'title': _titleController.text,
        'content': _contentController.text,
      }),
    );

      if (response.statusCode == 201) {
        // Jika berhasil, kembali ke halaman sebelumnya atau tampilkan pesan sukses
        Navigator.pop(context);
      } else {
        // Jika gagal, tampilkan error dari response
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Failed to add post';
        throw Exception(message);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding post: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    // Cek username (opsional, untuk debugging)
    // print("Logged in as: ${request.jsonData['username']}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: isLoading ? null : addPost,
              child: isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
