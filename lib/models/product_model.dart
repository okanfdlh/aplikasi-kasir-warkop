import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String image;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
  });

  // Factory untuk parsing JSON ke objek Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: double.tryParse(json['price'].toString()) ?? 0.0, // Default to 0.0 if parsing fails
      category: json['category'],
    );
  }

  // Method untuk mengubah List JSON menjadi List<Product>
  static List<Product> fromJsonList(String jsonStr) {
    final List<dynamic> data = json.decode(jsonStr);
    return data.map((item) => Product.fromJson(item)).toList();
  }
}
