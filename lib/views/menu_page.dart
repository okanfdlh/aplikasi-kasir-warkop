import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/menu_controller.dart' as MyMenuController;
import '../widgets/product_card.dart';

class MenuPage extends StatelessWidget {
  final MyMenuController.MenuController menuController = Get.put(MyMenuController.MenuController());

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Menu"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() => DropdownButton<String>(
                  value: menuController.selectedCategory.value,
                  isExpanded: true,
                  items: menuController.categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    menuController.selectedCategory.value = value!;
                    menuController.filterProducts();
                  },
                )),
          ),
          Expanded(
            child: Obx(() {
              if (menuController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: menuController.filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: menuController.filteredProducts[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
