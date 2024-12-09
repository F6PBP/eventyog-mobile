class Merchandise {
  final int id;
  final String imageUrl;
  final String name;
  final String description;
  final String price;
  final String relatedEvent;
  final int quantity;
  final String createdAt;
  final String updatedAt;
  final int boughtQuantity;

  Merchandise({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.relatedEvent,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.boughtQuantity,
  });

  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      id: json['pk'],
      imageUrl: json['image_url'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      relatedEvent: json['related_event'],
      quantity: json['quantity'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      boughtQuantity: json['bought_quantity'],
    );
  }
}
