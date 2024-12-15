import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:eventyog_mobile/models/ProfileModel.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({Key? key}) : super(key: key);

  @override
  _AdminUserListPageState createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  List<ProfileModel> _users = [];
  List<ProfileModel> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchUsers(CookieRequest request) async {
    try {
      final response = await request.get("http://127.0.0.1:8000/api/auth/profile/");
      
      if (response != null && response is List) {
        setState(() {
          _users = response.map((userJson) => ProfileModel.fromJson(userJson)).toList();
          _filteredUsers = _users;
        });
      } else {
        print('Unexpected response format');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users
          .where((user) => 
            user.data.name!.toLowerCase().contains(query.toLowerCase()) || 
            user.data.email!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showAddUserModal() {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20
          ),
          child: _buildAddUserForm(),
        ),
      )
    );
  }

  Widget _buildAddUserForm() {
    // Implement your add user form logic here
    return Column(
      children: [
        Text(
          'Create New User', 
          style: Theme.of(context).textTheme.titleLarge
        ),
        // Add form fields for username, email, password, etc.
        ElevatedButton(
          onPressed: () {
            // Implement user creation logic
            Navigator.of(context).pop();
          }, 
          child: Text('Create User')
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      fetchUsers(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddUserModal,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: _buildUserGrid()
          )
        ],
      ),
    );
  }

  Widget _buildUserGrid() {
    return _filteredUsers.isEmpty 
      ? const Center(child: Text('No users found'))
      : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10
          ),
          itemCount: _filteredUsers.length,
          itemBuilder: (context, index) {
            final user = _filteredUsers[index];
            return _buildUserCard(user);
          },
        );
  }

  Widget _buildUserCard(ProfileModel user) {
    return GestureDetector(
      onTap: () {
        // Navigate to user detail page
        // Navigator.push(context, MaterialPageRoute(...))
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.data.imageUrl != null 
                ? NetworkImage(user.data.imageUrl!)
                : const AssetImage('assets/placeholder_avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              user.data.name ?? '', 
              style: Theme.of(context).textTheme.titleMedium
            ),
            Text(
              user.data.email ?? '', 
              style: Theme.of(context).textTheme.bodyMedium
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: user.data.categories != null
                  ? user.data.categories!
                      .split(',')
                      .map<Widget>((category) => Chip(
                            label: Text(category),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: const TextStyle(color: Colors.blue),
                          ))
                      .toList() // Convert Iterable to List
                  : [const Text("No categories")],
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add edit or view details functionality
              }, 
              child: const Text('View Details')
            )
          ],
        ),
      ),
    );
  }
}