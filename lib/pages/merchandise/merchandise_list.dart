import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'merchandise_card.dart';
import 'merchandise_detail.dart';
import 'create_merchandise.dart';
import 'edit_merchandise.dart';

class MerchandiseList extends StatefulWidget {
  @override
  _MerchandiseListState createState() => _MerchandiseListState();
}

class _MerchandiseListState extends State<MerchandiseList> {
  List<dynamic> merchandise = [];

  @override
  void initState() {
    super.initState();
    fetchMerchandise();
  }

  Future<void> fetchMerchandise() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://127.0.0.1:8000/api/merchandise/show/7e74fdc9-c388-4d16-ae1b-58eac2b1438e/");
      if (response['status'] == 'success') {
        print(response['data']);
        setState(() {
          merchandise = response['data'];
        });
      } else {
        throw Exception('Failed to load merchandise');
      }
    } catch (e) {
      // Handle error appropriately
      print('Error fetching merchandise: $e');
    }
  }

  Future<void> deleteMerchandise(int id) async {
    final url = "http://127.0.0.1:8000/api/merchandise/delete/$id/";
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          await fetchMerchandise(); // Refetch merchandise after deletion
        } else {
          throw Exception('Failed to delete merchandise');
        }
      } else {
        throw Exception('Failed to delete merchandise');
      }
    } catch (e) {
      // Handle error appropriately
      print('Error deleting merchandise: $e');
    }
  }

  void _navigateToCreateMerchandise() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMerchandise(onCreate: fetchMerchandise),
      ),
    );
  }

  void _navigateToEditMerchandise(dynamic merchandise) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMerchandise(
          name: merchandise['name'],
          description: merchandise['description'],
          price: merchandise['price'].toString(),
          imageUrl: merchandise['image_url'],
          id: merchandise['pk'],
          onEdit: fetchMerchandise,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchandise List'),
      ),
      body: ListView.builder(
        itemCount: merchandise.length,
        itemBuilder: (context, index) {
          return MerchandiseCard(
            imageUrl: merchandise[index]['image_url'] ?? '',
            quantity: merchandise[index]['quantity'] ?? 0,
            name: merchandise[index]['name'] ?? 'Unknown',
            description: merchandise[index]['description'] ?? 'No description',
            price: merchandise[index]['price']?.toString() ?? '0.0',
            isAdmin: false,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MerchandiseDetail(
                    id: merchandise[index]['pk'],
                    imageUrl: merchandise[index]['image_url'] ?? '',
                    name: merchandise[index]['name'] ?? 'Unknown',
                    description: merchandise[index]['description'] ?? 'No description',
                    price: merchandise[index]['price']?.toString() ?? '0.0',
                    isAdmin: true,
                    onEdit: fetchMerchandise, // Pass callback
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            onDelete: () => deleteMerchandise(merchandise[index]['pk']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMerchandise,
        child: Icon(Icons.add),
        tooltip: 'Create Merchandise',
      ),
    );
  }
}
