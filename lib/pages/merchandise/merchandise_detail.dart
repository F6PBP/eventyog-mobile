import 'package:eventyog_mobile/const.dart';
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
  final int id;
  final VoidCallback onEdit;
  final String quantity;

  MerchandiseDetail({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.isAdmin,
    required this.id,
    required this.onEdit,
    required this.quantity,
  });

  @override
  _MerchandiseDetailState createState() => _MerchandiseDetailState();
}

class _MerchandiseDetailState extends State<MerchandiseDetail> {
  late String name;
  late String description;
  late String price;
  late String imageUrl;
  late String quantity;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    description = widget.description;
    price = widget.price;
    imageUrl = widget.imageUrl;
    quantity = widget.quantity;
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
          id: widget.id,
          onEdit: widget.onEdit,
          quantity: widget.quantity,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        name = result['name'];
        description = result['description'];
        price = result['price'];
        imageUrl = result['imageUrl'];
        quantity = result['quantity'];
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this merchandise?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await deleteMerchandise();
    }
  }

  Future<void> deleteMerchandise() async {
    final url = "$fetchUrl/api/merchandise/delete/${widget.id}/";
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
          widget.onEdit();
          Navigator.pop(context);
        } else {
          throw Exception('Failed to delete merchandise');
        }
      } else {
        throw Exception('Failed to delete merchandise');
      }
    } catch (e) {
      print('Error deleting merchandise: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        imageUrl,
                        height: constraints.maxWidth > 600 ? 350 : 200,
                        width: constraints.maxWidth > 600
                            ? 400
                            : constraints.maxWidth * 0.9,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  name,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Text(
                  'Rp$price',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                SizedBox(height: 8),
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                if (widget.isAdmin) ...[
                  SizedBox(height: 24),
                  constraints.maxWidth > 400
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _editMerchandise,
                              icon: Icon(Icons.edit),
                              label: Text('Edit'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _confirmDelete,
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _editMerchandise,
                              icon: Icon(Icons.edit,
                                  size: 18, color: Colors.white),
                              label: Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _confirmDelete,
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
