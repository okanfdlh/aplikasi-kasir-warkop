import 'package:coffeeorder/components/my_button.dart';
import 'package:coffeeorder/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController cartController = Get.find();

  bool isLoading = false;

  String formatRupiah(double price) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    cartController.cartItems.forEach((product) {
      final quantity = cartController.cartQuantities[product.id] ?? 1;
      _controllers[product.id] =
          TextEditingController(text: quantity.toString());
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
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: false,
        title: const Text(
          'Keranjang',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff024924),
        elevation: 0,
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return const Center(
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

                  _controllers.putIfAbsent(product.id,
                      () => TextEditingController(text: quantity.toString()));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Thumbnail
                        SizedBox(
                          width: 70,
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: Image.network(
                              '${ApiService.baseUrl}/storage/${product.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        /// Nama + Qty
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama produk + kategori
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.black),
                              ),
                              Text(
                                product.categoryName ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),

                              // Tombol qty
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      cartController.increaseQuantity(product);
                                      _controllers[product.id]
                                          ?.text = (cartController
                                                  .cartQuantities[product.id] ??
                                              1)
                                          .toString();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add,
                                        color: Colors.green),
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      '${cartController.cartQuantities[product.id] ?? 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cartController.decreaseQuantity(product);
                                      _controllers[product.id]
                                          ?.text = (cartController
                                                  .cartQuantities[product.id] ??
                                              1)
                                          .toString();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.remove,
                                        color: Colors.red),
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// Harga + Delete
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                cartController.removeFromCart(product);
                                _controllers.remove(product.id);
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete,
                                  size: 18, color: Colors.redAccent),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                formatRupiah(totalHarga),
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MyButton(
                text: "Checkout",
                isLoading: isLoading,
                onPressed: () {
                  double totalHargaSemua = 0;
                  cartController.cartItems.forEach((product) {
                    int quantity =
                        cartController.cartQuantities[product.id] ?? 1;
                    totalHargaSemua += product.price * quantity;
                  });

                  Get.toNamed('/pembayaran', arguments: {
                    'totalHarga': totalHargaSemua,
                    'items': cartController.cartItems.map((product) {
                      int quantity =
                          cartController.cartQuantities[product.id] ?? 1;
                      return {
                        'name': product.name,
                        'price': product.price,
                        'quantity': quantity,
                      };
                    }).toList()
                  });
                }, // fungsi tetap sama
              ),
            )
          ],
        );
      }),
    );
  }
}
