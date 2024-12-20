import 'package:eventyog_mobile/models/cart_models.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCartPage extends StatefulWidget {
  @override
  _MyCartPageState createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  List<dynamic> localCartEvents = [];
  List<dynamic> localCartMerch = [];
  UserProfile? userProfile; // Tambahkan variabel ini
  Future<void>? _fetchCartFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _fetchCartFuture = fetchCartData(request);
  }

  Future<void> fetchCartData(CookieRequest request) async {
    try {
      final response =
          await request.get("http://localhost:8000/api/cart/get_cart_data/");

      if (response.containsKey('user_profile') &&
          response.containsKey('cart_events') &&
          response.containsKey('cart_merch')) {
        if (mounted) {
          setState(() {
            // Perbaikan: Ambil userProfile dari response
            userProfile = UserProfile.fromJson(response['user_profile']);
            localCartEvents = (response['cart_events'] as List)
                .map((e) => EventCart.fromJson(e))
                .toList();
            localCartMerch = (response['cart_merch'] as List)
                .map((m) => MerchCart.fromJson(m))
                .toList();
          });
        }
      } else {
        throw Exception('Invalid JSON format');
      }
    } catch (e) {
      print('Error fetching cart data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load cart data')),
        );
      }
    }
  }

  Future<void> checkout(CookieRequest request) async {
  final cartData = {
    "event": localCartEvents.map((event) => {
          "name": event.ticketName,
          "quantity": event.quantity,
          "pricePerItem": event.price,
        }).toList(),
    "merch": localCartMerch.map((merch) => {
          "name": merch.name,
          "quantity": merch.quantity,
          "pricePerItem": merch.price,
        }).toList(),
  };

  double totalPrice = _calculateTotalPrice();

  if ((userProfile?.walletBalance ?? 0.0) < totalPrice) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Insufficient balance. Please top up your wallet.')),
    );
    return;
  }

  if (localCartEvents.isEmpty && localCartMerch.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Your cart is empty!')),
  );
  return;
}

  try {
    final response = await request.post(
      "http://localhost:8000/api/cart/checkout/",
      jsonEncode(cartData),
    );
    final newBalance = double.parse(response['new_wallet_balance']);
    if (response['status'] == true) {
  // Respons berhasil
      setState(() {
          userProfile?.walletBalance = newBalance;
          localCartEvents.clear();
          localCartMerch.clear();
        });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout successful!')),
    );
  } else {
    throw Exception(response['error']);
  }
  } catch (e) {
    print('Error during checkout: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('transaction success')),
    );
    
  }

}

// Fungsi untuk mengosongkan keranjang di server
Future<void> emptyCart(CookieRequest request) async {
  try {
    final response = await request.post(
      "http://localhost:8000/api/cart/empty_cart/",
      {},
    );

    if (response['status'] != true) {
      throw Exception('Failed to empty cart');
    }
  } catch (e) {
    print('Error emptying cart: $e');
  }
}


Widget _cartItem(dynamic item, {required bool isEvent}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Image.network(item.imageUrl,
              width: 100, height: 100, fit: BoxFit.cover),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEvent ? item.ticketName : item.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('Price: Rp${item.price.toStringAsFixed(2)}'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (item.quantity > 0) { // Kuantitas minimum 0
                            item.quantity -= 1;
                          }
                        });
                      },
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          item.quantity += 1;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text('Rp${(item.quantity * item.price).toStringAsFixed(2)}'),
        ],
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  double totalPrice = _calculateTotalPrice(); // Hitung total harga
  double walletBalance = userProfile?.walletBalance ?? 0.0;
  double remainingBalance = walletBalance - totalPrice; // Sisa uang

  return Scaffold(
    appBar: AppBar(title: const Text("My Cart")),
    body: FutureBuilder<void>(
      future: _fetchCartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Menampilkan item Event
                    if (localCartEvents.isNotEmpty)
                      ...localCartEvents
                          .map<Widget>((event) => _cartItem(event, isEvent: true))
                          .toList(),

                    // Menampilkan item Merchandise
                    if (localCartMerch.isNotEmpty)
                      ...localCartMerch
                          .map<Widget>((merch) => _cartItem(merch, isEvent: false))
                          .toList(),
                  ],
                ),
              ),

              // Total Price, Wallet Balance, dan Sisa Uang di Bawah
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance: Rp${walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Price: Rp${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remaining Balance: Rp${remainingBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: remainingBalance < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Checkout di Bawah
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    final request = context.read<CookieRequest>();
                    checkout(request);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              ElevatedButton(
        onPressed: () async {
          final request = context.read<CookieRequest>();
          await emptyCart(request); // Panggil fungsi emptyCart

          setState(() {
            localCartEvents.clear(); // Kosongkan state lokal untuk event
            localCartMerch.clear();  // Kosongkan state lokal untuk merchandise
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cart has been emptied successfully')),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.red, // Warna merah untuk tombol
        ),
        child: const Text(
          "Empty Cart",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
            ],
          );
        }
      },
    ),
  );
}

// Fungsi untuk menghitung total harga semua item di keranjang
double _calculateTotalPrice() {
  double total = 0.0;

  for (var event in localCartEvents) {
    total += event.price * event.quantity;
  }

  for (var merch in localCartMerch) {
    total += merch.price * merch.quantity;
  }

  return total;
}
}

class ApiService {
  final String baseUrl = 'http://localhost:8000/api/cart';

  Future<Map<String, dynamic>> fetchCartData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_cart_data/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: $data');

        return {
          'userProfile': UserProfile.fromJson(data['userProfile']),
          'cartEvents': (data['cartEvents'] as List)
              .map((e) => EventCart.fromJson(e))
              .toList(),
          'cartMerch': (data['cartMerch'] as List)
              .map((m) => MerchCart.fromJson(m))
              .toList(),
        };
      } else {
        throw Exception('Failed to fetch cart data');
      }
    } catch (e) {
      throw Exception('Error fetching cart data: $e');
    }
  }

  Future<bool> checkoutCart(Map<String, dynamic> cartData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkout/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cartData),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error during checkout: $e');
    }
  }

  Future<bool> emptyCart() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/empty_cart/'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error emptying cart: $e');
    }
  }

  Future<void> updateCart(Map<String, dynamic> updatedCart) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update_cart/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedCart),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update cart');
      }
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }
}
