class Product {
  final int id;
  final String name;
  final double price;
  final int productCategoryId;
  final String? categoryName;
  final int stock;
  final String image;
  final int totalSold;
  final DateTime? firstSoldAt;
  final DateTime? lastSoldAt;
  final int totalToday;
  final int totalThisMonth;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.productCategoryId,
    required this.categoryName,
    required this.stock,
    required this.image,
    required this.totalSold,
    required this.firstSoldAt,
    required this.lastSoldAt,
    required this.totalToday,
    required this.totalThisMonth,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Product(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: parseDouble(json['price']),
      productCategoryId: json['product_category_id'] ?? 0,
      categoryName: json['category_name']?.toString() ?? 'Tidak diketahui',
      stock: parseInt(json['stock']),
      image: json['image']?.toString() ?? '',
      totalSold: parseInt(json['total_sold']),
      firstSoldAt: parseDate(json['first_sold_at']),
      lastSoldAt: parseDate(json['last_sold_at']),
      totalThisMonth: parseInt(json['total_this_month']),
      totalToday: parseInt(json['total_today']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  // Converting Product to JSON format (optional, in case you need to send data back to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price':
          price.toString(), // Convert price back to string when sending to API
      'stock':
          stock.toString(), // Convert stock back to string when sending to API
      'category': categoryName,
    };
  }
}
