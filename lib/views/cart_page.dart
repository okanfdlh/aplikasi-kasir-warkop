import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController cartController = Get.find();

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    cartController.cartItems.forEach((product) {
      final quantity = cartController.cartQuantities[product.id] ?? 1;
      _controllers[product.id] = TextEditingController(text: quantity.toString());
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keranjang Anda"),
        backgroundColor: Colors.green,
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Text(
              "Keranjang masih kosong",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  Product product = cartController.cartItems[index];
                  int quantity = cartController.cartQuantities[product.id] ?? 1;
                  double totalHarga = product.price * quantity;

                  _controllers.putIfAbsent(product.id, () =>
                      TextEditingController(text: quantity.toString()));

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.shopping_bag, size: 36, color: Colors.green),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("Harga satuan: ${formatRupiah(product.price)}",
                                    style: TextStyle(fontSize: 13)),
                                Text("Total: ${formatRupiah(totalHarga)}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green[700])),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline,
                                          color: Colors.red),
                                      onPressed: () {
                                        cartController.decreaseQuantity(product);
                                        _controllers[product.id]?.text =
                                            (cartController.cartQuantities[product.id] ?? 1).toString();
                                        setState(() {});
                                      },
                                    ),
                                    Container(
                                      width: 40,
                                      height: 32,
                                      child: TextField(
                                        controller: _controllers[product.id],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onSubmitted: (value) {
                                          int newQty = int.tryParse(value) ?? 1;
                                          if (newQty < 1) newQty = 1;

                                          cartController.cartQuantities[product.id] = newQty;
                                          cartController.saveCartToPrefs();
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline,
                                          color: Colors.green),
                                      onPressed: () {
                                        cartController.increaseQuantity(product);
                                        _controllers[product.id]?.text =
                                            (cartController.cartQuantities[product.id] ?? 1).toString();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.grey[700]),
                            onPressed: () {
                              cartController.removeFromCart(product);
                              _controllers.remove(product.id);
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.payment),
                  label: Text("Pesan dan Bayar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    double totalHargaSemua = 0;
                    cartController.cartItems.forEach((product) {
                      int quantity = cartController.cartQuantities[product.id] ?? 1;
                      totalHargaSemua += product.price * quantity;
                    });

                    Get.toNamed('/pembayaran', arguments: {
                    'totalHarga': totalHargaSemua,
                    'items': cartController.cartItems.map((product) {
                      int quantity = cartController.cartQuantities[product.id] ?? 1;
                      return {
                        'name': product.name,
                        'price': product.price,
                        'quantity': quantity,
                      };
                    }).toList()
                  });
                  },
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
