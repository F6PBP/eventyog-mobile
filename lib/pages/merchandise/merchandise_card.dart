import 'package:flutter/material.dart';

class MerchandiseCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  MerchandiseCard({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.isAdmin,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
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
            if (isAdmin) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onDelete,
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
