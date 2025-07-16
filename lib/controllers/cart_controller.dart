import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class CartController extends GetxController {
  var cartItems = <Product>[].obs;
  var cartQuantities = <int, int>{}.obs;

  @override
  void onInit() {
    loadCartFromPrefs();
    super.onInit();
  }

  void addToCart(Product product, [int quantity = 1]) async {
    if (!cartItems.any((item) => item.id == product.id)) {
      cartItems.add(product);
    }
    cartQuantities[product.id] = (cartQuantities[product.id] ?? 0) + quantity;
    await saveCartToPrefs();
  }

  void increaseQuantity(Product product) async {
  addToCart(product); // Gunakan addToCart agar kuantitas dan penyimpanan otomatis
}

  void decreaseQuantity(Product product) {
    if (cartQuantities[product.id] != null && cartQuantities[product.id]! > 1) {
      cartQuantities[product.id] = cartQuantities[product.id]! - 1;
      saveCartToPrefs();
    }
  }

  void removeFromCart(Product product) {
    cartItems.remove(product);
    cartQuantities.remove(product.id);
    saveCartToPrefs();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
    await prefs.remove('quantities');
    cartItems.clear();
    cartQuantities.clear();
  }

  Future<void> saveCartToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> cartJson =
      cartItems.map((item) => jsonEncode(item.toJson())).toList();
  Map<String, String> quantityMap = cartQuantities.map(
      (key, value) => MapEntry(key.toString(), value.toString()));

  await prefs.setStringList('cart', cartJson);
  await prefs.setString('cart_quantities', jsonEncode(quantityMap));
}


  Future<void> loadCartFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? cartJson = prefs.getStringList('cart');
  final String? quantityJson = prefs.getString('cart_quantities');

  if (cartJson != null) {
    cartItems.value =
        cartJson.map((item) => Product.fromJson(jsonDecode(item))).toList();
  }

  if (quantityJson != null) {
    Map<String, dynamic> decoded = jsonDecode(quantityJson);
    cartQuantities.value = decoded.map((key, value) =>
        MapEntry(int.parse(key), int.parse(value.toString())));
  }
}

}
