import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMerchandise extends StatefulWidget {
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final int id; // Add id parameter
  final VoidCallback onEdit; // Add callback for refetching
  final String quantity; // Add quantity parameter

  EditMerchandise({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.id, // Initialize id
    required this.onEdit, // Initialize callback
    required this.quantity, // Initialize quantity
  }) : assert(name != null),
       assert(description != null),
       assert(price != null),
       assert(imageUrl != null),
       assert(id != null),
       assert(onEdit != null),
       assert(quantity != null); // Ensure all parameters are not null

  @override
  _EditMerchandiseState createState() => _EditMerchandiseState();
}

class _EditMerchandiseState extends State<EditMerchandise> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;
  late TextEditingController quantityController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    descriptionController = TextEditingController(text: widget.description);
    priceController = TextEditingController(text: widget.price);
    imageUrlController = TextEditingController(text: widget.imageUrl);
    quantityController = TextEditingController(text: widget.quantity);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _editMerchandise() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/merchandise/edit/${widget.id}/');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.parse(priceController.text),
      'image_url': imageUrlController.text,
      'quantity': int.parse(quantityController.text), // Add quantity to request body
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      widget.onEdit(); // Call the callback to refetch data
      Navigator.pop(context, {
        'id': widget.id, // Ensure id is included in the result
        'name': nameController.text,
        'description': descriptionController.text,
        'price': priceController.text,
        'imageUrl': imageUrlController.text,
        'quantity': quantityController.text, // Add quantity to result
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit merchandise')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Merchandise'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Please enter a valid number';
                    }
                    if (price < 1) {
                      return 'Price must be at least 1';
                    }
                    if (price >= 100000000) {
                      return 'Price must be less than 100000000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null) {
                      return 'Please enter a valid number';
                    }
                    if (quantity < 1) {
                      return 'Quantity must be at least 1';
                    }
                    if (quantity >= 100000000) {
                      return 'Quantity must be less than 100000000';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _editMerchandise();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
