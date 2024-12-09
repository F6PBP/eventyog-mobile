import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'merchandise_card.dart';
import 'merchandise_detail.dart';

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
        print(jsonResponse['data']);
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
      print('Error: $e');
      setState(() {
        merchandise = _mockMerchandiseList();
      });
    }
  }

  List<dynamic> _mockMerchandiseList() {
    return [
      {
        'imageUrl': 'https://via.placeholder.com/150',
        'name': 'Mock Item 1',
        'description': 'Description for mock item 1',
        'price': 10.0,
      },
      {
        'imageUrl': 'https://via.placeholder.com/150',
        'name': 'Mock Item 2',
        'description': 'Description for mock item 2',
        'price': 20.0,
      },
      {
        'imageUrl': 'https://via.placeholder.com/150',
        'name': 'Mock Item 3',
        'description': 'Description for mock item 3',
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
          print(merchandise[index]);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MerchandiseDetail(
                    imageUrl: merchandise[index]['imageUrl'],
                    name: merchandise[index]['name'],
                    description: merchandise[index]['description'],
                    price: merchandise[index]['price'].toString(),
                    isAdmin: true,
                  ),
                ),
              );
            },
            child: MerchandiseCard(
              imageUrl: merchandise[index]['imageUrl'],
              name: merchandise[index]['name'],
              description: merchandise[index]['description'],
              price: merchandise[index]['price'].toString(),
              isAdmin: false,
            ),
          );
        },
      ),
    );
  }
}
