import 'package:eventyog_mobile/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'merchandise_card.dart';
import 'merchandise_detail.dart';
import 'create_merchandise.dart';
import 'edit_merchandise.dart';

class MerchandiseList extends StatefulWidget {
  final String eventId;

  MerchandiseList({required this.eventId});

  @override
  _MerchandiseListState createState() => _MerchandiseListState();
}

class _MerchandiseListState extends State<MerchandiseList> {
  List<dynamic> merchandise = [];
  bool isAdmin = false;
  bool isLoading = true;
  String errorMessage = '';
  List<int> _itemAmount = [];
  Map<String, int> cartItems =
      {}; // Map to store selected merchandise and their quantities

  @override
  void initState() {
    super.initState();
    fetchMerchandise();
  }

  Future<void> fetchMerchandise() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request
          .get("$fetchUrl/api/merchandise/show/${widget.eventId}/");

      if (response['status'] == 'success') {
        setState(() {
          merchandise = response['data'];
          isAdmin = response['is_admin'] ?? false;
          isLoading = false;
          _itemAmount = List<int>.filled(merchandise.length, 0);
        });
      } else {
        throw Exception('Failed to load merchandise');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching merchandise: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteMerchandise(int id) async {
    final url = "$fetchUrl/api/merchandise/delete/$id/";
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
          await fetchMerchandise();
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

  void _navigateToCreateMerchandise() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMerchandise(
          onCreate: fetchMerchandise,
          eventId: widget.eventId,
        ),
      ),
    );
  }

  void _navigateToEditMerchandise(dynamic merchandise) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMerchandise(
          name: merchandise['name'],
          description: merchandise['description'],
          price: merchandise['price'].toString(),
          imageUrl: merchandise['image_url'],
          id: merchandise['pk'],
          onEdit: fetchMerchandise,
          quantity: merchandise['quantity'].toString(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        final index =
            this.merchandise.indexWhere((item) => item['pk'] == result['id']);
        if (index != -1) {
          this.merchandise[index] = result;
        }
      });
    }
  }

  void _increaseBoughtQuantity(int index) {
    if (index < 0 || index >= _itemAmount.length) {
      debugPrint("Invalid index: $index");
      return;
    }

    setState(() {
      if (_itemAmount[index] < merchandise[index]['quantity']) {
        _itemAmount[index]++;
        cartItems[merchandise[index]['name']] = _itemAmount[index];
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

  void _decreaseBoughtQuantity(int index) {
    if (index < 0 || index >= _itemAmount.length) {
      debugPrint("Invalid index: $index");
      return;
    }

    setState(() {
      if (_itemAmount[index] > 0) {
        _itemAmount[index]--;
        if (_itemAmount[index] == 0) {
          cartItems.remove(merchandise[index]['name']);
        } else {
          cartItems[merchandise[index]['name']] = _itemAmount[index];
        }
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

  void _navigateToCartPage() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => CartPage()), // Placeholder CartPage
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Merchandise List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAdmin)
              TextButton(
                onPressed: _navigateToCreateMerchandise,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Create Merchandise'),
                  ],
                ),
              ),
          ],
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: merchandise.length,
                    itemBuilder: (context, index) {
                      dynamic merchandiseItem = merchandise[index];
                      return Column(
                        children: [
                          MerchandiseCard(
                            imageUrl: merchandiseItem['image_url'] ?? '',
                            quantity: merchandiseItem['quantity'] ?? 0,
                            name: merchandiseItem['name'] ?? 'Unknown',
                            description: merchandiseItem['description'] ??
                                'No description',
                            price:
                                merchandiseItem['price']?.toString() ?? '0.0',
                            isAdmin: isAdmin,
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      MerchandiseDetail(
                                    id: merchandiseItem['pk'],
                                    imageUrl:
                                        merchandiseItem['image_url'] ?? '',
                                    name: merchandiseItem['name'] ?? 'Unknown',
                                    description:
                                        merchandiseItem['description'] ??
                                            'No description',
                                    price:
                                        merchandiseItem['price']?.toString() ??
                                            '0.0',
                                    isAdmin: isAdmin,
                                    onEdit: fetchMerchandise,
                                    quantity: merchandiseItem['quantity']
                                            ?.toString() ??
                                        '0',
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            onDelete: isAdmin
                                ? () => deleteMerchandise(merchandiseItem['pk'])
                                : null,
                            increaseBoughtQuantity: () =>
                                _increaseBoughtQuantity(index),
                            decreaseBoughtQuantity: () =>
                                _decreaseBoughtQuantity(index),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
        if (cartItems.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    ...cartItems.entries.map((entry) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  entry.key.length > 100
                                      ? '${entry.key.substring(0, 100)}...'
                                      : entry.key,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('${entry.value}'),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _navigateToCartPage,
                        icon: Icon(Icons.shopping_cart, color: Colors.white),
                        label: const Text('Go to Cart'),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24), // Increased horizontal padding
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
