class EventCart {
  final String imageUrl;
  final String title;
  final String ticketName;
  final double price;
  int quantity;
  double totalPrice;

  EventCart({
    required this.imageUrl,
    required this.title,
    required this.ticketName,
    required this.price,
    this.quantity = 1, // Default quantity is 1
  }): totalPrice = price * quantity;

 void updateTotalPrice() {
    totalPrice = price * quantity; // Tambahkan method untuk memperbarui totalPrice
  }
  // Create EventCart from JSON
  factory EventCart.fromJson(Map<String, dynamic> json) {
    try{
       return EventCart(
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? 'Unknown Event',
      ticketName: json['ticket_name'] ?? 'Unknown Ticket',
      price: _safeToDouble(json['price']),
      quantity: json['quantity'] ?? 1,
    );
    } catch (e){
       throw Exception('Error parsing EventCart: $e');
    }
   
  }

  // Convert EventCart to JSON
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'title': title,
      'ticket_name': ticketName,
      'price': price,
      'quantity': quantity,
    };
  }
}

class MerchCart {
  final String imageUrl;
  final String name;
  final double price;
  int quantity;
  double totalPrice;
  // Getter to calculate the total price

  MerchCart({
    required this.imageUrl,
    required this.name,
    required this.price,
    this.quantity = 1, // Default quantity is 1
  }): totalPrice = price * quantity;

  // Create MerchCart from JSON
  factory MerchCart.fromJson(Map<String, dynamic> json) {
    try{
      return MerchCart(
      imageUrl: json['image_url'] ?? '',
      name: json['name'] ?? 'Unknown Merchandise',
      price: _safeToDouble(json['price']),
      quantity: json['quantity'] ?? 1,
    );
    }catch (e){
       throw Exception('Error parsing MerchCart: $e');
    }
    
  }

  // Convert MerchCart to JSON
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class UserProfile {
  double walletBalance;

  UserProfile({
    required this.walletBalance,
  });

  // Create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try{
      return UserProfile(
      walletBalance: _safeToDouble(json['wallet_balance']),
    );
    } catch(e){
      throw Exception('Error parsing UserProfile: $e');
    }
    
  }

  // Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'wallet_balance': walletBalance,
    };
  }
}

// Helper function to safely parse dynamic values to double
double _safeToDouble(dynamic value) {
  if (value is int) {
    return value.toDouble();
  } else if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0; // Default to 0.0 if parsing fails
}
