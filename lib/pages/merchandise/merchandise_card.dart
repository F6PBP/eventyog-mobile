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
      if (boughtQuantity < widget.quantity) { // Add validation to not exceed quantity
        boughtQuantity++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot add more than available quantity'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _decreaseBoughtQuantity() {
    setState(() {
      if (boughtQuantity > 0) {
        boughtQuantity--;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The minimum number for payment is 1'),
            duration: Duration(seconds: 2),
          ),
        );
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
        child: Padding( // Add padding here
          padding: const EdgeInsets.all(16.0), // Consistent padding around the card content
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Adjusted font size
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]), // Adjusted font size
                          maxLines: 2, // Limit description to 2 lines
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Rp${widget.price}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green), // Adjusted font size
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0), // Adjust padding for the image
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15), // More rounded corners for the image
                          child: Image.network(
                            widget.imageUrl,
                            height: 140, // Increased height for the image
                            width: 140, // Increased width for the image
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
                  ),
                ],
              ),
              // Add buttons directly below the image, to the far end right
              Padding(
                padding: const EdgeInsets.only(right: 30.0, top: 8.0), // Add gap between image and buttons
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the far end right
                  children: [
                    Container(
                      color: Colors.white, // Background color white
                      child: IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decreaseBoughtQuantity,
                        color: Colors.black, // Change font color to black
                        padding: EdgeInsets.all(0),
                        constraints: BoxConstraints(),
                        iconSize: 24,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white, // Change background color to white
                      child: Text(
                        '$boughtQuantity', // Display the bought quantity
                        style: TextStyle(fontSize: 16, color: Colors.black), // Change font color to black
                      ),
                    ),
                    Container(
                      color: Colors.white, // Background color white
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _increaseBoughtQuantity,
                        color: Colors.black, // Change font color to black
                        padding: EdgeInsets.all(0),
                        constraints: BoxConstraints(),
                        iconSize: 24,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
