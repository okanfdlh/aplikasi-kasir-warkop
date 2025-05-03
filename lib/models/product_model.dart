import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String image;
  final double price; // Make sure price is a double
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
  });

  // Parsing JSON data to Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: double.tryParse(json['price']) ?? 0.0, // Convert string to double safely
      category: json['category'],
    );
  }

  // Converting Product to JSON format (optional, in case you need to send data back to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price.toString(), // Convert price back to string when sending to API
      'category': category,
    };
  }
}
