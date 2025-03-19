import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/menu_controller.dart' as MyMenuController;
import '../widgets/product_card.dart';
import 'tambah_menu_page.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final MyMenuController.MenuController menuController = Get.put(MyMenuController.MenuController());
  final TextEditingController searchController = TextEditingController();
  bool hasRedirected = false;

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(price);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasRedirected) {
      hasRedirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.off(() => TambahMenuPage(bearerToken: 'Bearer your_api_token_here'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Menu"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              String? result = await showSearch(
                context: context,
                delegate: ProductSearchDelegate(menuController),
              );
              if (result != null) {
                menuController.searchProducts(result);
              }
            },
          ),
        ],
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
                return const Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: menuController.filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: menuController.filteredProducts[index],
                    onEdit: () {
                      // Navigasi ke halaman edit jika ada
                    },
                    onDelete: () {
                      menuController.deleteProduct(menuController.filteredProducts[index].id);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => TambahMenuPage(bearerToken: 'Bearer your_api_token_here'));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final MyMenuController.MenuController menuController;

  ProductSearchDelegate(this.menuController);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    menuController.searchProducts(query);
    close(context, query);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: menuController.products
          .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
          .map((product) => ListTile(
                title: Text(product.name),
                onTap: () {
                  query = product.name;
                  showResults(context);
                },
              ))
          .toList(),
    );
  }
}
