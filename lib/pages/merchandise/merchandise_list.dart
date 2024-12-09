import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8000/api/merchandise/show/7e74fdc9-c388-4d16-ae1b-58eac2b1438e")); //nunggu id event
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          setState(() {
            merchandise = jsonResponse['data'];
          });
        } else {
          throw Exception('Invalid JSON: Missing "data" key');
        }
      } else {
        throw Exception('Failed to load merchandise');
      }
    } catch (e) {
      setState(() {
        merchandise = _mockMerchandiseList();
      });
    }
  }

  List<dynamic> _mockMerchandiseList() {
    return [
      {
        'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Ariana_Grande_interview_2016.png/800px-Ariana_Grande_interview_2016.png',
        'name': 'Mock Item 1',
        'description': 'Description for mock item 1',
        'quantity': 10,
        'price': 10.0,
      },
      {
        'imageUrl': 'https://cdn.antaranews.com/cache/1200x800/2023/06/30/3-Foto-Milkita-Bites-3.jpg',
        'name': 'Mock Item 2',
        'description': 'Description for mock item 2',
        'quantity': 10,
        'price': 20.0,
      },
      {
        'imageUrl': 'https://cdn.antaranews.com/cache/1200x800/2023/06/30/3-Foto-Milkita-Bites-3.jpg',
        'name': 'Mock Item 3',
        'description': 'Description for mock item 3',
        'quantity': 10,
        'price': 30.0,
      },
    ];
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
            imageUrl: merchandise[index]['imageUrl'],
            quantity: merchandise[index]['quantity'],
            name: merchandise[index]['name'],
            description: merchandise[index]['description'],
            price: merchandise[index]['price'].toString(),
            isAdmin: false,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MerchandiseDetail(
                    imageUrl: merchandise[index]['imageUrl'],
                    name: merchandise[index]['name'],
                    description: merchandise[index]['description'],
                    price: merchandise[index]['price'].toString(),
                    isAdmin: true,
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMerchandise(),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create Merchandise',
      ),
    );
  }
}
