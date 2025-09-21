import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/menu_controller.dart' as MyMenuController;
import 'components/product_card.dart';
import 'edit_menu_page.dart';
import '../../controllers/cart_controller.dart';
import '../cart/cart_page.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final MyMenuController.MenuController menuController = Get.put(
    MyMenuController.MenuController(),
  );

  String categorySelected = 'Semua';
  final TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _showSearchBar = false;

  String formatRupiah(double price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(price);
  }

  @override
  void initState() {
    super.initState();
    categorySelected = menuController.selectedCategory.value;
    Get.put(CartController());
    menuController.fetchProducts();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text(
          'Daftar Menu',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff024924),
        elevation: 0,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/ic_search.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
              });
            },
          ),
          // Tombol keranjang
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              size: 24,
              color: Colors.white,
            ),
            onPressed: () => Get.to(() => CartPage()),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔥 Search bar dengan animasi smooth
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1500),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0, // muncul dari atas
                  child: child,
                ),
              );
            },
            child: _showSearchBar
                ? Container(
                    key: const ValueKey(
                        "searchBar"), // penting biar switcher tahu widget beda
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey.shade200,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Cari menu...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              _showSearchBar = false;
                            });
                            // reset filter
                            menuController.fetchProducts();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        menuController.filterProducts(query: value);
                      },
                    ),
                  )
                : const SizedBox(
                    key: ValueKey("emptySpace"),
                  ),
          ),

          //konten lain
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Modern SliverAppBar
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Menu Tersedia',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff024924),
                                  ),
                                ),
                                buildTotalItems(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            buildCategories(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Products Grid
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (menuController.isLoading.value) {
                      return Container(
                        height: 400,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Memuat menu...',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (menuController.filteredProducts.isEmpty) {
                      return Container(
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada menu tersedia',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Coba ubah kategori atau tambah menu baru',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount:
                                    menuController.filteredProducts.length,
                                itemBuilder: (context, index) {
                                  return AnimatedContainer(
                                    duration: Duration(
                                      milliseconds: 300 + (index * 100),
                                    ),
                                    curve: Curves.easeOutBack,
                                    child: ProductCard(
                                      product: menuController
                                          .filteredProducts[index],
                                      onEdit: () {
                                        Get.to(
                                          EditMenuPage(
                                            product: menuController
                                                .filteredProducts[index],
                                          ),
                                        );
                                      },
                                      onDelete: () {
                                        _showDeleteConfirmationDialog(
                                          context,
                                          menuController
                                              .filteredProducts[index].id,
                                        );
                                      },
                                      onPesan: (quantity) {
                                        final CartController cartController =
                                            Get.put(
                                          CartController(),
                                        );
                                        cartController.addToCart(
                                          menuController
                                              .filteredProducts[index],
                                          quantity,
                                        );

                                        Get.rawSnackbar(
                                          message:
                                              "$quantity ${menuController.filteredProducts[index].name} dimasukkan ke keranjang",
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.black,
                                          borderRadius: 12,
                                          margin: const EdgeInsets.all(16),
                                          duration: const Duration(seconds: 2),
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.orange.shade400,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Konfirmasi Penghapusan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Apakah Anda yakin ingin menghapus produk ini? Tindakan ini tidak dapat dibatalkan.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          menuController.deleteProduct(productId);
                          Navigator.of(context).pop();
                          Get.rawSnackbar(
                            message: "Menu berhasil dihapus",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.black,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Hapus",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTotalItems() {
    return Obx(() {
      final itemCount = menuController.filteredProducts.length;

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "$itemCount item",
          style: TextStyle(
            color: Colors.green.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  Widget buildCategories() {
    return Obx(() {
      final categories = menuController.categories;

      if (categories.isEmpty) {
        return const SizedBox(
          height: 35,
          child: Center(
            child: Text(
              "Tidak ada kategori",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 29,
          child: ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              String category = categories[index];
              bool isActive = categorySelected == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    categorySelected = category;
                  });
                  menuController.selectedCategory.value = category;
                  menuController.filterProducts();
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 24 : 8,
                    right: index == categories.length - 1 ? 24 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xff024924)
                        : const Color.fromARGB(255, 220, 255, 217)
                            .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  alignment: Alignment.center,
                  child: Text(
                    category,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                      color: isActive ? Colors.white : const Color(0xff313131),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }
}

// class ProductSearchDelegate extends SearchDelegate<String> {
//   final MyMenuController.MenuController menuController;

//   ProductSearchDelegate(this.menuController);

//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     return Theme.of(context).copyWith(
//       appBarTheme: AppBarTheme(
//         backgroundColor: Colors.green.shade600,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       inputDecorationTheme: const InputDecorationTheme(
//         hintStyle: TextStyle(color: Colors.white70),
//         border: InputBorder.none,
//       ),
//       textTheme: const TextTheme(
//         titleLarge: TextStyle(color: Colors.white, fontSize: 18),
//       ),
//     );
//   }

//   @override
//   String get searchFieldLabel => 'Cari menu...';

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => close(context, ''),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     menuController.searchProducts(query);
//     close(context, query);
//     return const SizedBox();
//   }

//   // @override
//   // Widget buildSuggestions(BuildContext context) {
//   //   final suggestions = menuController.products
//   //       .where(
//   //         (product) => product.name.toLowerCase().contains(query.toLowerCase()),
//   //       )
//   //       .toList();

//   //   if (suggestions.isEmpty) {
//   //     return Center(
//   //       child: Column(
//   //         mainAxisAlignment: MainAxisAlignment.center,
//   //         children: [
//   //           Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
//   //           const SizedBox(height: 16),
//   //           Text(
//   //             'Tidak ada hasil',
//   //             style: TextStyle(
//   //               fontSize: 18,
//   //               color: Colors.grey.shade600,
//   //               fontWeight: FontWeight.w500,
//   //             ),
//   //           ),
//   //           const SizedBox(height: 8),
//   //           Text(
//   //             'Coba kata kunci yang berbeda',
//   //             style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   }

//     // return ListView.builder(
//     //   itemCount: suggestions.length,
//     //   itemBuilder: (context, index) {
//     //     final product = suggestions[index];
//     //     return ListTile(
//     //       leading: Container(
//     //         width: 50,
//     //         height: 50,
//     //         decoration: BoxDecoration(
//     //           borderRadius: BorderRadius.circular(8),
//     //           image: DecorationImage(
//     //             image: NetworkImage(
//     //               product.image.startsWith('http')
//     //                   ? product.image
//     //                   : '${ApiService.baseUrl}/storage/${product.image}',
//     //             ),
//     //             fit: BoxFit.cover,
//     //           ),
//     //         ),
//     //       ),
//     //       title: Text(
//     //         product.name,
//     //         style: const TextStyle(fontWeight: FontWeight.w600),
//     //       ),
//     //       subtitle: Text(
//     //         NumberFormat.currency(
//     //           locale: 'id_ID',
//     //           symbol: 'Rp ',
//     //           decimalDigits: 0,
//     //         ).format(product.price),
//     //         style: TextStyle(color: Colors.green.shade600),
//     //       ),
//     //       trailing: const Icon(Icons.search),
//     //       onTap: () {
//     //         query = product.name;
//     //         showResults(context);
//     //       },
//     //     );
//     //   },
//     // );
//   // }
// }
