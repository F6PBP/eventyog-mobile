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
  final String eventId; // Add eventId parameter

  MerchandiseList({required this.eventId}); // Update constructor

  @override
  _MerchandiseListState createState() => _MerchandiseListState();
}

class _MerchandiseListState extends State<MerchandiseList> {
  List<dynamic> merchandise = [];
  bool isAdmin = false;
  bool isLoading = true; // Add loading state
  String errorMessage = ''; // Add error message state

  @override
  void initState() {
    super.initState();
    fetchMerchandise();
  }

  Future<void> fetchMerchandise() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("http://10.0.2.2:8000/api/merchandise/show/${widget.eventId}/");
      
      if (response['status'] == 'success') {
        setState(() {
          merchandise = response['data'];
          isAdmin = response['is_admin'] ?? false; // Ensure isAdmin is set to false if not provided
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load merchandise');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching merchandise: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteMerchandise(int id) async {
    final url = "http://10.0.2.2:8000/api/merchandise/delete/$id/";
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
        builder: (context) => CreateMerchandise(
          onCreate: fetchMerchandise,
          eventId: widget.eventId, // Pass eventId to CreateMerchandise
        ),
      ),
    );
  }

  void _navigateToEditMerchandise(dynamic merchandise) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMerchandise(
          name: merchandise['name'],
          description: merchandise['description'],
          price: merchandise['price'].toString(),
          imageUrl: merchandise['image_url'],
          id: merchandise['pk'],
          onEdit: fetchMerchandise,
          quantity: merchandise['quantity'].toString(), // Pass quantity parameter
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final index = this.merchandise.indexWhere((item) => item['pk'] == result['id']);
        if (index != -1) {
          this.merchandise[index] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Merchandise List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isAdmin)
              TextButton(
                onPressed: _navigateToCreateMerchandise,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Create Merchandise'),
                  ],
                ),
              ),
          ],
        ),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : ListView.builder(
                    shrinkWrap: true, // Add this line
                    physics: NeverScrollableScrollPhysics(), // Add this line
                    itemCount: merchandise.length,
                    itemBuilder: (context, index) {
                      return MerchandiseCard(
                        imageUrl: merchandise[index]['image_url'] ?? '',
                        quantity: merchandise[index]['quantity'] ?? 0,
                        name: merchandise[index]['name'] ?? 'Unknown',
                        description: merchandise[index]['description'] ?? 'No description',
                        price: merchandise[index]['price']?.toString() ?? '0.0',
                        isAdmin: isAdmin,
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
                                isAdmin: isAdmin,
                                onEdit: fetchMerchandise, // Pass callback
                                quantity: merchandise[index]['quantity']?.toString() ?? '0', // Pass quantity parameter
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
                        onDelete: isAdmin ? () => deleteMerchandise(merchandise[index]['pk']) : null,
                      );
                    },
                  ),
      ],
    );
  }
}
