import 'package:flutter/material.dart';
import 'edit_merchandise.dart';

class MerchandiseDetail extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final bool isAdmin;

  MerchandiseDetail({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.isAdmin,
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
                    onPressed: () {
                      // Handle delete action
                    },
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
