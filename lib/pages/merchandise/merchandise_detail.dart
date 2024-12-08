import 'package:flutter/material.dart';
import '../merchandise/merchandise_card.dart';

class MerchandiseDetail extends StatelessWidget {
  final bool isAdmin; // Menentukan apakah admin atau bukan

  MerchandiseDetail({required this.isAdmin});

  // Dummy data (nanti diganti dengan data dari backend)
  final Map<String, dynamic> merchandiseData = {
    'id': 1,
    'image_url': 'https://via.placeholder.com/150',
    'name': 'Sample Merchandise',
    'description': 'This is a sample merchandise description.',
    'price': '50000',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchandise Detail'),
      ),
      body: Center(
        child: MerchandiseCard(
          imageUrl: merchandiseData['image_url'],
          name: merchandiseData['name'],
          description: merchandiseData['description'],
          price: merchandiseData['price'],
          isAdmin: isAdmin,
          onEdit: () {
            // Tambahkan navigasi ke halaman edit
            print('Edit pressed');
          },
          onDelete: () {
            // Tambahkan logika untuk delete
            print('Delete pressed');
          },
        ),
      ),
    );
  }
}
