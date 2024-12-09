import 'package:flutter/material.dart';

class MerchandiseCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final bool isAdmin;
  final int quantity; // Add this line
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  MerchandiseCard({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.isAdmin,
    required this.quantity, // Add this line
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  _MerchandiseCardState createState() => _MerchandiseCardState();
}

class _MerchandiseCardState extends State<MerchandiseCard> {
  int boughtQuantity = 0;

  void _increaseBoughtQuantity() {
    setState(() {
      boughtQuantity++;
    });
  }

  void _decreaseBoughtQuantity() {
    setState(() {
      if (boughtQuantity > 0) {
        boughtQuantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Ensure onTap is here
      child: Card(
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    widget.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: EdgeInsets.all(10), // Increase padding to make it larger
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle, // Change to circular shape
                    ),
                    child: Text(
                      '${widget.quantity}', // Display the quantity
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rp${widget.price}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: _decreaseBoughtQuantity,
                          ),
                          Text(
                            '$boughtQuantity', // Display the bought quantity
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: _increaseBoughtQuantity,
                          ),
                        ],
                      ),
                      if (widget.isAdmin)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: widget.onEdit,
                              icon: Icon(Icons.edit),
                              label: Text('Edit'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: widget.onDelete,
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              style: ElevatedButton.styleFrom(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
