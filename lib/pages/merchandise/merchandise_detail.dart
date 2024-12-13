import 'package:flutter/material.dart';
import 'edit_merchandise.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MerchandiseDetail extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final bool isAdmin;
  final int id; // Add id parameter
  final VoidCallback onEdit; // Add callback for refetching

  MerchandiseDetail({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.isAdmin,
    required this.id, // Initialize id
    required this.onEdit, // Initialize callback
  });

  @override
  _MerchandiseDetailState createState() => _MerchandiseDetailState();
}

class _MerchandiseDetailState extends State<MerchandiseDetail> {
  late String name;
  late String description;
  late String price;
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    description = widget.description;
    price = widget.price;
    imageUrl = widget.imageUrl;
  }

  void _editMerchandise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMerchandise(
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          id: widget.id, // Pass id parameter
          onEdit: widget.onEdit, // Pass callback
        ),
      ),
    );

    if (result != null) {
      setState(() {
        name = result['name'];
        description = result['description'];
        price = result['price'];
        imageUrl = result['imageUrl'];
      });
    }
  }

  Future<void> deleteMerchandise() async {
    final url = "http://127.0.0.1:8000/api/merchandise/delete/${widget.id}/";
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
          widget.onEdit(); // Refetch merchandise list
          Navigator.pop(context); // Go back to the previous screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: null, // Remove the pencil icon button
      ),
      body: SingleChildScrollView( // Make content scrollable
        padding: const EdgeInsets.all(24.0), // Add padding to the whole page content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Add padding around the image
                child: Image.network(
                  imageUrl,
                  height: 350, // Increase height
                  width: 400,  // Increase width for a larger rectangle
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Rp$price',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            if (widget.isAdmin) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _editMerchandise,
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: deleteMerchandise, // Call delete function
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
